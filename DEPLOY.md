# IM Server Linux 部署指南

## 部署前准备

在将服务端部署到Linux服务器之前，请确保满足以下要求：

### 服务器要求
- Linux发行版（推荐 Ubuntu 18.04+ 或 CentOS 7+）
- Python 3.7+
- 至少 50MB 可用磁盘空间
- 开放端口 8765（或根据需要修改）

### 网络要求
- 服务器需要能够访问公网以安装依赖包
- 客户端需要能够访问服务器的 8765 端口

## 部署步骤

### 方法一：使用部署脚本（推荐）

1. 将以下文件传输到您的Linux服务器：
   - `server.py`（服务端代码）
   - `requirements.txt`（依赖声明）
   - `deploy.sh`（部署脚本）

2. 在服务器上执行以下命令：
```bash
# 给部署脚本执行权限
chmod +x deploy.sh

# 运行部署脚本
./deploy.sh
```

3. 部署脚本会自动完成以下操作：
   - 检查并安装必要工具
   - 创建项目目录 `/opt/imserver`
   - 设置Python虚拟环境
   - 安装依赖包
   - 创建并启动 systemd 服务

### 方法二：手动部署

1. 在服务器上创建项目目录：
```bash
sudo mkdir -p /opt/imserver
cd /opt/imserver
```

2. 上传 `server.py` 到 `/opt/imserver/` 目录

3. 安装Python虚拟环境：
```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
```

4. 创建并激活虚拟环境：
```bash
python3 -v venv venv
source venv/bin/activate
```

5. 安装依赖：
```bash
pip install --upgrade pip
pip install websockets==16.0
```

6. 测试服务（按 Ctrl+C 停止）：
```bash
python server.py
```

7. 创建 systemd 服务文件 `/etc/systemd/system/imserver.service`：
```bash
sudo nano /etc/systemd/system/imserver.service
```

粘贴以下内容（替换 `<YOUR_USERNAME>` 为您的用户名）：
```
[Unit]
Description=IM Server
After=network.target

[Service]
Type=simple
User=<YOUR_USERNAME>
WorkingDirectory=/opt/imserver
Environment=PATH=/opt/imserver/venv/bin
ExecStart=/opt/imserver/venv/bin/python server.py
Restart=always

[Install]
WantedBy=multi-user.target
```

8. 启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable imserver
sudo systemctl start imserver
```

## 服务管理

### 检查服务状态
```bash
sudo systemctl status imserver
```

### 查看服务日志
```bash
sudo journalctl -u imserver -f
```

### 重启服务
```bash
sudo systemctl restart imserver
```

### 停止服务
```bash
sudo systemctl stop imserver
```

## 防火墙配置

如果服务器启用了防火墙，需要开放8765端口：

### Ubuntu (UFW)
```bash
sudo ufw allow 8765
```

### CentOS/RHEL (firewalld)
```bash
sudo firewall-cmd --permanent --add-port=8765/tcp
sudo firewall-cmd --reload
```

### CentOS/RHEL (iptables)
```bash
sudo iptables -A INPUT -p tcp --dport 8765 -j ACCEPT
sudo service iptables save
```

## 配置修改

如果需要修改服务端口或其他配置，可以通过以下方式：

### 方法一：修改服务文件（推荐）
编辑 systemd 服务文件 `/etc/systemd/system/imserver.service` 中的 ExecStart 行：
```
ExecStart=/opt/imserver/venv/bin/python server.py --host 0.0.0.0 --port 8765
```

然后重启服务：
```bash
sudo systemctl daemon-reload
sudo systemctl restart imserver
```

### 方法二：直接编辑源码
编辑 `/opt/imserver/server.py` 文件中的默认参数，然后重启服务：
```bash
sudo systemctl restart imserver
```

### 支持的命令行参数
- `--host`: 服务器绑定的主机地址（默认: 0.0.0.0）
- `--port`: 服务器监听的端口（默认: 8765）

## 故障排除

### 服务无法启动
1. 检查日志：
   ```bash
   sudo journalctl -u imserver -f
   ```
2. 确认端口未被占用：
   ```bash
   sudo netstat -tlnp | grep :8765
   ```

### 客户端无法连接
1. 检查防火墙设置
2. 确认服务器IP和端口是否正确
3. 检查服务器网络连通性

### 性能优化
对于高并发场景，可以考虑：
- 调整系统文件描述符限制
- 使用反向代理（如Nginx）处理WebSocket连接
- 配置负载均衡

## 客户端连接说明

部署完成后，客户端可以通过以下方式连接到服务器：

### 基本连接
1. 确保客户端机器可以访问服务器的指定端口（默认8765）
2. 在客户端运行：
```bash
python client.py --server ws://<服务器IP>:<端口号>
```

例如，如果服务器IP是 192.168.1.100，端口是8765：
```bash
python client.py --server ws://192.168.1.100:8765
```

### 客户端参数
- `--server`: 服务器地址（默认: ws://localhost:8765）

### 硬编码服务器IP
如果希望在客户端代码中直接指定服务器IP而不使用命令行参数：
1. 编辑 client.py 文件
2. 找到 DEFAULT_SERVER 变量
3. 将其值修改为您的服务器地址
4. 例如：`DEFAULT_SERVER = "ws://your-server-ip:8765"`

### 连接测试
1. 确认服务器服务正在运行：
   ```bash
   sudo systemctl status imserver
   ```
2. 确认端口已开放：
   ```bash
   sudo netstat -tlnp | grep :8765
   ```
3. 从客户端测试连接：
   ```bash
   telnet <服务器IP> <端口号>
   ```

## 安全建议

1. 使用专用用户运行服务
2. 定期更新系统和Python包
3. 配置防火墙限制访问来源
4. 监控服务日志中的异常活动
5. 考虑使用SSL/TLS加密通信