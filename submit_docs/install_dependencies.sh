#!/bin/bash
set -e

echo "======================================================================="
echo "  CÀI ĐẶT THƯ VIỆN DỰ ÁN: HoangXuanLuan23IT150-DaNenTang2026"
echo "  Môn: Lập Trình Đa Nền Tảng (Flutter + Node.js + MongoDB)"
echo "======================================================================="
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"

echo "[1/2] Đang cài đặt thư viện Backend (Node.js/Express)..."
cd "$PROJECT_ROOT/backend"
npm install

echo ""
echo "[2/2] Đang cài đặt thư viện Frontend (Flutter)..."
cd "$PROJECT_ROOT/frontend"
flutter pub get

echo ""
echo "======================================================================="
echo "  [HOÀN TẤT] Cài đặt toàn bộ thư viện cho Backend và Frontend thành công!"
echo "======================================================================="
