@echo off

set project_name=Merger

set love_exe_path=%~dp0..\.vscode\love2d
::echo %lua_exe_path%

set project_entry_path=%~dp0%project_name%
::echo %project_entry_path%

cd %love_exe_path%

@lovec "%project_entry_path%"

::pause
