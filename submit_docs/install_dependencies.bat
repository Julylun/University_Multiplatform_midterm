@echo off
chcp 65001 >nul
echo =======================================================================
echo   CÀI ĐẶT THƯ VIỆN DỰ ÁN: HoangXuanLuan23IT150-DaNenTang2026
echo   Môn: Lập Trình Đa Nền Tảng (Flutter + Node.js + MongoDB)
echo =======================================================================
echo.

cd /d "%~dp0\.."

echo [1/2] Đang cài đặt thư viện Backend (Node.js/Express)...
cd backend
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [LỖI] Không thể cài đặt thư viện Backend.
    pause
    exit /b %ERRORLEVEL%
)
cd ..

echo.
echo [2/2] Đang cài đặt thư viện Frontend (Flutter)...
cd frontend
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [LỖI] Không thể cài đặt thư viện Flutter Frontend.
    pause
    exit /b %ERRORLEVEL%
)
cd ..

echo.
echo =======================================================================
echo   [HOÀN TẤT] Cài đặt toàn bộ thư viện cho Backend và Frontend thành công!
echo =======================================================================
pause
