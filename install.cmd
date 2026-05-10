@echo off

REM Install paper-reader-skill to Claude Code

set SKILL_DIR=%USERPROFILE%\.claude\skills\paper-reader
set COMMAND_FILE=%USERPROFILE%\.claude\commands\paper-reader.md
set CURRENT_DIR=%~dp0

echo Installing paper-reader skill...

if not exist "%SKILL_DIR%" mkdir "%SKILL_DIR%"

xcopy /E /Y "%CURRENT_DIR%" "%SKILL_DIR%\"

echo.
echo Installed to %SKILL_DIR%

REM Install slash command
if not exist "%USERPROFILE%\.claude\commands" mkdir "%USERPROFILE%\.claude\commands"
copy /Y "%CURRENT_DIR%.claude\commands\paper-reader.md" "%COMMAND_FILE%"
echo Installed slash command: /paper-reader
echo.
echo Usage:
echo   /paper-reader ^<论文链接或文件路径^>
echo   or share a paper and say '学习笔记'