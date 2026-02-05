import asyncio
import json
try:
    import websockets
except ImportError:
    print("错误: 未找到websockets库。")
    print("请确保已激活虚拟环境并安装了websockets库。")
    print("激活虚拟环境命令: f:\\IMsystem\\im\\Scripts\\activate")
    print("安装websockets命令: pip install websockets")
    import sys
    sys.exit(1)

# 默认服务器地址 - 可以在这里硬编码服务器IP
DEFAULT_SERVER = "ws://139.199.89.126:8765"  # 修改这里为您的服务器IP

class IMClient:
    def __init__(self, username):
        self.username = username
        self.websocket = None
        
    async def connect(self, uri=None):
        """连接到服务器"""
        if uri is None:
            uri = DEFAULT_SERVER  # 使用默认服务器地址
            
        try:
            self.websocket = await websockets.connect(uri)
            print(f"已连接到服务器: {uri}")
            
            # 登录到服务器
            login_data = {
                "type": "login",
                "user": self.username
            }
            await self.websocket.send(json.dumps(login_data))
            print(f"已登录，用户名: {self.username}")
            
            return self.websocket
            
        except Exception as e:
            print(f"连接错误: {e}")
            return None
    
    async def send_message(self, to_user, content):
        """发送消息给指定用户"""
        if self.websocket:
            message_data = {
                "type": "chat",
                "to": to_user,
                "content": content
            }
            await self.websocket.send(json.dumps(message_data))
            print(f"已发送消息给 {to_user}: {content}")
        else:
            print("未连接到服务器")
    
    async def receive_messages(self, websocket):
        """接收来自服务器的消息"""
        try:
            async for message in websocket:
                data = json.loads(message)
                
                # 处理接收到的消息
                if "from" in data and "content" in data:
                    print(f"[收到来自 {data['from']} 的消息]: {data['content']}")
                elif data.get("type") == "user_list":
                    print(f"当前在线用户 ({len(data['users'])}人): {', '.join(data['users']) if data['users'] else '无'}")
                elif data.get("type") == "login_success":
                    print(data["message"])
                else:
                    print(f"收到未知消息: {data}")
                    
        except websockets.exceptions.ConnectionClosed:
            print("与服务器的连接已关闭")
        except Exception as e:
            print(f"接收消息时出错: {e}")


async def user_input_handler(client, websocket):
    """处理用户输入的独立协程"""
    print("\\n使用说明:")
    print("- 发送消息格式: @用户名 消息内容")
    print("- 例如: @张三 你好")
    print("- 查看在线用户: list")
    print("- 输入 'quit' 退出程序")
    
    while True:
        try:
            user_input = await asyncio.get_event_loop().run_in_executor(None, input)
            
            if user_input.lower() == 'quit':
                print("正在退出...")
                if websocket:
                    await websocket.close()
                break
                
            # 请求在线用户列表
            elif user_input.lower() == 'list':
                if websocket:
                    list_request = {
                        "type": "list"
                    }
                    await websocket.send(json.dumps(list_request))
                else:
                    print("错误: 未连接到服务器")
                
            # 解析用户输入 - 格式: @用户名 消息内容
            elif user_input.startswith('@'):
                if not websocket:
                    print("错误: 未连接到服务器")
                    continue
                    
                # 查找第一个空格的位置
                space_index = user_input.find(' ')
                if space_index != -1:
                    to_user = user_input[1:space_index]  # 提取用户名（去掉@符号）
                    content = user_input[space_index+1:]  # 提取消息内容
                    
                    if content.strip():  # 确保消息内容不为空
                        message_data = {
                            "type": "chat",
                            "to": to_user,
                            "content": content
                        }
                        await websocket.send(json.dumps(message_data))
                        print(f"已发送消息给 {to_user}: {content}")
                    else:
                        print("消息内容不能为空")
                else:
                    print("无效的消息格式，请使用: @用户名 消息内容")
            else:
                print("无效的命令格式，请使用: @用户名 消息内容 或 'list'")
                
        except KeyboardInterrupt:
            print("\\n正在退出...")
            if websocket:
                await websocket.close()
            break


async def main():
    import argparse
    parser = argparse.ArgumentParser(description='IM Client')
    parser.add_argument('--server', type=str, help=f'Server address (default: {DEFAULT_SERVER})')
    args = parser.parse_args()

    # 如果没有提供服务器地址，则使用默认值
    server_uri = args.server if args.server else DEFAULT_SERVER

    # 获取用户名
    username = await asyncio.get_event_loop().run_in_executor(None, input, "请输入您的用户名: ")
    
    # 创建客户端实例
    client = IMClient(username)
    
    # 连接到服务器
    websocket = await client.connect(server_uri)
    
    if websocket:
        # 创建两个并发任务：一个处理用户输入，一个接收消息
        await asyncio.gather(
            user_input_handler(client, websocket),
            client.receive_messages(websocket)
        )
    else:
        print("无法连接到服务器")

if __name__ == "__main__":
    asyncio.run(main())