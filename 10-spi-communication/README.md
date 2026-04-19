# 第10节：SPI通信实战：使用Zig实现SPI Flash驱动

## 课程说明

本节教程是 Zig 单片机教程的第十课，重点介绍如何使用 Zig 实现 STM32F407 的 SPI 通信驱动，包括 SPI 主机模式配置、数据收发以及读取 SPI Flash ID 的完整示例。

SPI（Serial Peripheral Interface）是一种高速、全双工、同步的通信总线，广泛应用于嵌入式系统中连接各种外设，如 Flash 存储器、传感器、显示屏等。掌握 SPI 通信是嵌入式开发的重要技能之一。

## 课程目标

- 理解 SPI 通信协议的基本原理
- 掌握 STM32F407 SPI 外设的寄存器配置
- 理解 SPI 主机模式的配置方法
- 掌握 SPI 数据收发的实现
- 使用 Zig 实现 SPI Flash ID 读取
- 在开发板上测试 SPI 通信

## 目录结构

```
10-spi-communication/
├── README.md              # 课程说明
├── spi-communication.md   # 主教程内容
└── example-project/       # 示例项目
    ├── src/
    │   ├── main.zig       # 主程序文件（Zig）
    │   ├── startup.zig    # 启动文件（Zig 实现）
    │   ├── spi.zig        # SPI 驱动模块
    │   ├── uart.zig       # UART 驱动模块
    │   ├── clock_tree.zig # 时钟树模块
    │   └── link.ld        # 链接脚本
    ├── .vscode/
    │   └── launch.json    # VSCode 调试配置
    ├── run-qemu.bat       # QEMU 运行脚本
    └── run-qemu-debug.bat # QEMU 调试脚本
```

## 快速开始

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

程序会通过 QEMU 的串口输出 SPI Flash ID 读取信息。

### 4. 调试项目

1. 启动 QEMU 调试模式：

```bash
run-qemu-debug.bat
```

2. 在 VSCode 中按下 `F5` 键启动调试
3. 使用调试工具栏进行单步执行、断点设置等操作

## 核心代码说明

### spi.zig 文件

`spi.zig` 文件实现了 SPI 驱动功能：

1. **寄存器定义**：定义了 SPI 寄存器地址和位定义
2. **SPI 初始化**：配置 SPI 为主机模式
3. **数据发送**：实现单字节和多字节数据发送
4. **数据接收**：实现单字节和多字节数据接收
5. **全双工通信**：实现同时发送和接收数据

### uart.zig 文件

`uart.zig` 文件实现了 UART 驱动功能：

1. **UART 初始化**：配置 USART1 为 115200 波特率
2. **字符串发送**：实现字符串输出
3. **十六进制输出**：实现 8 位和 32 位十六进制格式输出
4. **整数输出**：实现无符号整数输出

### main.zig 文件

`main.zig` 文件实现了 SPI Flash ID 读取功能：

1. **SPI2 初始化**：配置 SPI2 为主机模式
2. **GPIO 配置**：配置 SPI2 引脚和 CS 片选引脚
3. **Flash ID 读取**：发送 0x9F 命令读取 Flash ID
4. **UART 输出**：通过 UART 打印读取到的 Flash ID

### SPI2 引脚配置

本示例使用 SPI2 连接 SPI Flash：

| 引脚 | 功能 | 说明 |
|------|------|------|
| PC2 | SPI2_MISO | 主入从出 |
| PC3 | SPI2_MOSI | 主出从入 |
| PB13 | SPI2_SCK | 时钟线 |
| PB12 | CS | 片选信号 |

### 运行脚本

- **run-qemu.bat**：运行 QEMU 仿真，显示串口输出
- **run-qemu-debug.bat**：启动 QEMU 调试模式，等待 GDB 连接

## VSCode 调试配置

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

## 学习资源

- [STM32F407 参考手册](https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)
- [Zig 官方文档](https://ziglang.org/documentation/master/)
- [QEMU 官网](https://www.qemu.org/)
- [ARM GCC 工具链下载](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)

## 常见问题

### SPI 初始化失败
- 检查 SPI 时钟是否正确使能
- 确认 GPIO 引脚配置是否正确
- 检查 SPI 模式配置是否与从机匹配

### 数据传输错误
- 确认时钟极性（CPOL）和时钟相位（CPHA）设置正确
- 检查波特率分频是否合适
- 验证数据帧格式（8位/16位）配置

### Flash ID 读取失败
- 检查 CS 片选信号是否正确控制
- 确认 SPI Flash 是否正确连接
- 验证 SPI Flash 是否支持 0x9F 命令

### QEMU 启动失败
- 检查 QEMU 路径是否正确
- 确认使用的机器类型是否支持（本教程使用 olimex-stm32-h405）
- 检查编译生成的可执行文件是否存在

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
