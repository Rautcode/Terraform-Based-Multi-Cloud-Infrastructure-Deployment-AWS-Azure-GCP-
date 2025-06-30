# Enhanced Multi-Cloud Setup Script with Authentication Checks
# Works with the new terraform/environments/ structure

param(
    [switch]$CheckOnly,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Multi-Cloud Infrastructure Management Setup Script
=================================================

Usage: .\setup.ps1 [options]

Options:
-CheckOnly    Only check authentication status and project structure
-Help         Show this help message

This script helps you set up and manage multi-cloud infrastructure using Terraform.
It supports AWS, Azure, and Google Cloud Platform.
"@
    exit 0
}

Write-Host "Multi-Cloud Infrastructure Management" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Function to check authentication status for a cloud provider
function Test-CloudAuthentication {
    param([string]$Provider)
    
    switch ($Provider) {
        "aws" {
            try {
                $result = aws sts get-caller-identity 2>$null
                return $LASTEXITCODE -eq 0
            } catch {
                return $false
            }
        }
        "azure" {
            try {
                $result = az account show 2>$null
                return $LASTEXITCODE -eq 0
            } catch {
                return $false
            }
        }
        "gcp" {
            try {
                $result = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
                return $LASTEXITCODE -eq 0 -and $result.Trim() -ne ""
            } catch {
                return $false
            }
        }
    }
    return $false
}

# Function to configure authentication for a cloud provider
function Configure-CloudAuth {
    param([string]$Provider)
    
    Write-Host "`nConfiguring $Provider authentication..." -ForegroundColor Yellow
    
    switch ($Provider) {
        "aws" {
            Write-Host "Starting AWS authentication..." -ForegroundColor Cyan
            Write-Host "Please configure AWS credentials using one of these methods:" -ForegroundColor White
            Write-Host "1. Run: aws configure" -ForegroundColor Gray
            Write-Host "2. Set environment variables" -ForegroundColor Gray
            Write-Host "3. Use AWS SSO: aws configure sso" -ForegroundColor Gray
            $choice = Read-Host "`nWould you like to run 'aws configure' now? (y/n)"
            if ($choice -eq "y" -or $choice -eq "Y") {
                aws configure
            }
        }
        "azure" {
            Write-Host "Starting Azure authentication..." -ForegroundColor Cyan
            $choice = Read-Host "Would you like to login to Azure now? (y/n)"
            if ($choice -eq "y" -or $choice -eq "Y") {
                az login
            }
        }
        "gcp" {
            Write-Host "Starting GCP authentication..." -ForegroundColor Cyan
            $choice = Read-Host "Would you like to authenticate with Google Cloud now? (y/n)"
            if ($choice -eq "y" -or $choice -eq "Y") {
                gcloud auth login
            }
        }
    }
}

# Check if running from project root or scripts directory
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$projectRoot = if ((Split-Path $scriptDir -Leaf) -eq "scripts") {
    Split-Path $scriptDir -Parent
} else {
    $scriptDir
}
$terraformPath = Join-Path $projectRoot "terraform\environments"

if (-not (Test-Path $terraformPath)) {
    Write-Host "Error: This script must be run from a properly structured multi-cloud project." -ForegroundColor Red
    Write-Host "Expected terraform/environments/ directory not found." -ForegroundColor Yellow
    Write-Host "Please ensure you're running from the correct directory structure." -ForegroundColor White
    exit 1
}

# Check authentication status for all providers
Write-Host "Checking cloud provider authentication status..." -ForegroundColor Yellow
Write-Host ""

$authStatus = @{
    "AWS" = Test-CloudAuthentication "aws"
    "Azure" = Test-CloudAuthentication "azure" 
    "GCP" = Test-CloudAuthentication "gcp"
}

foreach ($provider in $authStatus.Keys) {
    if ($authStatus[$provider]) {
        Write-Host "[OK] $provider - Authenticated" -ForegroundColor Green
    } else {
        Write-Host "[X] $provider - Not authenticated" -ForegroundColor Red
    }
}

# Offer to configure authentication for unauthenticated providers
$unauthenticated = $authStatus.Keys | Where-Object { -not $authStatus[$_] }

if ($unauthenticated.Count -gt 0) {
    Write-Host "`nWarning: Some cloud providers are not authenticated." -ForegroundColor Yellow
    
    if ($CheckOnly) {
        Write-Host "CheckOnly mode: Authentication status check complete." -ForegroundColor Yellow
        Write-Host "`nProject structure: VALID" -ForegroundColor Green
        Write-Host "Authentication status:" -ForegroundColor Cyan
        foreach ($provider in $authStatus.Keys) {
            $status = if ($authStatus[$provider]) { "[OK] Authenticated" } else { "[X] Not authenticated" }
            $color = if ($authStatus[$provider]) { "Green" } else { "Red" }
            Write-Host "  $provider : $status" -ForegroundColor $color
        }
        exit 0
    }
    
    Write-Host "You can configure them now or proceed and authenticate later." -ForegroundColor White
    
    foreach ($provider in $unauthenticated) {
        $configure = Read-Host "`nWould you like to configure $provider authentication now? (y/n)"
        if ($configure -eq "y" -or $configure -eq "Y") {
            Configure-CloudAuth $provider.ToLower()
            
            # Recheck authentication
            Write-Host "`nRechecking $provider authentication..." -ForegroundColor Cyan
            if (Test-CloudAuthentication $provider.ToLower()) {
                Write-Host "[OK] $provider authentication successful!" -ForegroundColor Green
                $authStatus[$provider] = $true
            } else {
                Write-Host "[X] $provider authentication failed. You can configure it later." -ForegroundColor Red
            }
        }
    }
} else {
    if ($CheckOnly) {
        Write-Host "CheckOnly mode: All cloud providers are authenticated!" -ForegroundColor Green
        Write-Host "`nProject structure: VALID" -ForegroundColor Green
        Write-Host "Authentication status: ALL OK" -ForegroundColor Green
        exit 0
    }
    Write-Host "`nAll cloud providers are authenticated!" -ForegroundColor Green
}

