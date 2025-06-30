# Multi-Cloud Infrastructure Validation Script
# =============================================
# Validates project structure and configurations

param(
    [switch]$Detailed,
    [string]$Provider = "all"
)

Write-Host "🔍 Multi-Cloud Infrastructure Validation" -ForegroundColor Cyan
Write-Host "=" * 45 -ForegroundColor Cyan
Write-Host ""

$validationResults = @{
    "Structure" = $false
    "AWS" = $false
    "Azure" = $false
    "GCP" = $false
    "Scripts" = $false
    "Authentication" = $false
}

# Function to validate project structure
function Test-ProjectStructure {
    Write-Host "📁 Validating project structure..." -ForegroundColor Yellow
    
    $requiredPaths = @(
        "scripts\multicloud.ps1",
        "scripts\setup.ps1", 
        "scripts\install-cloud-tools.ps1",
        "scripts\configure-cloud-auth.ps1",
        "terraform\environments\aws",
        "terraform\environments\azure", 
        "terraform\environments\gcp",
        "docs",
        "tests",
        ".gitignore"
    )
    
    $missing = @()
    $present = @()
    
    foreach ($path in $requiredPaths) {
        if (Test-Path $path) {
            $present += $path
            if ($Detailed) {
                Write-Host "  ✅ $path" -ForegroundColor Green
            }
        } else {
            $missing += $path
            Write-Host "  ❌ $path" -ForegroundColor Red
        }
    }
    
    if ($missing.Count -eq 0) {
        Write-Host "  ✅ Project structure validation: PASSED" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ Project structure validation: FAILED" -ForegroundColor Red
        Write-Host "    Missing $($missing.Count) required paths" -ForegroundColor Yellow
        return $false
    }
}

# Function to validate terraform configuration
function Test-TerraformConfig {
    param([string]$Provider)
    
    Write-Host "🔧 Validating $($Provider.ToUpper()) Terraform configuration..." -ForegroundColor Yellow
    
    $providerPath = "terraform\environments\$Provider"
    if (-not (Test-Path $providerPath)) {
        Write-Host "  ❌ Provider directory not found: $providerPath" -ForegroundColor Red
        return $false
    }
    
    # Check required files
    $requiredFiles = @("main.tf", "variables.tf", "outputs.tf", "terraform.tfvars.example")
    $issues = @()
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $providerPath $file
        if (Test-Path $filePath) {
            if ($Detailed) {
                Write-Host "  ✅ $file" -ForegroundColor Green
            }
        } else {
            $issues += $file
            Write-Host "  ❌ Missing: $file" -ForegroundColor Red
        }
    }
    
    # Check for terraform.tfvars
    $tfvarsPath = Join-Path $providerPath "terraform.tfvars"
    if (Test-Path $tfvarsPath) {
        if ($Detailed) {
            Write-Host "  ✅ terraform.tfvars (configured)" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⚠️  terraform.tfvars not found (will use defaults)" -ForegroundColor Yellow
    }
    
    # Try terraform init to validate configuration
    $originalLocation = Get-Location
    try {
        Set-Location $providerPath
        $initResult = terraform init -backend=false 2>&1
        if ($LASTEXITCODE -eq 0) {
            if ($Detailed) {
                Write-Host "  ✅ Terraform syntax validation: PASSED" -ForegroundColor Green
            }
        } else {
            Write-Host "  ❌ Terraform syntax validation: FAILED" -ForegroundColor Red
            if ($Detailed) {
                Write-Host "    Error: $initResult" -ForegroundColor Gray
            }
            $issues += "Terraform syntax errors"
        }
    } catch {
        Write-Host "  ⚠️  Could not validate Terraform syntax (terraform not found)" -ForegroundColor Yellow
    } finally {
        Set-Location $originalLocation
    }
    
    if ($issues.Count -eq 0) {
        Write-Host "  ✅ $($Provider.ToUpper()) validation: PASSED" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ $($Provider.ToUpper()) validation: FAILED ($($issues.Count) issues)" -ForegroundColor Red
        return $false
    }
}

