Set-Location HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell
New-Item ModuleLogging,ModuleLogging\ModuleNames,ScriptBlockLogging
Set-ItemProperty ModuleLogging -Name EnableModuleLogging -Value 1
Set-ItemProperty .\ModuleLogging\ModuleNames -Name * -Value *
Set-ItemProperty ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1
