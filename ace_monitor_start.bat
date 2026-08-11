@echo off
echo ==========================================
echo   ACE Monitor - Starting...
echo   Log file: ace_monitor.log
echo   Press Ctrl+C to stop
echo ==========================================
powershell -ExecutionPolicy Bypass -File "%~dp0ace_monitor.ps1"
pause
