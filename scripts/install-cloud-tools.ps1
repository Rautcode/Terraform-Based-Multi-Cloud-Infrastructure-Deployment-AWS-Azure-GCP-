# Cloud CLI Tools Installation Script
# This script installs AWS CLI, Azure CLI, and Google Cloud CLI on Windows

param(
    [switch]$AWS,
    [switch]$Azure,
    [switch]$GCP,
    [switch]$All,
    [switch]$Help
)

# Display help information
if ($Help) {
    Write-Host @"
Cloud CLI Tools Installation Script
===================================

This script installs cloud provider CLI tools required for the multi-cloud infrastructure management.

Usage: .\install-cloud-tools.ps1 [options]

Options:
-AWS     Install AWS CLI only
-Azure   Install Azure CLI only  
-GCP     Install Google Cloud CLI only
-All     Install all cloud CLI tools (default)
-Help    Show this help message

Examples:
.\install-cloud-tools.ps1 -All
.\install-cloud-tools.ps1 -AWS -Azure
.\install-cloud-tools.ps1 -GCP

After installation, you'll need to configure each CLI tool:
- AWS CLI: aws configure
- Azure CLI: az login
- Google Cloud CLI: gcloud auth login
"@
    exit 0
}

# If no specific options are provided, install all
if (-not $AWS -and -not $Azure -and -not $GCP) {
    $All = $true
}

if ($All) {
    $AWS = $true
    $Azure = $true
    $GCP = $true
}

