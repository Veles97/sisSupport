@echo off
chcp 65001 > nul

:: Шаг 1: Очистка экрана и вывод информационной карточки
cls
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '        [⚙] PC Setup Assistant              ' -ForegroundColor Cyan"
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '[➜] Программа: hwinfo' -ForegroundColor Blue"
powershell -Command "Write-Host '[➜] Назначение: Проверка ПК' -ForegroundColor DarkGray"
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
set "DEFAULT_PATH=C:\Tools\health_soft\hwinfo"

:: Шаг 4: Запрос пути у пользователя и создание папки
powershell -Command "Write-Host '[➜] Введите путь для установки (Enter = по умолчанию):' -ForegroundColor Yellow"
powershell -Command "Write-Host 'Путь по умолчанию: %DEFAULT_PATH%' -ForegroundColor DarkGray"
set "USER_PATH="
set /p "USER_PATH=> "
if "%USER_PATH%"=="" set "USER_PATH=%DEFAULT_PATH%"

powershell -Command "Write-Host '[⚙] Проверка и подготовка директории...' -ForegroundColor DarkGray"
powershell -Command "if (!(Test-Path '%USER_PATH%')) { New-Item -ItemType Directory -Force -Path '%USER_PATH%' | Out-Null }"
echo.

:: Шаг 5: Установка через winget
powershell -Command "Write-Host '[⚙] Скачивание и установка hwinfo через winget...' -ForegroundColor Yellow"
winget install -e --id REALiX.HWiNFO --location "%USER_PATH%" --silent --accept-package-agreements --accept-source-agreements
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[✗] Ошибка: Сбой установки через winget!' -ForegroundColor Red"
    pause > nul
    exit /b
)
powershell -Command "Write-Host '[✓] Установка успешно выполнена.' -ForegroundColor Green"
echo.

:: Шаг 6: Успех, открытие папки и выход
powershell -Command "Write-Host '[✓] Модуль hwinfo успешно установлен!' -ForegroundColor Green"
explorer "%USER_PATH%"
exit /b