@echo off

REM Uninstall paper-reader-skill from Claude Code

set SKILL_DIR=%USERPROFILE%\.claude\skills\paper-reader

echo Uninstalling paper-reader skill...

if exist "%SKILL_DIR%" (
    rmdir /S /Q "%SKILL_DIR%"
    echo Uninstalled from %SKILL_DIR%
) else (
    echo Skill not found at %SKILL_DIR%
)