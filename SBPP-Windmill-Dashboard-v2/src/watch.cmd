@echo off
REM SBPP-Windmill-Dashboard-v2 - Tailwind watch (v2.0.1)
REM Location: SBPP-Windmill-Dashboard-v2\src\watch.cmd
REM Leave running while editing; rebuilds ..\css\windmill.css on each save.
cd /d "%~dp0"
tailwindcss.exe -i input.css -o ..\css\windmill.css --watch
