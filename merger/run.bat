@echo off

set love="%~dp0"../../.vscode/love2d
::echo %love%

set project="%~dp0\."
::echo %project%

cd %love%

@lovec %project%

::pause