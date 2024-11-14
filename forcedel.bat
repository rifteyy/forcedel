@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (
	echo=
	echo=ForceDel - https://github.com/rifteyy/forcedel
	echo=Usage: %~nx0 "file path" ^<switches^>
	echo=
	echo=/q    Runs fully quiet, no console printing unless error has occured
	echo=/c    Automatically confirms you are aware that the action is irreversible
	echo=/sl   Skips check for process using the file
	exit /b 0
)
	
2>nul >nul "%windir%\System32\net.exe" session || (
	echo=ERROR: No admin permissions. Re-run console as admin and try again.
	exit /b 1
)
for %%A in (%*) do (
	if "%%A"=="/q" set "quiet=true"
	if "%%A"=="/c" set "confirm=true"
	if "%%A"=="/sl" set "skiplock=true"
)
if not exist "%~1" (
	echo=ERROR: File does not exist.
	exit /b 1
)
if not "!confirm!"=="true" (
	"%windir%\System32\choice.exe" /C yn /M "WARNING: You are now attempting to delete file "%~1" and this action is not reversible. Are you sure?"
	if "!errorlevel!"=="2" exit /b 0
)
if not "!skiplock!"=="true" (
	if not "!quiet!"=="true" echo INFO: Looking for process locking the file "%~1"
	for /f "delims=" %%A in ('powershell.exe -Command "try { Get-Process | ForEach-Object { if ($_.Modules | Where-Object { $_.FileName -eq '%~1' }) { Write-Output $_.Id } } } catch { Write-Output 'Error accessing process modules.' }"') do (
		if not "%%A"=="Error accessing process modules." (
			>nul "%windir%\System32\Taskkill.exe" /PID %%A /F && (
				if not "!quiet!"=="true" echo=SUCCESS: PID %%A terminated.
			) || (
				echo=ERROR: PID %%A could not be terminated.
				exit /b 1
			)
		) else exit /b 1
	)
)
>nul "%windir%\System32\takeown.exe" /F "%~1" && (
	if not "!quiet!"=="true" echo=SUCCESS: Takeown.exe has exited with errorlevel 0
) || (
	echo=ERROR: Takeown.exe has failed.
	exit /b 1
)
>nul "%windir%\System32\icacls.exe" "%~1" /grant Everyone:F && (
	if not "!quiet!"=="true" echo=SUCCESS: Icacls.exe has exited with errorlevel 0
) || (
	echo=ERROR: Icacls.exe has failed.
	exit /b 1
)
del /f "%~1" && (
	if not exist "%~1" (
		if not "!quiet!"=="true" echo=SUCCESS: File was successfully deleted
	) else (
		echo=ERROR: File could not be deleted.
		exit /b 1
	)
) || (
	if exist "%~1" (
		echo=ERROR: File could not be deleted.
		if "!skiplock!"=="true" echo=This could have been caused by using the "/sl" switch.
		exit /b 1
	)
)
exit /b 0