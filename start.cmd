@echo off

start "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" http://localhost:3000/

python -m http.server 3000

