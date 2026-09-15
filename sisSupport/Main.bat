@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =======================================================
:: Блок проверки и установки WinGet
:: =======================================================
where winget >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[⚙] WinGet не найден. Пробуем скачать с GitHub...' -ForegroundColor Yellow"

    :: Включаем TLS 1.2 и качаем (без скрытия ошибок)
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; " ^
        "$url = 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'; " ^
        "$file = \"$env:TEMP\winget.msixbundle\"; " ^
        "Write-Host '   -> Загрузка пакета...' -ForegroundColor DarkGray; " ^
        "Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing; " ^
        "Write-Host '   -> Установка пакета (может занять минуту)...' -ForegroundColor DarkGray; " ^
        "Add-AppxPackage -Path $file"

    :: Обновляем пути
    set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WindowsApps;%ProgramFiles%\WindowsApps"

    :: Проверка
    where winget >nul 2>&1
    if %errorlevel% equ 0 (
        powershell -Command "Write-Host '[✓] WinGet успешно установлен!' -ForegroundColor Green"
    ) else (
        powershell -Command "Write-Host '[!] WinGet не установился. Читайте красную ошибку выше.' -ForegroundColor Red"
    )
)
echo.

:: Определяем текущую директорию (там, где лежит main.bat)
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

:MainMenu
cls
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '        [⚙] PC Setup Assistant - Меню       ' -ForegroundColor Cyan"
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '[➜] Выберите категорию для установки:' -ForegroundColor Yellow"
echo.
powershell -Command "Write-Host '  [1] Повседневный софт (soft)' -ForegroundColor Green"
powershell -Command "Write-Host '  [2] Диагностика и система (health_soft)' -ForegroundColor Green"
powershell -Command "Write-Host '  [3] Сеть и обход блокировок (zapret)' -ForegroundColor Green"
powershell -Command "Write-Host '  [4] Разархиваторы (arhivator)' -ForegroundColor Green"
echo.
powershell -Command "Write-Host '  [0] Выход' -ForegroundColor DarkGray"
echo.

set "MENU_CHOICE="
set /p "MENU_CHOICE=> "

if "%MENU_CHOICE%"=="1" (set "CURRENT_FOLDER=soft" & goto :CategoryMenu)
if "%MENU_CHOICE%"=="2" (set "CURRENT_FOLDER=health_soft" & goto :CategoryMenu)
if "%MENU_CHOICE%"=="3" (set "CURRENT_FOLDER=zapret" & goto :CategoryMenu)
if "%MENU_CHOICE%"=="4" (set "CURRENT_FOLDER=arhivator" & goto :CategoryMenu)
if "%MENU_CHOICE%"=="0" exit /b

:: Если ввели что-то другое - возвращаемся в меню
goto :MainMenu


:CategoryMenu
cls
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '        [📁] Категория: %CURRENT_FOLDER%' -ForegroundColor Cyan"
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"

:: Проверка существования папки
if not exist "%BASE_DIR%\%CURRENT_FOLDER%" (
    powershell -Command "Write-Host '[✗] Ошибка: Папка %CURRENT_FOLDER% не найдена!' -ForegroundColor Red"
    powershell -Command "Write-Host 'Она должна лежать рядом с main.bat' -ForegroundColor DarkGray"
    pause > nul
    goto :MainMenu
)

:: Динамическое чтение всех .bat файлов в папке
set "idx=0"
for %%F in ("%BASE_DIR%\%CURRENT_FOLDER%\*.bat") do (
    set /a idx+=1
    set "FILE_PATH[!idx!]=%%~fF"
    set "FILE_NAME[!idx!]=%%~nxF"
)

:: Если батников нет
if %idx%==0 (
    powershell -Command "Write-Host '[!] В этой категории пока нет .bat файлов.' -ForegroundColor Yellow"
    echo.
    powershell -Command "Write-Host '  [0] Назад в главное меню' -ForegroundColor DarkGray"
    set /p "SUB_CHOICE=> "
    goto :MainMenu
)

powershell -Command "Write-Host '[➜] Доступные модули:' -ForegroundColor Yellow"
echo.
:: Вывод списка файлов
for /L %%i in (1, 1, %idx%) do (
    powershell -Command "Write-Host '  [%%i] !FILE_NAME[%%i]!' -ForegroundColor Green"
)
echo.
powershell -Command "Write-Host '  [0] Назад в главное меню' -ForegroundColor DarkGray"
echo.

set "SUB_CHOICE="
set /p "SUB_CHOICE=> "

if "%SUB_CHOICE%"=="0" goto :MainMenu

:: Проверка правильности выбранного номера
if defined FILE_PATH[%SUB_CHOICE%] (
    cls
    powershell -Command "Write-Host '[⚙] Запуск модуля: !FILE_NAME[%SUB_CHOICE%]!...' -ForegroundColor Blue"
    echo.
    
    :: Вызов стороннего скрипта (call возвращает управление обратно в main.bat после exit /b)
    call "!FILE_PATH[%SUB_CHOICE%]!"
    
    echo.
    powershell -Command "Write-Host '[✓] Работа модуля завершена. Нажмите любую клавишу для возврата...' -ForegroundColor DarkGray"
    pause > nul
    goto :CategoryMenu
) else (
    powershell -Command "Write-Host '[✗] Неверный выбор! Попробуйте снова.' -ForegroundColor Red"
    timeout /t 2 > nul
    goto :CategoryMenu
)