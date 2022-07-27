@echo off
setlocal EnableDelayedExpansion

:Folder
set n=0
for /d %%a in (*) do (
	if exist "%%a\*.cbz" (
		set /a n+=1
		echo !n!. %%a
		set "list[!n!]=%%a"
	) else (
		set subFolder=
		for /d %%b in ("%%a\*") do (
			set subFolder=true
		)
		if defined subFolder (
			set /a n+=1
			echo !n!. %%a
			set "list[!n!]=%%a"
		)
	)
)
if !n!==0 (
	echo 1. Enable CBZ
	echo 2. Disable CBZ
	echo.
	call :Patch
) else (
	echo.
	call :SubFolder
)
exit /b %errorlevel%

:Patch
setlocal DisableDelayedExpansion
set /p o=Please choose the number of the desired operation: 
if %o%==1 (
	call :Enable
) else (
	if %o%==2 (
		call :Disable
	) else (
		goto :Patch
	)
)
pause
exit /b 0

:SubFolder
set /p p=Please choose the number of the desired folder: 
set /a i=p
if %i% gtr !n! (
	goto :SubFolder
) else (
	if %i% leq 0 (
		goto :SubFolder
	) else (
		echo.
		echo !list[%i%]!:
		cd "!list[%i%]!"
		goto :Folder
	)
)
exit /b 0

:Enable
set /p c=Do you want to delete the folders after conversion? [Y/N]: 
if /i not %c%==y (if /i not %c%==n (goto :Enable))
for /d %%i in (*) do (
if not exist "%%i.cbz" (
"%ProgramFiles%\7-Zip\7z.exe" a "%%i.zip" .\"%%i"\*.jpg .\"%%i"\*.png > nul
ren "%%i.zip" "%%i.cbz"
)
if /i %c%==y (rmdir /s /q "%%i")
echo %%i.cbz
)
exit /b 0

:Disable
set /p c=Do you want to delete CBZ files after conversion? [Y/N]: 
if /i not %c%==y (if /i not %c%==n (goto :Disable))
for %%i in (*.cbz) do (
if not exist "%%~ni" (
"%ProgramFiles%\7-Zip\7z.exe" e "%%i" -o"%%~ni" -y > nul
type nul > "%%~ni\.nomedia"
)
if /i %c%==y (del /s /q "%%i" > nul)
echo %%~ni
)
exit /b 0