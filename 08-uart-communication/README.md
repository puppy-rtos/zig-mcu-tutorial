# 第8节：UART通信实战：使用Zig实现串口打印

## 📚 课程说明

本节教程是 Zig 单片机教程的第八课，重点介绍如何使用 Zig 实现 UART 通信，通过串口打印 "Hello Zig from MCU!" 消息。

UART（Universal Asynchronous Receiver Transmitter）是一种通用的异步串行通信协议，广泛应用于嵌入式系统中，用于与上位机或其他设备进行通信。掌握 UART 通信是嵌入式开发的基础技能之一。

## 🎯 课程目标

- 理解 UART 通信的基本原理
- 掌握 STM32F407 UART 寄存器的配置方法
- 使用 Zig 实现 UART 初始化和发送功能
- 在 QEMU 中测试 UART 输出
- 结合 VSCode 进行 UART 代码的调试
- 解决 UART 通信中常见的问题

## 📁 目录结构

```
08-uart-communication/
├── README.md              # 课程说明
├── uart-communication.md  # 主教程内容
└── example-project/       # 示例项目
    ├── src/
    │   ├── main.zig       # 主程序文件（Zig）
    │   ├── startup.zig    # 启动文件（Zig 实现）
    │   └── link.ld        # 链接脚本
    ├── .vscode/
    │   └── launch.json    # VSCode 调试配置
    ├── run-qemu.bat       # QEMU 运行脚本
    └── run-qemu-debug.bat # QEMU 调试脚本
```

## 🚀 快速开始

### 1. 安装必要工具

- VSCode
- Zig 0.15.0+
- QEMU（本教程使用路径：`D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe`）
- ARM GCC 工具链
- Cortex-Debug VSCode 插件

### 2. 编译项目

在 `example-project` 目录执行以下命令编译项目：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

### 3. 运行项目

使用以下命令运行项目：

```bash
run-qemu.bat
```

程序会通过 QEMU 的串口输出 "Hello Zig from MCU!" 消息，每秒打印一次。

### 4. 调试项目

1. 启动 QEMU 调试模式：

```bash
run-qemu-debug.bat
```

2. 在 VSCode 中按下 `F5` 键启动调试
3. 使用调试工具栏进行单步执行、断点设置等操作

## 🔧 核心代码说明

### main.zig 文件

`main.zig` 文件实现了 UART 初始化和发送功能：

1. **寄存器定义**：定义了所需的 RCC、GPIOA 和 USART1 寄存器地址
2. **时钟使能**：使能 GPIOA 和 USART1 的时钟
3. **引脚配置**：将 PA9 和 PA10 配置为复用功能模式，并设置为 AF7（USART1）
4. **USART 配置**：设置波特率为 115200，使能发送器和接收器
5. **主循环**：每秒打印一次 "Hello Zig from MCU!" 消息
6. **辅助函数**：
   - `uart_send_byte`：发送单个字符
   - `uart_print`：打印字符串
   - `delay_ms`：简单的延迟函数

### 运行脚本

- **run-qemu.bat**：运行 QEMU 仿真，显示串口输出
- **run-qemu-debug.bat**：启动 QEMU 调试模式，等待 GDB 连接

## 🔍 VSCode 调试配置

在 `example-project/.vscode/launch.json` 文件中配置调试参数：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug with QEMU",
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "external",
            "cwd": "${workspaceFolder}",
            "executable": "${workspaceFolder}/stm32f407",
            "runToEntryPoint": "main",
            "targetId": "cortex-m4",
            "gdbPath": "D:/Progrem/arm-gnu-toolchain-12.2.rel1/bin/arm-none-eabi-gdb",
            "gdbTarget": "localhost:1234"
        }
    ]
}
```

## 📖 学习资源

- [STM32F407 参考手册](https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)
- [Zig 官方文档](https://ziglang.org/documentation/master/)
- [QEMU 官网](https://www.qemu.org/)
- [ARM GCC 工具链下载](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)

## 🐛 常见问题

### UART 初始化失败
- 检查时钟使能是否正确
- 确认引脚配置是否正确，特别是复用功能设置
- 检查波特率设置是否正确
- 验证 USART 使能位是否设置

### 串口输出乱码
- 检查波特率设置是否与上位机一致
- 确认系统时钟频率是否正确
- 检查串口线连接是否正确

### QEMU 启动失败
- 检查 QEMU 路径是否正确
- 确认使用的机器类型是否支持（本教程使用 olimex-stm32-h405）
- 检查编译生成的可执行文件是否存在

### 调试连接问题
- 确保 QEMU 调试模式已经启动
- 检查 GDB 路径是否正确配置
- 确认端口号（默认为 1234）没有被占用
- 重启 VSCode 和 QEMU

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*