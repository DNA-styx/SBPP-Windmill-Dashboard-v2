@echo off
REM SBPP-Windmill-Dashboard-v2 - Tailwind build (v2.0.1)
REM Location: SBPP-Windmill-Dashboard-v2\src\build.cmd
REM Run from the src folder. Produces ..\css\windmill.css (minified).
cd /d "%~dp0"
tailwindcss.exe -i input.css -o ..\css\windmill.css --minify
