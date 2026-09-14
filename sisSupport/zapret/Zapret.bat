@echo off
chcp 65001 > nul

:: Шаг 1: Очистка экрана и вывод информационной карточки
cls
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '        [⚙] PC Setup Assistant              ' -ForegroundColor Cyan"
powershell -Command "Write-Host '============================================' -ForegroundColor Cyan"
powershell -Command "Write-Host '[➜] Программа: Zapret (Discord / YouTube)' -ForegroundColor Blue"
powershell -Command "Write-Host '[➜] Назначение: Обход блокировок и замедления сервисов' -ForegroundColor DarkGray"
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
set "DEFAULT_PATH=C:\Tools\Network\Zapret"

:: Шаг 4: Запрос пути у пользователя и создание папки
powershell -Command "Write-Host '[➜] Введите путь для установки (Enter = по умолчанию):' -ForegroundColor Yellow"
powershell -Command "Write-Host 'Путь по умолчанию: %DEFAULT_PATH%' -ForegroundColor DarkGray"
set "USER_PATH="
set /p "USER_PATH=> "
if "%USER_PATH%"=="" set "USER_PATH=%DEFAULT_PATH%"

powershell -Command "Write-Host '[⚙] Проверка и подготовка директории...' -ForegroundColor DarkGray"
powershell -Command "if (!(Test-Path '%USER_PATH%')) { New-Item -ItemType Directory -Force -Path '%USER_PATH%' | Out-Null }"
echo.

:: Шаг 5: Скачивание архива с GitHub
set "TEMP_ZIP=%TEMP%\zapret_master.zip"
set "URL=https://github.com/Flowseal/zapret-discord-youtube/archive/refs/heads/main.zip"
powershell -Command "Write-Host '[⚙] Скачивание архива Zapret с GitHub...' -ForegroundColor Yellow"
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%TEMP_ZIP%'"
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[✗] Ошибка: Не удалось скачать архив с GitHub!' -ForegroundColor Red"
    pause > nul
    exit /b
)
powershell -Command "Write-Host '[✓] Скачивание завершено.' -ForegroundColor Green"
echo.

:: Шаг 6: Распаковка архива
powershell -Command "Write-Host '[⚙] Распаковка файлов в целевую директорию...' -ForegroundColor Yellow"
:: Параметр -Force перезапишет файлы, если они уже были в папке
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%USER_PATH%' -Force"
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[✗] Ошибка: Не удалось распаковать архив!' -ForegroundColor Red"
    pause > nul
    exit /b
)
powershell -Command "Write-Host '[✓] Распаковка успешно выполнена.' -ForegroundColor Green"
echo.

:: Шаг 7: Удаление временного архива
powershell -Command "Write-Host '[⚙] Очистка временных файлов...' -ForegroundColor DarkGray"
del /q "%TEMP_ZIP%"
echo.

:: Шаг 8: Успех, открытие папки и выход
powershell -Command "Write-Host '[✓] Модуль Zapret успешно загружен и распакован!' -ForegroundColor Green"
explorer "%USER_PATH%"
exit /b