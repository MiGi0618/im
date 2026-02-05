@echo off
chcp 65001 >nul
echo Starting IM System Test Environment
echo ====================================

echo 1. 启动服务端 (按Ctrl+C停止)
echo 运行: f:\IMsystem\im\Scripts\python server.py
pause
start cmd /k "cd /d f:\IMsystem && chcp 65001 >nul && title IM Server && f:\IMsystem\im\Scripts\python server.py"

echo.
echo 2. 启动Alice客户端
echo 运行: f:\IMsystem\im\Scripts\python client.py (用户名: Alice)
pause
start cmd /k "cd /d f:\IMsystem && chcp 65001 >nul && title Alice Client && f:\IMsystem\im\Scripts\python client.py"

echo.
echo 3. 启动Bob客户端
echo 运行: f:\IMsystem\im\Scripts\python client.py (用户名: Bob)
pause
start cmd /k "cd /d f:\IMsystem && chcp 65001 >nul && title Bob Client && f:\IMsystem\im\Scripts\python client.py"

echo.
echo 所有组件已启动！
echo 请在各个窗口中按照提示操作。
echo.
echo 服务端窗口：将显示谁上线/下线
echo Alice客户端：输入 @Bob 你好，我是Alice
echo Bob客户端：输入 @Alice 你好，我是Bob
echo.
pause