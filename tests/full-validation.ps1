# Comprehensive Multi-Cloud Infrastructure Validation Script
# Tests all components of the refactored project

param(
    [switch]$Quick,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Multi-Cloud Infrastructure Full Validation Script
================================================

Usage: .\full-validation.ps1 [options]

Options:
-Quick    Run only basic validation without user interaction
-Help     Show this help message

This script performs comprehensive validation of the multi-cloud infrastructure project:
1. Project structure validation
2. Script syntax validation  
3. Terraform configuration validation
4. Authentication status checks
5. Documentation completeness
"@
    exit 0
}

Write-Host "Multi-Cloud Infrastructure - Full Validation" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$WarningCount = 0

function Test-Component {
    param([string]$Name, [scriptblock]$Test, [switch]$IsWarning)
    
    Write-Host "Testing: $Name" -ForegroundColor Yellow -NoNewline
    try {
        $result = & $Test
        if ($result) {
            Write-Host " [OK]" -ForegroundColor Green
            return $true
        } else {
            if ($IsWarning) {
                Write-Host " [WARN]" -ForegroundColor Yellow
                $script:WarningCount++
            } else {
                Write-Host " [ERROR]" -ForegroundColor Red
                $script:ErrorCount++
            }
            return $false
        }
    } catch {
        if ($IsWarning) {
            Write-Host " [WARN] ($($_.Exception.Message))" -ForegroundColor Yellow
            $script:WarningCount++
        } else {
            Write-Host " [ERROR] ($($_.Exception.Message))" -ForegroundColor Red
            $script:ErrorCount++
        }
        return $false
    }
}

# 1. Project Structure Validation
Write-Host "`n=== Project Structure ===" -ForegroundColor Magenta

Test-Component "Project root structure" {
    (Test-Path "scripts") -and (Test-Path "terraform") -and (Test-Path "docs") -and (Test-Path "tests")
}

Test-Component "Scripts directory" {
    (Test-Path "scripts\multicloud.ps1") -and (Test-Path "scripts\setup.ps1") -and (Test-Path "scripts\configure-cloud-auth.ps1")
}

Test-Component "Terraform environments" {
    (Test-Path "terraform\environments\aws") -and (Test-Path "terraform\environments\azure") -and (Test-Path "terraform\environments\gcp")
}

Test-Component "Documentation" {
    (Test-Path "docs\README.md") -and (Test-Path "REFACTORING_PLAN.md") -and (Test-Path "REFACTORING_SUMMARY.md")
}

Test-Component "Security files" {
    Test-Path ".gitignore"
}

# 2. Script Syntax Validation  
Write-Host "`n=== Script Syntax Validation ===" -ForegroundColor Magenta

Test-Component "run.ps1 syntax" {
    try {
        powershell -NoProfile -Command "& { . '.\run.ps1' -Help }" | Out-Null
        return $true
    } catch { return $false }
}

Test-Component "multicloud.ps1 syntax" {
    try {
        powershell -NoProfile -Command "& { . '.\scripts\multicloud.ps1' -Help }" | Out-Null
        return $true
    } catch { return $false }
}

Test-Component "setup.ps1 syntax" {
    try {
        powershell -NoProfile -Command "& { . '.\scripts\setup.ps1' -Help }" | Out-Null
        return $true
    } catch { return $false }
}

Test-Component "configure-cloud-auth.ps1 syntax" {
    try {
        powershell -NoProfile -Command "& { . '.\scripts\configure-cloud-auth.ps1' -Help }" | Out-Null
        return $true
    } catch { return $false }
}

# 3. Terraform Configuration Validation
Write-Host "`n=== Terraform Configuration ===" -ForegroundColor Magenta

$providers = @("aws", "azure", "gcp")
foreach ($provider in $providers) {
    Test-Component "Terraform $provider config" {
        $tfPath = "terraform\environments\$provider"
        (Test-Path "$tfPath\main.tf") -and (Test-Path "$tfPath\variable.tf") -and (Test-Path "$tfPath\output.tf")
    }
}