# Function to test authentication
function Test-CloudAuthentication {
    Write-Host "🔐 Testing cloud provider authentication..." -ForegroundColor Yellow
    
    $authResults = @{}
    
    # AWS
    try {
        $awsResult = aws sts get-caller-identity 2>$null
        if ($LASTEXITCODE -eq 0) {
            $authResults["AWS"] = $true
            if ($Detailed) {
                Write-Host "  ✅ AWS authentication: CONFIGURED" -ForegroundColor Green
            }
        } else {
            $authResults["AWS"] = $false
            Write-Host "  ❌ AWS authentication: NOT CONFIGURED" -ForegroundColor Red
        }
    } catch {
        $authResults["AWS"] = $false
        Write-Host "  ⚠️  AWS CLI not found" -ForegroundColor Yellow
    }
    
    # Azure
    try {
        $azureResult = az account show 2>$null
        if ($LASTEXITCODE -eq 0) {
            $authResults["Azure"] = $true
            if ($Detailed) {
                Write-Host "  ✅ Azure authentication: CONFIGURED" -ForegroundColor Green
            }
        } else {
            $authResults["Azure"] = $false
            Write-Host "  ❌ Azure authentication: NOT CONFIGURED" -ForegroundColor Red
        }
    } catch {
        $authResults["Azure"] = $false
        Write-Host "  ⚠️  Azure CLI not found" -ForegroundColor Yellow
    }
    
    # GCP
    try {
        $gcpResult = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
        if ($LASTEXITCODE -eq 0 -and $gcpResult.Trim() -ne "") {
            $authResults["GCP"] = $true
            if ($Detailed) {
                Write-Host "  ✅ GCP authentication: CONFIGURED" -ForegroundColor Green
            }
        } else {
            $authResults["GCP"] = $false
            Write-Host "  ❌ GCP authentication: NOT CONFIGURED" -ForegroundColor Red
        }
    } catch {
        $authResults["GCP"] = $false
        Write-Host "  ⚠️  GCP CLI not found" -ForegroundColor Yellow
    }
    
    return $authResults
}

# Main validation execution
try {
    # Validate project structure
    $validationResults["Structure"] = Test-ProjectStructure
    Write-Host ""
    
    # Validate individual providers or all
    $providers = @()
    if ($Provider -eq "all") {
        $providers = @("aws", "azure", "gcp")
    } else {
        $providers = @($Provider.ToLower())
    }
    
    foreach ($prov in $providers) {
        $validationResults[$prov.ToUpper()] = Test-TerraformConfig $prov
        Write-Host ""
    }
    
    # Test authentication
    $authResults = Test-CloudAuthentication
    $validationResults["Authentication"] = ($authResults.Values -contains $true)
    
    # Summary
    Write-Host "📊 VALIDATION SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 21 -ForegroundColor Cyan
    
    $totalChecks = 0
    $passedChecks = 0
    
    foreach ($check in $validationResults.Keys) {
        $totalChecks++
        if ($validationResults[$check]) {
            $passedChecks++
            Write-Host "✅ $check" -ForegroundColor Green
        } else {
            Write-Host "❌ $check" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    $percentage = [math]::Round(($passedChecks / $totalChecks) * 100)
    if ($percentage -eq 100) {
        Write-Host "🎉 All validations passed! ($passedChecks/$totalChecks)" -ForegroundColor Green
        Write-Host "Your multi-cloud infrastructure is ready for deployment!" -ForegroundColor Green
    } elseif ($percentage -ge 80) {
        Write-Host "⚠️  Most validations passed ($passedChecks/$totalChecks - $percentage%)" -ForegroundColor Yellow
        Write-Host "Address the remaining issues before deployment." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Multiple validation failures ($passedChecks/$totalChecks - $percentage%)" -ForegroundColor Red
        Write-Host "Please fix the issues before proceeding." -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Validation script error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
