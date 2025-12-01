# Quick Start Script for CUET Hackathon

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CUET Hackathon - Docker Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "[1/4] Checking Docker..." -ForegroundColor Yellow
try {
    docker info > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker is running" -ForegroundColor Green
    } else {
        throw "Docker not running"
    }
} catch {
    Write-Host "✗ Docker Desktop is not running!" -ForegroundColor Red
    Write-Host "  Please start Docker Desktop and run this script again." -ForegroundColor Yellow
    exit 1
}

# Check if .env exists
Write-Host "[2/4] Checking environment file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ .env file exists" -ForegroundColor Green
} else {
    Write-Host "✗ .env file not found!" -ForegroundColor Red
    exit 1
}

# Ask user which environment to start
Write-Host "[3/4] Select environment:" -ForegroundColor Yellow
Write-Host "  1. Development (with hot reload)" -ForegroundColor Cyan
Write-Host "  2. Production (optimized)" -ForegroundColor Cyan
$choice = Read-Host "Enter choice (1 or 2)"

if ($choice -eq "2") {
    $composeFile = "docker/compose.production.yaml"
    $envName = "Production"
} else {
    $composeFile = "docker/compose.development.yaml"
    $envName = "Development"
}

# Start services
Write-Host "[4/4] Starting $envName environment..." -ForegroundColor Yellow
Write-Host "This may take a few minutes on first run..." -ForegroundColor Gray
docker compose -f $composeFile up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ Setup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Services started:" -ForegroundColor Cyan
    Write-Host "  • Gateway:  http://localhost:5921" -ForegroundColor White
    Write-Host "  • Backend:  Private network only" -ForegroundColor White
    Write-Host "  • MongoDB:  Private network only" -ForegroundColor White
    Write-Host ""
    Write-Host "Test endpoints:" -ForegroundColor Cyan
    Write-Host "  curl http://localhost:5921/health" -ForegroundColor Gray
    Write-Host "  curl http://localhost:5921/api/health" -ForegroundColor Gray
    Write-Host ""
    Write-Host "View logs:" -ForegroundColor Cyan
    Write-Host "  docker compose -f $composeFile logs -f" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Stop services:" -ForegroundColor Cyan
    Write-Host "  docker compose -f $composeFile down" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "✗ Failed to start services" -ForegroundColor Red
    Write-Host "Check the logs above for errors" -ForegroundColor Yellow
    exit 1
}
