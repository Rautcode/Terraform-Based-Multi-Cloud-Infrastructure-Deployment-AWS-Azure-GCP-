# Multi-Cloud Infrastructure Validation Script
# Simple version for testing refactored structure

Write-Host "Validating Multi-Cloud Infrastructure" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Test project structure
Write-Host "Testing project structure..." -ForegroundColor Yellow

$requiredPaths = @(
    "scripts\multicloud.ps1",
    "scripts\setup.ps1",
    "terraform\environments\aws",
    "terraform\environments\azure", 
    "terraform\environments\gcp",
    "docs",
    ".gitignore"
)

$allGood = $true

foreach ($path in $requiredPaths) {
    if (Test-Path $path) {
        Write-Host "  ✅ $path" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $path" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""

if ($allGood) {
    Write-Host "🎉 Project structure validation: PASSED" -ForegroundColor Green
    Write-Host "The refactored multi-cloud infrastructure is ready!" -ForegroundColor Green
} else {
    Write-Host "❌ Project structure validation: FAILED" -ForegroundColor Red
    Write-Host "Some required files or directories are missing." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: .\run.ps1 to start the application" -ForegroundColor White
Write-Host "2. Configure authentication: .\scripts\configure-cloud-auth.ps1" -ForegroundColor White
Write-Host "3. Set up terraform.tfvars files in each environment" -ForegroundColor White
