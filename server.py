# 导入必要的库
import asyncio      # 异步编程库，类似C++的多线程，但更轻量级
import json         # JSON数据处理库，用于解析和生成JSON格式数据
try:
    import websockets   # WebSocket协议库，用于实现实时双向通信
except ImportError:
    print("错误: 未找到websockets库。")
    print("请确保已激活虚拟环境并安装了websockets库。")
    print("激活虚拟环境命令: f:\\IMsystem\\im\\Scripts\\activate")
    print("安装websockets命令: pip install websockets")
    import sys
    sys.exit(1)

# 全局变量：在线用户表，类似C++的std::map<std::string, WebSocket*>
# 键：用户ID（字符串），值：WebSocket连接对象
online_users = {}

# 异步函数：处理每个客户端连接
# 参数ws：WebSocket连接对象，类似C++的socket连接
async def handler(ws):
    user_id = None  # 当前连接的用户ID，初始化为None（类似C++的nullptr）

    try:
        # 异步循环：持续接收来自客户端的消息
        # 类似C++中的while循环，但不会阻塞其他连接
        async for message in ws:
            # 将JSON字符串转换为Python字典（类似C++的map）
            data = json.loads(message)

            # 1. 用户登录：标记这个连接属于哪个用户
            if data["type"] == "login":
                # 从消息中提取用户ID
                user_id = data["user"]
                # 将用户ID和连接对象存入在线用户表
                # 类似C++: online_users[user_id] = ws;
                online_users[user_id] = ws
                print(f"{user_id} 上线")  # 打印用户上线信息
                print_online_users()  # 打印当前在线用户列表
                
                # 向客户端发送登录成功的确认消息
                await ws.send(json.dumps({
                    "type": "login_success",
                    "message": f"欢迎 {user_id}，您已成功登录"
                }))

            # 2. 聊天消息转发：将消息转发给指定用户
            elif data["type"] == "chat":
                # 获取消息的目标用户
                to_user = data["to"]

                # 检查目标用户是否在线（类似C++检查指针是否有效）
                if to_user in online_users:
                    # 构造要转发的消息内容
                    message_to_send = {
                        "from": user_id,           # 消息发送者
                        "content": data["content"] # 消息内容
                    }

                    # 将消息转换为JSON字符串并发送给目标用户
                    # await：等待发送完成，不阻塞其他操作
                    await online_users[to_user].send(json.dumps(message_to_send))

            # 3. 请求在线用户列表
            elif data["type"] == "list":
                # 返回当前在线用户列表
                await ws.send(json.dumps({
                    "type": "user_list",
                    "users": list(online_users.keys())
                }))

    finally:
        # finally块：无论正常结束还是异常，都会执行
        # 清理工作：用户断开连接时，从在线用户表中移除
        if user_id:  # 如果用户ID有效
            # 从在线用户表中删除该用户
            # pop(key, None)：删除键值对，如果键不存在也不报错
            online_users.pop(user_id, None)
            print(f"{user_id} 下线")  # 打印用户下线信息
            print_online_users()  # 打印当前在线用户列表

# 辅助函数：打印当前在线用户列表
def print_online_users():
    print(f"当前在线用户 ({len(online_users)}人): {', '.join(online_users.keys()) if online_users else '无'}")

# 主函数：启动WebSocket服务器
async def main():
    import argparse
    parser = argparse.ArgumentParser(description='IM Server')
    parser.add_argument('--host', type=str, default='0.0.0.0', help='Server host (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=8765, help='Server port (default: 8765)')
    args = parser.parse_args()

    # 启动WebSocket服务器，监听指定IP地址和端口
    # 类似C++的socket编程中的bind和listen
    # handler：当有新连接时调用的处理函数
    async with websockets.serve(handler, args.host, args.port):
        print(f"Server started on {args.host}:{args.port}")  # 服务器启动成功提示
        # 永远等待，保持服务器运行
        # asyncio.Future()：一个永远不会完成的Future对象
        await asyncio.Future()

# 程序入口点：运行主函数
# 类似C++的int main()函数
asyncio.run(main())
