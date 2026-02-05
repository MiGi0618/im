#!/bin/bash

# IM Server 部署脚本
# 适用于 Linux 系统

set -e  # 遇到错误时退出

echo "开始部署 IM Server..."

# 检查是否已安装 Python3 和 pip3
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 python3，请先安装"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "警告: 未找到 pip3，将尝试安装"
    sudo apt update
    sudo apt install -y python3-pip
fi

# 创建项目目录
PROJECT_DIR="/opt/imserver"
sudo mkdir -p $PROJECT_DIR

# 复制服务器文件
sudo cp server.py $PROJECT_DIR/
sudo cp requirements.txt $PROJECT_DIR/

# 更改目录权限
sudo chown -R $USER:$USER $PROJECT_DIR
cd $PROJECT_DIR

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 升级 pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt

echo "依赖安装完成"

# 创建 systemd 服务文件
SERVICE_FILE="/etc/systemd/system/imserver.service"
sudo bash -c "cat > $SERVICE_FILE << EOF
[Unit]
Description=IM Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment=PATH=$PROJECT_DIR/venv/bin
ExecStart=$PROJECT_DIR/venv/bin/python server.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

echo "服务文件创建完成: $SERVICE_FILE"

# 重载 systemd 配置
sudo systemctl daemon-reload

# 启用并启动服务
sudo systemctl enable imserver
sudo systemctl start imserver

# 检查服务状态
sudo systemctl status imserver --no-pager -l

echo "IM Server 部署完成!"
echo "服务状态: $(systemctl is-active imserver)"
echo "访问地址: 服务器IP:8765"