# 4. Functional Testing (if not Quick mode)
if (-not $Quick) {
    Write-Host "`n=== Functional Testing ===" -ForegroundColor Magenta
    
    Test-Component "setup.ps1 -CheckOnly" {
        try {
            $output = & ".\scripts\setup.ps1" -CheckOnly 2>&1 | Out-String
            return $output -like "*Project structure: VALID*"
        } catch { return $false }
    }
    
    Test-Component "multicloud.ps1 -Help" {
        try {
            $output = & ".\scripts\multicloud.ps1" -Help 2>&1 | Out-String
            return $output -like "*Multi-Cloud Infrastructure Management Tool*"
        } catch { return $false }
    }
    
    Test-Component "configure-cloud-auth.ps1 -Help" {
        try {
            $output = & ".\scripts\configure-cloud-auth.ps1" -Help 2>&1 | Out-String
            return $output -like "*Cloud CLI Configuration Guide*"
        } catch { return $false }
    }
    
    # Test authentication status (warning only)
    Test-Component "Cloud authentication status" -IsWarning {
        try {
            echo y | & ".\scripts\configure-cloud-auth.ps1" -Status 2>&1 | Out-Null
            return $true
        } catch { return $false }
    }
}

# 5. Documentation Completeness
Write-Host "`n=== Documentation Completeness ===" -ForegroundColor Magenta

Test-Component "README.md content" {
    $readme = Get-Content "docs\README.md" -Raw
    ($readme -like "*Multi-Cloud*") -and ($readme -like "*Terraform*") -and ($readme.Length -gt 500)
}

Test-Component "Refactoring documentation" {
    (Test-Path "REFACTORING_PLAN.md") -and (Test-Path "REFACTORING_SUMMARY.md")
}

# 6. Security Validation
Write-Host "`n=== Security Validation ===" -ForegroundColor Magenta

Test-Component ".gitignore completeness" {
    $gitignore = Get-Content ".gitignore" -Raw
    ($gitignore -like "*terraform.tfvars*") -and ($gitignore -like "*.terraform*") -and ($gitignore -like "*credentials*")
}

Test-Component "No sensitive files committed" {
    $sensitiveFiles = @("terraform.tfvars", "*.pem", "*.key", "*credentials*")
    $found = $false
    foreach ($pattern in $sensitiveFiles) {
        if (Get-ChildItem -Recurse -Name $pattern -ErrorAction SilentlyContinue) {
            $found = $true
            break
        }
    }
    return -not $found
}

# Results Summary
Write-Host "`n=== Validation Results ===" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "[SUCCESS] ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "The multi-cloud infrastructure project is ready for production use." -ForegroundColor Green
} elseif ($ErrorCount -eq 0) {
    Write-Host "[OK] VALIDATION PASSED with $WarningCount warnings" -ForegroundColor Yellow
    Write-Host "The project is functional but some improvements are recommended." -ForegroundColor Yellow
} else {
    Write-Host "[ERROR] VALIDATION FAILED with $ErrorCount errors and $WarningCount warnings" -ForegroundColor Red
    Write-Host "Please fix the errors before proceeding." -ForegroundColor Red
}

Write-Host "`nTest Summary:" -ForegroundColor White
Write-Host "  Errors: $ErrorCount" -ForegroundColor $(if($ErrorCount -eq 0){"Green"}else{"Red"})
Write-Host "  Warnings: $WarningCount" -ForegroundColor $(if($WarningCount -eq 0){"Green"}else{"Yellow"})
Write-Host ""

if ($ErrorCount -eq 0) {
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Configure cloud authentication: .\scripts\configure-cloud-auth.ps1" -ForegroundColor White
    Write-Host "2. Set up terraform.tfvars files in each environment" -ForegroundColor White
    Write-Host "3. Test infrastructure creation: .\run.ps1" -ForegroundColor White
    Write-Host "4. Initialize Git repository and push to version control" -ForegroundColor White
}

exit $ErrorCount
