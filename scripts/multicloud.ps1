# Multi-Cloud Infrastructure Management Script
# Supports AWS, Azure, and GCP with Terraform automation

param(
    [switch]$Help
)

# Display help information
if ($Help) {
    Write-Host @"
Multi-Cloud Infrastructure Management Tool
=========================================

This script helps you manage infrastructure across multiple cloud providers using Terraform.

Usage: .\multicloud.ps1

Features:
- Create or destroy infrastructure
- Support for AWS, Azure, and GCP
- Automated Terraform initialization and execution
- Cross-platform cloud management
- User-friendly CLI interface

Requirements:
- Terraform must be installed and available in PATH
- Cloud provider CLI tools (AWS CLI, Azure CLI, or gcloud)
- Appropriate cloud credentials configured

Directory Structure Expected:
- aws/     - Contains AWS Terraform configurations
- azure/   - Contains Azure Terraform configurations
- gcp/     - Contains GCP Terraform configurations
"@
    exit 0
}

# Function to display the main menu
function Show-MainMenu {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "    Multi-Cloud Infrastructure Management Tool     " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "What would you like to do?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Create Infrastructure" -ForegroundColor Green
    Write-Host "2. Destroy Infrastructure" -ForegroundColor Red
    Write-Host "3. Exit" -ForegroundColor Gray
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Function to display cloud provider menu
function Show-CloudMenu {
    param([string]$Action)
    
    Clear-Host    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "           Select Cloud Provider                   " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You selected: $Action Infrastructure" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Choose your cloud provider:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. AWS (Amazon Web Services)" -ForegroundColor DarkYellow
    Write-Host "2. Azure (Microsoft Azure)" -ForegroundColor Blue
    Write-Host "3. GCP (Google Cloud Platform)" -ForegroundColor Green
    Write-Host "4. Back to Main Menu" -ForegroundColor Gray
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Test-TerraformInstalled {
    try {
        $null = Get-Command terraform -ErrorAction Stop
        return $true
    }
    catch {
        Write-Host "Terraform is not installed or not in PATH." -ForegroundColor Red
        return $false
    }
}

function Install-Terraform {
    Write-Host "Installing Terraform..." -ForegroundColor Cyan
    
    try {
        # Check if Chocolatey is available
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "Using Chocolatey to install Terraform..." -ForegroundColor Yellow
            choco install terraform -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Terraform installed successfully via Chocolatey!" -ForegroundColor Green
                return $true
            }
        }
        
        # Check if Winget is available
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Using Winget to install Terraform..." -ForegroundColor Yellow
            winget install HashiCorp.Terraform
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Terraform installed successfully via Winget!" -ForegroundColor Green
                return $true
            }
        }
        
        # Manual installation method
        Write-Host "Installing Terraform manually..." -ForegroundColor Yellow
        
        # Create temp directory
        $tempDir = Join-Path $env:TEMP "terraform-install"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        # Download latest Terraform
        $terraformUrl = "https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_windows_amd64.zip"
        $zipPath = Join-Path $tempDir "terraform.zip"
        
        Write-Host "Downloading Terraform..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $terraformUrl -OutFile $zipPath -UseBasicParsing
        
        # Extract and install
        Write-Host "Extracting Terraform..." -ForegroundColor Yellow
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
        
        # Create installation directory
        $installDir = "C:\Tools\Terraform"
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        
        # Copy terraform.exe to installation directory
        Copy-Item -Path (Join-Path $tempDir "terraform.exe") -Destination $installDir -Force
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$installDir*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installDir", "User")
            Write-Host "Added Terraform to PATH" -ForegroundColor Green
        }
        
        # Update current session PATH
        $env:PATH += ";$installDir"
        
        # Clean up
        Remove-Item -Path $tempDir -Recurse -Force
        
        Write-Host "Terraform installed successfully!" -ForegroundColor Green
        Write-Host "Installed to: $installDir" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Host "Failed to install Terraform automatically: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please install Terraform manually from: https://www.terraform.io/downloads.html" -ForegroundColor Yellow
        return $false
    }
}

# Function to check cloud authentication
function Test-CloudAuthentication {
    param([string]$CloudProvider)
    
    switch ($CloudProvider.ToLower()) {
        "aws" {
            try {
                aws sts get-caller-identity --output json | Out-Null
                return $LASTEXITCODE -eq 0
            }
            catch {
                return $false
            }
        }
        "azure" {
            try {
                az account show --output json | Out-Null
                return $LASTEXITCODE -eq 0
            }
            catch {
                return $false
            }
        }
        "gcp" {
            try {
                gcloud auth list --filter=status:ACTIVE --format="value(account)" | Out-Null
                return $LASTEXITCODE -eq 0
            }
            catch {
                return $false
            }
        }
        default {
            return $false
        }
    }
}

