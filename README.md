# IM系统使用指南

## 系统架构
- 服务端：server.py (监听端口 8765)
- 客户端：client.py (连接到服务端进行通信)

## 运行步骤

### 步骤0：激活虚拟环境
在运行任何程序之前，需要先激活虚拟环境：
```
cd f:\IMsystem
f:\IMsystem\im\Scripts\activate
```
或者如果您在f:\IMsystem目录下，可以直接运行：
```
im\Scripts\activate
```

### 步骤1：启动服务端
打开一个新的命令行窗口，运行：
```
cd f:\IMsystem
im\Scripts\activate
python server.py
```
您应该看到输出："Server started on port 8765"

### 步骤2：启动第一个客户端
打开第二个命令行窗口，运行：
```
cd f:\IMsystem
im\Scripts\activate
python client.py
```
输入用户名，例如："Alice"

### 步骤3：启动第二个客户端
打开第三个命令行窗口，运行：
```
cd f:\IMsystem
im\Scripts\activate
python client.py
```
输入另一个用户名，例如："Bob"

### 步骤4：进行通信
- 在Alice的客户端中输入：`@Bob 你好，我是Alice`
- 在Bob的客户端中会收到：`[收到来自 Alice 的消息]: 你好，我是Alice`
- 在Bob的客户端中回复：`@Alice 你好Alice，我是Bob`
- 在Alice的客户端中会收到：`[收到来自 Bob 的消息]: 你好Alice，我是Bob`

## 消息格式
- 发送消息：`@用户名 消息内容`
- 示例：`@Tom 明天开会记得准时参加`
- 查看在线用户：输入 `list`
- 退出程序：输入 `quit`

## 注意事项
1. 确保服务端先启动再启动客户端
2. 不同客户端需使用不同的用户名
3. 只有在线用户才能收到消息
4. 用户断开连接后会自动从在线列表中移除
5. 必须在虚拟环境中运行程序以确保依赖库可用
6. 如需硬编码服务器IP，请修改client.py中的DEFAULT_SERVER变量

## 故障排除
- 如果连接失败，请确认服务端正在运行
- 确认防火墙没有阻止8765端口
- 检查网络连接是否正常
- 确保已激活虚拟环境：`im\Scripts\activate`
- 确认websockets库已安装：在激活虚拟环境后运行 `pip install websockets`
- 验证Python解释器路径：运行 `where python` 应该显示虚拟环境路径
- 如果仍然有问题，直接使用虚拟环境中的Python：`im\Scripts\python server.py`
- 如果遇到端口占用错误，终止相关进程：`taskkill /F /IM python.exe`