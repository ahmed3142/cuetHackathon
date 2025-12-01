# Test Script for CUET Hackathon

Write-Host "
========================================" -ForegroundColor Cyan
Write-Host "  Testing E-Commerce Microservices" -ForegroundColor Cyan
Write-Host "========================================
" -ForegroundColor Cyan

$baseUrl = "http://localhost:5921"
$testsPassed = 0
$testsFailed = 0

# Test 1: Gateway Health
Write-Host "[1/5] Testing Gateway Health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/health" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Gateway is healthy" -ForegroundColor Green
        $testsPassed++
    } else {
        throw "Unexpected status code"
    }
} catch {
    Write-Host "  ✗ Gateway health check failed" -ForegroundColor Red
    $testsFailed++
}

# Test 2: Backend Health (through Gateway)
Write-Host "[2/5] Testing Backend Health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/health" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Backend is healthy" -ForegroundColor Green
        $testsPassed++
    } else {
        throw "Unexpected status code"
    }
} catch {
    Write-Host "  ✗ Backend health check failed" -ForegroundColor Red
    $testsFailed++
}

# Test 3: Create Product
Write-Host "[3/5] Testing Product Creation..." -ForegroundColor Yellow
try {
    $body = @{
        name = "Test Product"
        price = 99.99
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/products" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    if ($response.StatusCode -eq 201) {
        Write-Host "  ✓ Product created successfully" -ForegroundColor Green
        $testsPassed++
    } else {
        throw "Unexpected status code"
    }
} catch {
    Write-Host "  ✗ Product creation failed: $_" -ForegroundColor Red
    $testsFailed++
}

# Test 4: Get Products
Write-Host "[4/5] Testing Product Listing..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/products" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $products = $response.Content | ConvertFrom-Json
        Write-Host "  ✓ Retrieved $($products.Count) product(s)" -ForegroundColor Green
        $testsPassed++
    } else {
        throw "Unexpected status code"
    }
} catch {
    Write-Host "  ✗ Product listing failed" -ForegroundColor Red
    $testsFailed++
}

# Test 5: Security - Direct Backend Access (Should Fail)
Write-Host "[5/5] Testing Security (Backend Isolation)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3847/api/products" -Method GET -UseBasicParsing -TimeoutSec 5
    Write-Host "  ✗ Backend is exposed (security issue!)" -ForegroundColor Red
    $testsFailed++
} catch {
    Write-Host "  ✓ Backend is properly isolated" -ForegroundColor Green
    $testsPassed++
}

# Summary
Write-Host "
========================================" -ForegroundColor Cyan
Write-Host "  Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Passed: " -NoNewline -ForegroundColor White
Write-Host $testsPassed -ForegroundColor Green
Write-Host "  Failed: " -NoNewline -ForegroundColor White
if ($testsFailed -eq 0) {
    Write-Host $testsFailed -ForegroundColor Green
} else {
    Write-Host $testsFailed -ForegroundColor Red
}
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "🎉 All tests passed! Your setup is ready for the hackathon!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some tests failed. Please check the errors above." -ForegroundColor Yellow
}
Write-Host ""
