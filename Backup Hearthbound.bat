@echo off
rem Double-click after closing the game to back up Hearthbound's data.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Backup-Hearthbound.ps1"