Write-Host "`n$('='*50)" -ForegroundColor Cyan
Write-Host ""

# Ask user for action: create or destroy infrastructure
$action = Read-Host "Do you want to CREATE new infrastructure or DESTROY existing infrastructure? (Enter 'create' or 'destroy')"

if ($action -ne "create" -and $action -ne "destroy") {
    Write-Host "Invalid action. Please enter 'create' or 'destroy'." -ForegroundColor Red
    exit 1
}

# Ask user for cloud provider choice
Write-Host "`nSelect Cloud Provider:" -ForegroundColor Cyan
Write-Host ""

# Show authentication status in the menu
if ($authStatus["AWS"]) {
    Write-Host "1. AWS (Amazon Web Services) [OK] Authenticated" -ForegroundColor Green
} else {
    Write-Host "1. AWS (Amazon Web Services) [X] Not Authenticated" -ForegroundColor Yellow
}

if ($authStatus["Azure"]) {
    Write-Host "2. Azure (Microsoft Azure) [OK] Authenticated" -ForegroundColor Green
} else {
    Write-Host "2. Azure (Microsoft Azure) [X] Not Authenticated" -ForegroundColor Yellow
}

if ($authStatus["GCP"]) {
    Write-Host "3. GCP (Google Cloud Platform) [OK] Authenticated" -ForegroundColor Green
} else {
    Write-Host "3. GCP (Google Cloud Platform) [X] Not Authenticated" -ForegroundColor Yellow
}

Write-Host ""
$choice = Read-Host "Enter your choice (1-3)"

# Validate choice and check authentication
$selectedProvider = ""
$providerKey = ""

switch ($choice) {
    "1" {
        $selectedProvider = "aws"
        $providerKey = "AWS"
        $workingDir = Join-Path $projectRoot "terraform\environments\aws"
        Write-Host "[OK] Selected AWS" -ForegroundColor Green
    }
    "2" {
        $selectedProvider = "azure"
        $providerKey = "Azure"
        $workingDir = Join-Path $projectRoot "terraform\environments\azure"
        Write-Host "[OK] Selected Azure" -ForegroundColor Green
    }
    "3" {
        $selectedProvider = "gcp"
        $providerKey = "GCP"
        $workingDir = Join-Path $projectRoot "terraform\environments\gcp"
        Write-Host "[OK] Selected GCP" -ForegroundColor Green
    }
    default {
        Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
        exit 1
    }
}

# Check if selected provider is authenticated
if (-not $authStatus[$providerKey]) {
    Write-Host "`nWarning: $providerKey is not authenticated!" -ForegroundColor Yellow
    Write-Host "This may cause Terraform operations to fail." -ForegroundColor Red
    
    $proceedChoice = Read-Host "`nDo you want to configure $providerKey authentication now? (y/n)"
    if ($proceedChoice -eq "y" -or $proceedChoice -eq "Y") {
        Configure-CloudAuth $selectedProvider
        
        # Recheck authentication
        Write-Host "`nRechecking $providerKey authentication..." -ForegroundColor Cyan
        if (-not (Test-CloudAuthentication $selectedProvider)) {
            Write-Host "[X] Authentication still failed. Terraform operations may not work." -ForegroundColor Red
            $continueChoice = Read-Host "Do you want to continue anyway? (y/n)"
            if ($continueChoice -ne "y" -and $continueChoice -ne "Y") {
                Write-Host "Exiting..." -ForegroundColor Gray
                exit 1
            }
        } else {
            Write-Host "[OK] $providerKey authentication successful!" -ForegroundColor Green
        }
    } else {
        $continueChoice = Read-Host "Do you want to continue without authentication? (y/n)"
        if ($continueChoice -ne "y" -and $continueChoice -ne "Y") {
            Write-Host "Exiting..." -ForegroundColor Gray
            exit 1
        }
    }
}

# Change to the selected provider's directory
Write-Host "`nChanging to $workingDir..." -ForegroundColor Cyan
Set-Location $workingDir

# Initialize Terraform
Write-Host "`nInitializing Terraform..." -ForegroundColor Cyan
terraform init

# Run Terraform apply or destroy based on action
if ($action -eq "create") {
    Write-Host "`nCreating infrastructure..." -ForegroundColor Yellow
    terraform apply -auto-approve
}
elseif ($action -eq "destroy") {
    Write-Host "`nDestroying infrastructure..." -ForegroundColor Magenta
    terraform destroy -auto-approve
}

Write-Host "`nOperation completed!" -ForegroundColor Green
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
