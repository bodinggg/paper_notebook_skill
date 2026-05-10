@echo off

REM Install paper-reader-skill to Claude Code

set SKILL_DIR=%USERPROFILE%\.claude\skills\paper-reader
set CURRENT_DIR=%~dp0

echo Installing paper-reader skill...

if not exist "%SKILL_DIR%" mkdir "%SKILL_DIR%"

xcopy /E /Y "%CURRENT_DIR%" "%SKILL_DIR%\"

echo.
echo Installed to %SKILL_DIR%
echo.
echo Usage: Share a paper with Claude Code and say '学习笔记' or 'Heilmeier分析'