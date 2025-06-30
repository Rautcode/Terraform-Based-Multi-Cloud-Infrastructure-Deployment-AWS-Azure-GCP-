# Cloud CLI Configuration Guide
# This script helps configure authentication for AWS, Azure, and Google Cloud

param(
    [switch]$AWS,
    [switch]$Azure,
    [switch]$GCP,
    [switch]$Status,
    [switch]$Help
)

# Display help information
if ($Help) {
    Write-Host @"
Cloud CLI Configuration Guide
=============================

This script helps you configure authentication for cloud providers.

Usage: .\configure-cloud-auth.ps1 [options]

Options:
-AWS      Configure AWS CLI authentication
-Azure    Configure Azure CLI authentication  
-GCP      Configure Google Cloud CLI authentication
-Status   Check authentication status for all providers
-Help     Show this help message

Examples:
.\configure-cloud-auth.ps1 -Status
.\configure-cloud-auth.ps1 -AWS
.\configure-cloud-auth.ps1 -Azure -GCP

Authentication Methods:
- AWS: Access Key ID and Secret Access Key
- Azure: Interactive browser login
- GCP: Interactive browser login + project setup
"@
    exit 0
}

Write-Host "Cloud CLI Configuration Guide" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Function to check authentication status
function Test-CloudAuth {
    Write-Host "=== Authentication Status Check ===" -ForegroundColor Magenta
    Write-Host ""
    
    # Check AWS
    Write-Host "AWS CLI Status:" -ForegroundColor Yellow
    try {
        $awsResult = aws sts get-caller-identity --output table 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ AWS CLI is configured and authenticated" -ForegroundColor Green
            aws sts get-caller-identity --output table
        } else {
            Write-Host "❌ AWS CLI is not configured or not authenticated" -ForegroundColor Red
            Write-Host "Run: aws configure" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "❌ AWS CLI is not configured or not authenticated" -ForegroundColor Red
        Write-Host "Run: aws configure" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Check Azure
    Write-Host "Azure CLI Status:" -ForegroundColor Yellow
    try {
        $azResult = az account show --output table 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Azure CLI is configured and authenticated" -ForegroundColor Green
            az account show --output table
        } else {
            Write-Host "❌ Azure CLI is not configured or not authenticated" -ForegroundColor Red
            Write-Host "Run: az login" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "❌ Azure CLI is not configured or not authenticated" -ForegroundColor Red
        Write-Host "Run: az login" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Check GCP
    Write-Host "Google Cloud CLI Status:" -ForegroundColor Yellow
    try {
        $gcpResult = gcloud auth list --filter=status:ACTIVE --format="table(account,status)" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $activeAccount = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
            if ($activeAccount) {
                Write-Host "✅ Google Cloud CLI is configured and authenticated" -ForegroundColor Green
                gcloud auth list --filter=status:ACTIVE --format="table(account,status)"
                gcloud config list project --format="table(value)"
            } else {
                Write-Host "❌ Google Cloud CLI is not authenticated" -ForegroundColor Red
                Write-Host "Run: gcloud auth login" -ForegroundColor Gray
            }
        } else {
            Write-Host "❌ Google Cloud CLI is not authenticated" -ForegroundColor Red
            Write-Host "Run: gcloud auth login" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "❌ Google Cloud CLI is not authenticated" -ForegroundColor Red
        Write-Host "Run: gcloud auth login" -ForegroundColor Gray
    }
    Write-Host ""
}

# Function to configure AWS
function Configure-AWS {
    Write-Host "=== AWS CLI Configuration ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "You'll need the following from your AWS account:" -ForegroundColor Yellow
    Write-Host "- Access Key ID" -ForegroundColor White
    Write-Host "- Secret Access Key" -ForegroundColor White
    Write-Host "- Default region (e.g., us-east-1)" -ForegroundColor White
    Write-Host "- Output format (json recommended)" -ForegroundColor White
    Write-Host ""
    Write-Host "Get these from: AWS Console > IAM > Users > Your User > Security Credentials" -ForegroundColor Gray
    Write-Host ""
    
    $confirm = Read-Host "Do you have your AWS credentials ready? (y/n)"
    if ($confirm.ToLower() -eq "y") {
        Write-Host "Running AWS configuration..." -ForegroundColor Cyan
        aws configure
        
        Write-Host ""
        Write-Host "Testing AWS configuration..." -ForegroundColor Cyan
        aws sts get-caller-identity
    } else {
        Write-Host "Please get your AWS credentials and run: aws configure" -ForegroundColor Yellow
    }
}

# Function to configure Azure
function Configure-Azure {
    Write-Host "=== Azure CLI Configuration ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "This will open a browser window for authentication." -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "Ready to log in to Azure? (y/n)"
    if ($confirm.ToLower() -eq "y") {
        Write-Host "Opening browser for Azure authentication..." -ForegroundColor Cyan
        az login
        
        Write-Host ""
        Write-Host "Listing available subscriptions..." -ForegroundColor Cyan
        az account list --output table
        
        Write-Host ""
        Write-Host "If you have multiple subscriptions, set the default with:" -ForegroundColor Yellow
        Write-Host "az account set --subscription <subscription-id>" -ForegroundColor Gray
    } else {
        Write-Host "Run when ready: az login" -ForegroundColor Yellow
    }
}

# Function to configure GCP
function Configure-GCP {
    Write-Host "=== Google Cloud CLI Configuration ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "This will:" -ForegroundColor Yellow
    Write-Host "1. Open a browser window for authentication" -ForegroundColor White
    Write-Host "2. List your available projects" -ForegroundColor White
    Write-Host "3. Help you set a default project" -ForegroundColor White
    Write-Host ""
    
    $confirm = Read-Host "Ready to log in to Google Cloud? (y/n)"
    if ($confirm.ToLower() -eq "y") {
        Write-Host "Opening browser for Google Cloud authentication..." -ForegroundColor Cyan
        gcloud auth login
        
        Write-Host ""
        Write-Host "Listing available projects..." -ForegroundColor Cyan
        gcloud projects list
        
        Write-Host ""
        $projectId = Read-Host "Enter your project ID (or press Enter to skip)"
        if ($projectId) {
            gcloud config set project $projectId
            Write-Host "Default project set to: $projectId" -ForegroundColor Green
        } else {
            Write-Host "You can set a default project later with:" -ForegroundColor Yellow
            Write-Host "gcloud config set project YOUR_PROJECT_ID" -ForegroundColor Gray
        }
    } else {
        Write-Host "Run when ready: gcloud auth login" -ForegroundColor Yellow
    }
}

# Main execution
if ($Status -or (-not $AWS -and -not $Azure -and -not $GCP)) {
    Test-CloudAuth
}

if ($AWS) {
    Configure-AWS
}

if ($Azure) {
    Configure-Azure
}

if ($GCP) {
    Configure-GCP
}

if ($AWS -or $Azure -or $GCP) {
    Write-Host ""
    Write-Host "=== Configuration Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run the following to check your authentication status:" -ForegroundColor Yellow
    Write-Host ".\configure-cloud-auth.ps1 -Status" -ForegroundColor Gray
    Write-Host ""
    Write-Host "After all configurations are complete, you can run:" -ForegroundColor Yellow
    Write-Host ".\multicloud.ps1" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