function Test-CloudDirectory {
    param([string]$CloudProvider)
    
    $dirPath = Join-Path (Split-Path $PWD -Parent) "terraform\environments\$CloudProvider"
    if (-not (Test-Path $dirPath)) {
        Write-Host "Error: Directory 'terraform\environments\$CloudProvider' not found." -ForegroundColor Red
        Write-Host "Expected path: $dirPath" -ForegroundColor Yellow
        Write-Host "Please ensure your Terraform configurations are organized in the following structure:" -ForegroundColor White
        Write-Host "  - terraform/environments/aws/     (for AWS configurations)" -ForegroundColor Yellow
        Write-Host "  - terraform/environments/azure/   (for Azure configurations)" -ForegroundColor Cyan
        Write-Host "  - terraform/environments/gcp/     (for GCP configurations)" -ForegroundColor Green
        return $false
    }
    return $true
}

# Function to execute Terraform commands
function Invoke-TerraformOperation {
    param(
        [string]$CloudProvider,
        [string]$Operation
    )
    
    $cloudDir = Join-Path (Split-Path $PWD -Parent) "terraform\environments\$CloudProvider"
    $originalLocation = Get-Location
      try {
        Write-Host ""
        Write-Host "Starting $Operation operation for $($CloudProvider.ToUpper())..." -ForegroundColor Cyan
        Write-Host "Working directory: $cloudDir" -ForegroundColor Gray
        Write-Host ""
        
        # Change to cloud provider directory
        Set-Location $cloudDir
        
        # Initialize Terraform
        Write-Host "Initializing Terraform..." -ForegroundColor Yellow
        Write-Host "Running: terraform init" -ForegroundColor Gray
        terraform init
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform initialization failed"
        }
        
        Write-Host "Terraform initialization completed successfully!" -ForegroundColor Green
        Write-Host ""        # Execute the requested operation
        if ($Operation -eq "Create") {
            Write-Host "Building infrastructure..." -ForegroundColor Yellow
            Write-Host "Running: terraform apply -auto-approve" -ForegroundColor Gray
            
            # Run terraform apply with timeout
            $process = Start-Process -FilePath "terraform" -ArgumentList "apply", "-auto-approve" -NoNewWindow -PassThru -RedirectStandardOutput "terraform_output.txt" -RedirectStandardError "terraform_error.txt"
            
            # Wait for process with timeout (10 minutes)
            $timeout = 600
            if ($process.WaitForExit($timeout * 1000)) {
                $exitCode = $process.ExitCode
                
                # Display output
                if (Test-Path "terraform_output.txt") {
                    Get-Content "terraform_output.txt" | Write-Host
                    Remove-Item "terraform_output.txt" -Force
                }
                if (Test-Path "terraform_error.txt") {
                    Get-Content "terraform_error.txt" | Write-Host -ForegroundColor Red
                    Remove-Item "terraform_error.txt" -Force
                }
                
                if ($exitCode -ne 0) {
                    throw "Terraform apply failed with exit code: $exitCode"
                }
            } else {
                $process.Kill()
                throw "Terraform apply timed out after $timeout seconds"
            }
        }
        elseif ($Operation -eq "Destroy") {
            Write-Host "Destroying infrastructure..." -ForegroundColor Yellow
            Write-Host "Running: terraform destroy -auto-approve" -ForegroundColor Gray
            
            # Run terraform destroy with timeout
            $process = Start-Process -FilePath "terraform" -ArgumentList "destroy", "-auto-approve" -NoNewWindow -PassThru -RedirectStandardOutput "terraform_output.txt" -RedirectStandardError "terraform_error.txt"
            
            # Wait for process with timeout (10 minutes)
            $timeout = 600
            if ($process.WaitForExit($timeout * 1000)) {
                $exitCode = $process.ExitCode
                
                # Display output
                if (Test-Path "terraform_output.txt") {
                    Get-Content "terraform_output.txt" | Write-Host
                    Remove-Item "terraform_output.txt" -Force
                }
                if (Test-Path "terraform_error.txt") {
                    Get-Content "terraform_error.txt" | Write-Host -ForegroundColor Red
                    Remove-Item "terraform_error.txt" -Force
                }
                
                if ($exitCode -ne 0) {
                    throw "Terraform destroy failed with exit code: $exitCode"
                }
            } else {
                $process.Kill()
                throw "Terraform destroy timed out after $timeout seconds"
            }
        }
          Write-Host ""
        Write-Host "$Operation operation completed successfully!" -ForegroundColor Green
        Write-Host "$($CloudProvider.ToUpper()) infrastructure has been ${Operation.ToLower()}d!" -ForegroundColor Cyan
        
    }
    catch {
        Write-Host ""
        Write-Host "Error during $Operation operation: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please check the Terraform output above for more details." -ForegroundColor Yellow
    }
    finally {
        # Return to original directory
        Set-Location $originalLocation
        Write-Host ""
        Write-Host "Press any key to continue..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Function to get user input with validation
function Get-ValidatedInput {
    param(
        [string]$Prompt,
        [string[]]$ValidOptions,
        [string]$ErrorMessage = "Invalid selection. Please try again."
    )
    
    do {
        Write-Host $Prompt -ForegroundColor White -NoNewline
        $input = Read-Host
        if ($input -in $ValidOptions) {
            return $input
        }
        Write-Host $ErrorMessage -ForegroundColor Red
        Write-Host ""
    } while ($true)
}

# Function to check and configure authentication for all cloud providers upfront
function Initialize-CloudAuthentication {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "           Authentication Setup                    " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Checking authentication status for all cloud providers..." -ForegroundColor Yellow
    Write-Host ""
    
    $cloudProviders = @(
        @{ Name = "AWS"; Dir = "aws"; Command = "aws configure"; AuthScript = ".\configure-cloud-auth.ps1 -AWS" },
        @{ Name = "Azure"; Dir = "azure"; Command = "az login"; AuthScript = ".\configure-cloud-auth.ps1 -Azure" },
        @{ Name = "GCP"; Dir = "gcp"; Command = "gcloud auth login"; AuthScript = ".\configure-cloud-auth.ps1 -GCP" }
    )
    
    $authStatus = @{}
    $needsAuth = @()
    
    # Check authentication status for each provider
    foreach ($provider in $cloudProviders) {
        Write-Host "Checking $($provider.Name)..." -ForegroundColor Cyan -NoNewline
        
        if (Test-CloudDirectory $provider.Dir) {
            if (Test-CloudAuthentication $provider.Dir) {
                Write-Host " ✅ Authenticated" -ForegroundColor Green
                $authStatus[$provider.Name] = $true
            }
            else {
                Write-Host " ❌ Not authenticated" -ForegroundColor Red
                $authStatus[$provider.Name] = $false
                $needsAuth += $provider
            }
        }
        else {
            Write-Host " ⚠️  Directory not found" -ForegroundColor Yellow
            $authStatus[$provider.Name] = "No Directory"
        }
    }
    
    if ($needsAuth.Count -eq 0) {
        Write-Host ""
        Write-Host "All available cloud providers are authenticated! ✅" -ForegroundColor Green
        Write-Host ""
        Write-Host "Press any key to continue to the main menu..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
    
    # Show authentication options for providers that need setup
    Write-Host ""
    Write-Host "The following cloud providers need authentication:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($provider in $needsAuth) {
        Write-Host "• $($provider.Name)" -ForegroundColor Red
        Write-Host "  Commands: $($provider.Command)" -ForegroundColor Gray
        Write-Host "  Or run: $($provider.AuthScript)" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "Would you like to configure authentication now?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Configure authentication interactively" -ForegroundColor Green
    Write-Host "2. Skip and continue (you'll be prompted later)" -ForegroundColor Yellow
    Write-Host "3. Exit and configure manually" -ForegroundColor Red
    Write-Host ""
    
    $choice = Get-ValidatedInput "Enter your choice (1-3): " @("1", "2", "3")
    
    switch ($choice) {
        "1" {
            # Interactive authentication setup
            foreach ($provider in $needsAuth) {
                Write-Host ""
                Write-Host "Configuring $($provider.Name) authentication..." -ForegroundColor Cyan
                Write-Host ""
                
                $configChoice = Get-ValidatedInput "Configure $($provider.Name) now? (y/n): " @("y", "n", "Y", "N")
                
                if ($configChoice.ToLower() -eq "y") {
                    Write-Host "Running authentication setup for $($provider.Name)..." -ForegroundColor Yellow
                    
                    try {
                        switch ($provider.Dir) {
                            "aws" {
                                Write-Host "Opening AWS configuration..." -ForegroundColor Cyan
                                aws configure
                            }
                            "azure" {
                                Write-Host "Opening Azure login..." -ForegroundColor Cyan
                                az login
                            }
                            "gcp" {
                                Write-Host "Opening Google Cloud authentication..." -ForegroundColor Cyan
                                gcloud auth login
                            }
                        }
                        
                        # Verify authentication after setup
                        if (Test-CloudAuthentication $provider.Dir) {
                            Write-Host "$($provider.Name) authentication successful! ✅" -ForegroundColor Green
                        }
                        else {
                            Write-Host "$($provider.Name) authentication may have failed. ❌" -ForegroundColor Red
                            Write-Host "You can configure it later or run: $($provider.AuthScript)" -ForegroundColor Yellow
                        }
                    }
                    catch {
                        Write-Host "Error during $($provider.Name) authentication: $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host "You can configure it later or run: $($provider.AuthScript)" -ForegroundColor Yellow
                    }
                }
                else {
                    Write-Host "Skipping $($provider.Name) authentication." -ForegroundColor Yellow
                }
            }
            
            Write-Host ""
            Write-Host "Authentication setup completed!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Press any key to continue to the main menu..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Write-Host ""
            Write-Host "Skipping authentication setup." -ForegroundColor Yellow
            Write-Host "You will be prompted to authenticate when selecting a cloud provider." -ForegroundColor Gray
            Write-Host ""
            Write-Host "Press any key to continue to the main menu..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Write-Host ""
            Write-Host "Please configure authentication manually and run the script again:" -ForegroundColor Yellow
            Write-Host ""
            foreach ($provider in $needsAuth) {
                Write-Host "For $($provider.Name): $($provider.Command)" -ForegroundColor Gray
                Write-Host "Or: $($provider.AuthScript)" -ForegroundColor Gray
                Write-Host ""
            }
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
    }
}

# Main script execution
function Start-MultiCloudManager {
    # Check prerequisites
    if (-not (Test-TerraformInstalled)) {
        Write-Host ""
        Write-Host "Would you like to install Terraform automatically?" -ForegroundColor Yellow
        $installChoice = Get-ValidatedInput "Install Terraform now? (y/n): " @("y", "n", "Y", "N")
          if ($installChoice.ToLower() -eq "y") {
            if (Install-Terraform) {
                Write-Host ""
                Write-Host "Terraform installation completed! Restarting the tool..." -ForegroundColor Green
                Start-Sleep 3
                
                # Verify installation
                if (-not (Test-TerraformInstalled)) {
                    Write-Host "Terraform installation verification failed." -ForegroundColor Red
                    Write-Host "You may need to restart your PowerShell session or reboot your computer." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "Press any key to exit..." -ForegroundColor Gray
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    exit 1
                }
            } else {
                Write-Host ""
                Write-Host "Press any key to exit..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                exit 1
            }
        } else {
            Write-Host "Terraform installation cancelled. Please install Terraform manually and run the script again." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    }
    
    # Initialize cloud authentication
    Initialize-CloudAuthentication
    
    do {
        Show-MainMenu
        $mainChoice = Get-ValidatedInput "Enter your choice (1-3): " @("1", "2", "3")
        
        switch ($mainChoice) {            "1" {
                $action = "Create"
                do {
                    Show-CloudMenu $action
                    $cloudChoice = Get-ValidatedInput "Enter your choice (1-4): " @("1", "2", "3", "4")
                    
                    $cloudMap = @{
                        "1" = @{ Name = "AWS"; Dir = "aws" }
                        "2" = @{ Name = "Azure"; Dir = "azure" }
                        "3" = @{ Name = "GCP"; Dir = "gcp" }
                    }
                    
                    if ($cloudChoice -eq "4") {
                        break
                    }
                    
                    $selectedCloud = $cloudMap[$cloudChoice]
                    
                    if (Test-CloudDirectory $selectedCloud.Dir) {
                        # Check authentication before proceeding
                        Write-Host ""
                        Write-Host "Checking $($selectedCloud.Name) authentication..." -ForegroundColor Cyan
                        
                        if (-not (Test-CloudAuthentication $selectedCloud.Dir)) {
                            Write-Host "Authentication failed for $($selectedCloud.Name)!" -ForegroundColor Red
                            Write-Host "Please configure authentication first:" -ForegroundColor Yellow
                            switch ($selectedCloud.Dir) {
                                "aws" { 
                                    Write-Host "Run: aws configure" -ForegroundColor Gray 
                                    Write-Host "Or: .\configure-cloud-auth.ps1 -AWS" -ForegroundColor Gray
                                }
                                "azure" { 
                                    Write-Host "Run: az login" -ForegroundColor Gray 
                                    Write-Host "Or: .\configure-cloud-auth.ps1 -Azure" -ForegroundColor Gray
                                }
                                "gcp" { 
                                    Write-Host "Run: gcloud auth login" -ForegroundColor Gray 
                                    Write-Host "Or: .\configure-cloud-auth.ps1 -GCP" -ForegroundColor Gray
                                }
                            }
                            Write-Host ""
                            Write-Host "Press any key to continue..." -ForegroundColor Gray
                            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                            continue
                        }
                        
                        Write-Host "Authentication verified!" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "WARNING: You are about to CREATE infrastructure on $($selectedCloud.Name)!" -ForegroundColor Yellow
                        $confirm = Get-ValidatedInput "Are you sure you want to proceed? (y/n): " @("y", "n", "Y", "N")
                        
                        if ($confirm.ToLower() -eq "y") {
                            Invoke-TerraformOperation $selectedCloud.Dir $action
                        } else {
                            Write-Host "Operation cancelled." -ForegroundColor Yellow
                            Start-Sleep 2
                        }
                    }
                } while ($cloudChoice -ne "4")
            }            "2" {
                $action = "Destroy"
                do {
                    Show-CloudMenu $action
                    $cloudChoice = Get-ValidatedInput "Enter your choice (1-4): " @("1", "2", "3", "4")
                    
                    $cloudMap = @{
                        "1" = @{ Name = "AWS"; Dir = "aws" }
                        "2" = @{ Name = "Azure"; Dir = "azure" }
                        "3" = @{ Name = "GCP"; Dir = "gcp" }
                    }
                    
                    if ($cloudChoice -eq "4") {
                        break
                    }
                    
                    $selectedCloud = $cloudMap[$cloudChoice]
                    
                    if (Test-CloudDirectory $selectedCloud.Dir) {
                        # Check authentication before proceeding
                        Write-Host ""
                        Write-Host "Checking $($selectedCloud.Name) authentication..." -ForegroundColor Cyan
                        
                        if (-not (Test-CloudAuthentication $selectedCloud.Dir)) {
                            Write-Host "Authentication failed for $($selectedCloud.Name)!" -ForegroundColor Red
                            Write-Host "Please configure authentication first:" -ForegroundColor Yellow
                            switch ($selectedCloud.Dir) {
                                "aws" { 
                                    Write-Host "Run: aws configure" -ForegroundColor Gray 
                                    Write-Host "Or: .\configure-cloud-auth.ps1 -AWS" -ForegroundColor Gray
                                }
                                "azure" { 
                                    Write-Host "Run: az login" -ForegroundColor Gray 
                                    Write-Host "Or: .\configure-cloud-auth.ps1 -Azure" -ForegroundColor Gray
                                }
                                "gcp" { 
                                    Write-Host "Run: gcloud auth login" -ForegroundColor Gray 
                                    Write-Host "Or: .\configure-cloud-auth.ps1 -GCP" -ForegroundColor Gray
                                }
                            }
                            Write-Host ""
                            Write-Host "Press any key to continue..." -ForegroundColor Gray
                            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                            continue
                        }
                        
                        Write-Host "Authentication verified!" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "DANGER: You are about to DESTROY infrastructure on $($selectedCloud.Name)!" -ForegroundColor Red
                        Write-Host "This action cannot be undone!" -ForegroundColor Red
                        $confirm = Get-ValidatedInput "Are you absolutely sure you want to proceed? (y/n): " @("y", "n", "Y", "N")
                        
                        if ($confirm.ToLower() -eq "y") {
                            Write-Host "Last chance! Type 'DESTROY' to confirm:" -ForegroundColor Red -NoNewline
                            $finalConfirm = Read-Host
                            if ($finalConfirm -eq "DESTROY") {
                                Invoke-TerraformOperation $selectedCloud.Dir $action
                            } else {
                                Write-Host "Operation cancelled." -ForegroundColor Yellow
                                Start-Sleep 2
                            }
                        } else {
                            Write-Host "Operation cancelled." -ForegroundColor Yellow
                            Start-Sleep 2
                        }
                    }
                } while ($cloudChoice -ne "4")
            }            "3" {
                Write-Host ""
                Write-Host "Thank you for using Multi-Cloud Infrastructure Management Tool!" -ForegroundColor Cyan
                Write-Host "Goodbye!" -ForegroundColor Green
                exit 0
            }
        }
    } while ($true)
}

# Script entry point
Write-Host "Initializing Multi-Cloud Infrastructure Management Tool..." -ForegroundColor Cyan
Start-Sleep 1
Start-MultiCloudManager