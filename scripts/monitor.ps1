# Docker Monitoring Script - Track Growth Over Time

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              Docker Resource Monitoring                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. Container stats
Write-Host "📊 CONTAINER RESOURCE USAGE" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# 2. Image sizes
Write-Host "`n📦 IMAGE SIZES" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# 3. Volume info
Write-Host "`n💾 VOLUMES" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
docker volume ls

# 4. Overall system
Write-Host "`n🖥️  SYSTEM OVERVIEW" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
docker system df

Write-Host "`n💡 Recommendations:" -ForegroundColor Yellow
Write-Host "  • Run .\scripts\cleanup.ps1 if disk usage is high" -ForegroundColor Gray
Write-Host "  • Monitor regularly to prevent bloat" -ForegroundColor Gray
Write-Host "  • Remove old/unused images periodically" -ForegroundColor Gray
Write-Host "`n"
