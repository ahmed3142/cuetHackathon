# Docker Cleanup Script - Manage Growth Over Time

param(
    [switch]$DryRun,
    [switch]$All
)

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              Docker Cleanup & Maintenance Script                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made`n" -ForegroundColor Yellow
}

# 1. Show current disk usage
Write-Host "[1/6] Checking Docker disk usage..." -ForegroundColor Yellow
docker system df

Write-Host "`n[2/6] Analyzing image sizes..." -ForegroundColor Yellow
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | Select-Object -First 20

# 2. Remove stopped containers
Write-Host "`n[3/6] Checking for stopped containers..." -ForegroundColor Yellow
$stoppedContainers = docker ps -a -q -f status=exited
if ($stoppedContainers) {
    Write-Host "Found $($stoppedContainers.Count) stopped containers" -ForegroundColor Gray
    if (-not $DryRun) {
        docker container prune -f
        Write-Host "✓ Removed stopped containers" -ForegroundColor Green
    }
} else {
    Write-Host "✓ No stopped containers" -ForegroundColor Green
}

# 3. Remove dangling images
Write-Host "`n[4/6] Checking for dangling images..." -ForegroundColor Yellow
$danglingImages = docker images -f "dangling=true" -q
if ($danglingImages) {
    Write-Host "Found $($danglingImages.Count) dangling images" -ForegroundColor Gray
    if (-not $DryRun) {
        docker image prune -f
        Write-Host "✓ Removed dangling images" -ForegroundColor Green
    }
} else {
    Write-Host "✓ No dangling images" -ForegroundColor Green
}

# 4. Remove unused volumes
Write-Host "`n[5/6] Checking for unused volumes..." -ForegroundColor Yellow
if ($All) {
    if (-not $DryRun) {
        Write-Host "⚠️  WARNING: This will remove ALL unused volumes!" -ForegroundColor Red
        $confirm = Read-Host "Continue? (yes/no)"
        if ($confirm -eq "yes") {
            docker volume prune -f
            Write-Host "✓ Removed unused volumes" -ForegroundColor Green
        } else {
            Write-Host "Skipped volume cleanup" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "Skipped (use -All to remove unused volumes)" -ForegroundColor Gray
}

# 5. Remove build cache
Write-Host "`n[6/6] Checking build cache..." -ForegroundColor Yellow
if ($All) {
    if (-not $DryRun) {
        docker builder prune -f
        Write-Host "✓ Removed build cache" -ForegroundColor Green
    }
} else {
    Write-Host "Skipped (use -All to remove build cache)" -ForegroundColor Gray
}

# Final summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Final disk usage:" -ForegroundColor Cyan
docker system df

Write-Host "`n💡 Tips:" -ForegroundColor Yellow
Write-Host "  • Run with -DryRun to preview changes" -ForegroundColor Gray
Write-Host "  • Run with -All for aggressive cleanup" -ForegroundColor Gray
Write-Host "  • Run regularly to prevent disk bloat" -ForegroundColor Gray
Write-Host "`n"
