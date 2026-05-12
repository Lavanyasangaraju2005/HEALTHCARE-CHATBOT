@echo off
REM Healthcare Chat Assistant - Complete Startup Script
REM This script starts MySQL, Ollama, Backend, and Frontend

echo ========================================
echo Healthcare Chat Assistant Startup
echo ========================================
echo.

REM Check if running as administrator
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' (
    echo WARNING: This script should be run as Administrator for MySQL service control
    echo Continuing anyway...
    echo.
)

REM Start MySQL
echo [1/4] Starting MySQL Service...
net start MySQL80 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ MySQL started successfully
) else (
    echo ✗ MySQL may already be running or failed to start
)
echo.

REM Show instructions
echo ========================================
echo IMPORTANT: Start the following in new terminals:
echo ========================================
echo.
echo [2/4] OLLAMA SERVICE (New Terminal):
echo   cd capstone
echo   ollama serve
echo.
echo [3/4] BACKEND SERVICE (New Terminal):
echo   cd capstone\backend
echo   mvn spring-boot:run
echo.
echo [4/4] FRONTEND SERVICE (New Terminal):
echo   cd capstone\frontend
echo   npm run dev
echo.
echo ========================================
echo VERIFY CONNECTIVITY:
echo ========================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:8080
echo Ollama:   http://localhost:11434
echo.
echo Check Ollama models available:
echo   curl http://localhost:11434/api/tags
echo.
echo If Ollama shows no models, download gemma:2b:
echo   ollama pull gemma:2b
echo.
pause