Write-Host "Cloud CLI Tools Installation Script" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install AWS CLI
function Install-AWSCLI {
    Write-Host "Installing AWS CLI..." -ForegroundColor Yellow
    
    if (Test-CommandExists "aws") {
        Write-Host "AWS CLI is already installed!" -ForegroundColor Green
        aws --version
        return $true
    }
    
    try {
        # Try winget first
        if (Test-CommandExists "winget") {
            Write-Host "Using Winget to install AWS CLI..." -ForegroundColor Cyan
            winget install Amazon.AWSCLI
            if ($LASTEXITCODE -eq 0) {
                Write-Host "AWS CLI installed successfully via Winget!" -ForegroundColor Green
                return $true
            }
        }
        
        # Try chocolatey
        if (Test-CommandExists "choco") {
            Write-Host "Using Chocolatey to install AWS CLI..." -ForegroundColor Cyan
            choco install awscli -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "AWS CLI installed successfully via Chocolatey!" -ForegroundColor Green
                return $true
            }
        }
        
        # Manual installation
        Write-Host "Installing AWS CLI manually..." -ForegroundColor Cyan
        $awsUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
        $tempFile = Join-Path $env:TEMP "AWSCLIV2.msi"
        
        Write-Host "Downloading AWS CLI installer..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $awsUrl -OutFile $tempFile -UseBasicParsing
        
        Write-Host "Installing AWS CLI..." -ForegroundColor Gray
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$tempFile`" /quiet"
        
        Remove-Item $tempFile -Force
        Write-Host "AWS CLI installed successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to install AWS CLI: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to install Azure CLI
function Install-AzureCLI {
    Write-Host "Installing Azure CLI..." -ForegroundColor Yellow
    
    if (Test-CommandExists "az") {
        Write-Host "Azure CLI is already installed!" -ForegroundColor Green
        az --version
        return $true
    }
    
    try {
        # Try winget first
        if (Test-CommandExists "winget") {
            Write-Host "Using Winget to install Azure CLI..." -ForegroundColor Cyan
            winget install Microsoft.AzureCLI
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Azure CLI installed successfully via Winget!" -ForegroundColor Green
                return $true
            }
        }
        
        # Try chocolatey
        if (Test-CommandExists "choco") {
            Write-Host "Using Chocolatey to install Azure CLI..." -ForegroundColor Cyan
            choco install azure-cli -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Azure CLI installed successfully via Chocolatey!" -ForegroundColor Green
                return $true
            }
        }
        
        # Manual installation using PowerShell method
        Write-Host "Installing Azure CLI manually..." -ForegroundColor Cyan
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
        Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
        Remove-Item .\AzureCLI.msi
        
        Write-Host "Azure CLI installed successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to install Azure CLI: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to install Google Cloud CLI
function Install-GoogleCloudCLI {
    Write-Host "Installing Google Cloud CLI..." -ForegroundColor Yellow
    
    if (Test-CommandExists "gcloud") {
        Write-Host "Google Cloud CLI is already installed!" -ForegroundColor Green
        gcloud --version
        return $true
    }
    
    try {
        # Try winget first
        if (Test-CommandExists "winget") {
            Write-Host "Using Winget to install Google Cloud CLI..." -ForegroundColor Cyan
            winget install Google.CloudSDK
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Google Cloud CLI installed successfully via Winget!" -ForegroundColor Green
                return $true
            }
        }
        
        # Try chocolatey
        if (Test-CommandExists "choco") {
            Write-Host "Using Chocolatey to install Google Cloud CLI..." -ForegroundColor Cyan
            choco install gcloudsdk -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Google Cloud CLI installed successfully via Chocolatey!" -ForegroundColor Green
                return $true
            }
        }
        
        # Manual installation
        Write-Host "Installing Google Cloud CLI manually..." -ForegroundColor Cyan
        $gcpUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
        $tempFile = Join-Path $env:TEMP "GoogleCloudSDKInstaller.exe"
        
        Write-Host "Downloading Google Cloud CLI installer..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $gcpUrl -OutFile $tempFile -UseBasicParsing
        
        Write-Host "Installing Google Cloud CLI..." -ForegroundColor Gray
        Start-Process $tempFile -Wait -ArgumentList "/silent"
        
        Remove-Item $tempFile -Force
        Write-Host "Google Cloud CLI installed successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to install Google Cloud CLI: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main installation process
$installResults = @{}

if ($AWS) {
    Write-Host ""
    Write-Host "=== AWS CLI Installation ===" -ForegroundColor Magenta
    $installResults["AWS"] = Install-AWSCLI
}

if ($Azure) {
    Write-Host ""
    Write-Host "=== Azure CLI Installation ===" -ForegroundColor Magenta
    $installResults["Azure"] = Install-AzureCLI
}

if ($GCP) {
    Write-Host ""
    Write-Host "=== Google Cloud CLI Installation ===" -ForegroundColor Magenta
    $installResults["GCP"] = Install-GoogleCloudCLI
}

# Summary
Write-Host ""
Write-Host "=== Installation Summary ===" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$totalCount = 0

foreach ($tool in $installResults.Keys) {
    $totalCount++
    if ($installResults[$tool]) {
        Write-Host "$tool CLI: ✅ Installed Successfully" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "$tool CLI: ❌ Installation Failed" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Installation completed: $successCount/$totalCount tools installed successfully" -ForegroundColor Cyan

if ($successCount -gt 0) {
    Write-Host ""
    Write-Host "=== Next Steps - CLI Configuration ===" -ForegroundColor Yellow
    Write-Host ""
    
    if ($installResults["AWS"]) {
        Write-Host "Configure AWS CLI:" -ForegroundColor White
        Write-Host "  aws configure" -ForegroundColor Gray
        Write-Host "  (You'll need: Access Key ID, Secret Access Key, Default region, Output format)" -ForegroundColor Gray
        Write-Host ""
    }
    
    if ($installResults["Azure"]) {
        Write-Host "Configure Azure CLI:" -ForegroundColor White
        Write-Host "  az login" -ForegroundColor Gray
        Write-Host "  (This will open a browser for authentication)" -ForegroundColor Gray
        Write-Host ""
    }
    
    if ($installResults["GCP"]) {
        Write-Host "Configure Google Cloud CLI:" -ForegroundColor White
        Write-Host "  gcloud auth login" -ForegroundColor Gray
        Write-Host "  gcloud config set project YOUR_PROJECT_ID" -ForegroundColor Gray
        Write-Host "  (This will open a browser for authentication)" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "After configuration, restart PowerShell and run your multicloud.ps1 script!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
