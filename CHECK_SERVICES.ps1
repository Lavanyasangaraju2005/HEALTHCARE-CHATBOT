# Healthcare Chat Assistant - Connection Diagnostics
# This script checks if all services are running and accessible

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Healthcare Chat Assistant - Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to test port connectivity
function Test-Port {
    param(
        [string]$Host,
        [int]$Port,
        [string]$ServiceName
    )
    
    Write-Host "Testing $ServiceName ($Host`:$Port)..." -ForegroundColor Yellow
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect($Host, $Port)
        if ($connection.Connected) {
            Write-Host "✓ $ServiceName is RUNNING" -ForegroundColor Green
            $connection.Close()
            return $true
        }
    } catch {
        Write-Host "✗ $ServiceName is NOT RUNNING" -ForegroundColor Red
        return $false
    }
}

# Check MySQL
Write-Host ""
Write-Host "--- Database Check ---" -ForegroundColor Magenta
$mysqlService = Get-Service MySQL80 -ErrorAction SilentlyContinue
if ($mysqlService) {
    if ($mysqlService.Status -eq 'Running') {
        Write-Host "✓ MySQL Service is RUNNING" -ForegroundColor Green
    } else {
        Write-Host "✗ MySQL Service is STOPPED" -ForegroundColor Red
        Write-Host "  Start with: Start-Service MySQL80" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ MySQL Service not found - it may not be installed" -ForegroundColor Yellow
}

# Test Backend
Write-Host ""
Write-Host "--- Backend Check ---" -ForegroundColor Magenta
$backendRunning = Test-Port "localhost" 8080 "Backend API"

# Test Ollama
Write-Host ""
Write-Host "--- AI Service Check (Ollama) ---" -ForegroundColor Magenta
$ollamaRunning = Test-Port "localhost" 11434 "Ollama Service"

if ($ollamaRunning) {
    try {
        Write-Host "Checking available Ollama models..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -ErrorAction SilentlyContinue
        $models = $response.Content | ConvertFrom-Json
        Write-Host "Available models: $($models.models.Count)" -ForegroundColor Green
        if ($models.models.Count -gt 0) {
            Write-Host "  Models:" -ForegroundColor Green
            $models.models.name | ForEach-Object { Write-Host "    - $_" -ForegroundColor Green }
        } else {
            Write-Host "  No models found! Download gemma:2b with: ollama pull gemma:2b" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error checking models: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Test Frontend
Write-Host ""
Write-Host "--- Frontend Check ---" -ForegroundColor Magenta
$frontendRunning = Test-Port "localhost" 5173 "Frontend Dev Server"

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

if ($mysqlService.Status -eq 'Running') {
    Write-Host "✓ Database" -ForegroundColor Green
} else {
    Write-Host "✗ Database - Start MySQL Service" -ForegroundColor Red
    $allGood = $false
}

if ($backendRunning) {
    Write-Host "✓ Backend" -ForegroundColor Green
} else {
    Write-Host "✗ Backend - Run: cd backend; mvn spring-boot:run" -ForegroundColor Red
    $allGood = $false
}

if ($ollamaRunning) {
    Write-Host "✓ Ollama" -ForegroundColor Green
} else {
    Write-Host "✗ Ollama - Run: ollama serve" -ForegroundColor Red
    $allGood = $false
}

if ($frontendRunning) {
    Write-Host "✓ Frontend" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend - Run: cd frontend; npm run dev" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""
if ($allGood) {
    Write-Host "✓ All services are running!" -ForegroundColor Green
    Write-Host "Visit: http://localhost:5173" -ForegroundColor Green
} else {
    Write-Host "⚠ Some services are not running" -ForegroundColor Yellow
    Write-Host "Please start the missing services" -ForegroundColor Yellow
}

Write-Host ""
