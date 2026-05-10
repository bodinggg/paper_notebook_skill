@echo off

REM Uninstall paper-reader-skill from Claude Code

set SKILL_DIR=%USERPROFILE%\.claude\skills\paper-reader
set COMMAND_FILE=%USERPROFILE%\.claude\commands\paper-reader.md

echo Uninstalling paper-reader skill...

if exist "%SKILL_DIR%" (
    rmdir /S /Q "%SKILL_DIR%"
    echo Uninstalled from %SKILL_DIR%
) else (
    echo Skill not found at %SKILL_DIR%
)

REM Remove slash command
if exist "%COMMAND_FILE%" (
    del /F /Q "%COMMAND_FILE%"
    echo Removed slash command: /paper-reader
)