@echo off
chcp 65001 > nul

:: Шаг 1: Очистка экрана и вывод информационной карточки
cls
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '        [⚙] PC Setup Assistant              ' -ForegroundColor Cyan"
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '[➜] Программа: Happ Desktop' -ForegroundColor Blue"
powershell -Command "Write-Host '[➜] Назначение: Кроссплатформенный прокси-клиент' -ForegroundColor DarkGray"
echo.

:: Шаг 2: Проверка интернета
powershell -Command "Write-Host '[⚙] Проверка подключения к интернету...' -ForegroundColor Yellow"
ping -n 1 8.8.8.8 > nul
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[✗] Ошибка: Отсутствует подключение к сети!' -ForegroundColor Red"
    pause > nul
    exit /b
)
powershell -Command "Write-Host '[✓] Интернет доступен.' -ForegroundColor Green"
echo.

:: Шаг 3: Назначение пути по умолчанию
set "DEFAULT_PATH=C:\Tools\Network\Happ"

:: Шаг 4: Запрос пути у пользователя и создание папки
powershell -Command "Write-Host '[➜] Введите путь для установки (Enter = по умолчанию):' -ForegroundColor Yellow"
powershell -Command "Write-Host 'Путь по умолчанию: %DEFAULT_PATH%' -ForegroundColor DarkGray"
set "USER_PATH="
set /p "USER_PATH=> "
if "%USER_PATH%"=="" set "USER_PATH=%DEFAULT_PATH%"

powershell -Command "Write-Host '[⚙] Проверка и подготовка директории...' -ForegroundColor DarkGray"
powershell -Command "if (!(Test-Path '%USER_PATH%')) { New-Item -ItemType Directory -Force -Path '%USER_PATH%' | Out-Null }"
echo.

:: Шаг 5: Скачивание инсталлятора с GitHub
set "TEMP_FILE=%TEMP%\happ_setup.exe"
set "URL=https://github.com/Happ-proxy/happ-desktop/releases/latest/download/setup-Happ.x64.exe"
powershell -Command "Write-Host '[⚙] Скачивание Happ Desktop во временную папку...' -ForegroundColor Yellow"
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%TEMP_FILE%'"
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[✗] Ошибка: Не удалось скачать установочный файл!' -ForegroundColor Red"
    pause > nul
    exit /b
)
powershell -Command "Write-Host '[✓] Скачивание завершено.' -ForegroundColor Green"
echo.

:: Шаг 6: Тихая установка
powershell -Command "Write-Host '[⚙] Выполнение тихой установки в ''%USER_PATH%''...' -ForegroundColor Yellow"
:: Happ собирается на базе Electron/NSIS, поэтому используем стандартные тихие ключи
start /wait "" "%TEMP_FILE%" /S /D="%USER_PATH%"
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[✗] Ошибка: Сбой в процессе установки!' -ForegroundColor Red"
    pause > nul
    exit /b
)
powershell -Command "Write-Host '[✓] Установка успешно выполнена.' -ForegroundColor Green"
echo.

:: Шаг 7: Удаление временных файлов
powershell -Command "Write-Host '[⚙] Очистка временных файлов...' -ForegroundColor DarkGray"
del /q "%TEMP_FILE%"
echo.

:: Шаг 8: Успех, открытие папки и выход
powershell -Command "Write-Host '[✓] Модуль Happ Desktop успешно установлен!' -ForegroundColor Green"
explorer "%USER_PATH%"
exit /b