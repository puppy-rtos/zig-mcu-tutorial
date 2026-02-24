# UART通信实战：使用Zig实现串口打印

## 🚀 开篇引言

欢迎来到 Zig 单片机教程的第八课！

在前几节课中，我们学习了 Zig 语言的基础知识、搭建了调试环境，并使用 QEMU 进行了在线仿真。本节课我们将重点介绍如何使用 Zig 实现 UART 通信，通过串口打印 "Hello Zig from MCU!" 消息。

UART（Universal Asynchronous Receiver Transmitter）是一种通用的异步串行通信协议，广泛应用于嵌入式系统中，用于与上位机或其他设备进行通信。掌握 UART 通信是嵌入式开发的基础技能之一。

---

## 🎯 学习目标

通过本节课的学习，你将能够：

- ✅ 理解 UART 通信的基本原理
- ✅ 掌握 STM32F407 UART 寄存器的配置方法
- ✅ 使用 Zig 实现 UART 初始化和发送功能
- ✅ 在 QEMU 中测试 UART 输出

---

## 📋 工具准备

### 1.1 必要工具清单

搭建完整的 UART 通信环境需要以下工具：

| 工具 | 版本/要求 | 用途 |
|------|-----------|------|
| VSCode | 最新版本 | 代码编辑和调试界面 |
| Zig | 0.15.0+ | 编译工具链 |
| QEMU | 7.0+ | ARM Cortex-M 仿真器 |
| ARM GCC 工具链 | 12.2+ | 提供 GDB 调试工具 |
| Cortex-Debug | VSCode 插件 | VSCode 调试支持 |

### 1.2 工具安装

如果您已经完成了第7节教程的学习，那么您应该已经安装了上述所有工具。如果尚未安装，请参考第7节教程中的工具安装步骤。

---

## 📡 UART通信原理

### 2.1 UART 基本概念

UART 是一种异步串行通信协议，主要特点包括：

- **异步通信**：不需要时钟信号，通过约定的波特率进行同步
- **串行传输**：数据一位一位地按顺序传输
- **全双工**：可以同时发送和接收数据
- **帧格式**：通常包含起始位、数据位（8位）、奇偶校验位（可选）和停止位（1位）

### 2.2 STM32F407 UART 资源

STM32F407 系列芯片有多个 UART 接口：

| UART | 引脚 | 功能 |
|------|------|------|
| USART1 | PA9 (TX), PA10 (RX) | 通用同步/异步收发器 |
| USART2 | PA2 (TX), PA3 (RX) | 通用同步/异步收发器 |
| USART3 | PB10 (TX), PB11 (RX) | 通用同步/异步收发器 |
| UART4 | PC10 (TX), PC11 (RX) | 通用异步收发器 |
| UART5 | PC12 (TX), PD2 (RX) | 通用异步收发器 |
| USART6 | PC6 (TX), PC7 (RX) | 通用同步/异步收发器 |

本教程使用 USART1（PA9/PA10）进行演示。

### 2.3 UART 初始化步骤

使用 UART 进行通信的基本步骤：

1. **使能时钟**：使能 GPIO 和 USART 时钟
2. **配置引脚**：设置 TX/RX 引脚为复用功能
3. **配置 USART**：设置波特率、数据位、停止位等参数
4. **使能 USART**：使能发送器和接收器
5. **发送/接收数据**：通过数据寄存器发送或接收数据

---

## 📁 示例项目

### 3.1 项目结构

本节教程的项目结构如下：

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

### 3.2 核心代码解析

#### 3.2.1 主程序文件（main.zig）

```zig
// UART打印示例 - 直接操作寄存器

// STM32F407寄存器地址
const RCC_BASE = 0x40023800;
const GPIOA_BASE = 0x40020000;
const USART1_BASE = 0x40011000;

// RCC寄存器
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));
const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x44));

// GPIOA寄存器
const GPIOA_MODER = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x00));
const GPIOA_AFRL = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x20));
const GPIOA_AFRH = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x24));

// USART1寄存器
const USART1_SR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x00));
const USART1_DR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x04));
const USART1_BRR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x08));
const USART1_CR1 = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x0C));

// UART引脚
const UART_TX_PIN = 9;  // PA9
const UART_RX_PIN = 10; // PA10

pub fn main() noreturn {
    // 启用GPIOA时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 0); // GPIOA的时钟使能位是第0位
    
    // 启用USART1时钟
    RCC_APB2ENR.* |= @as(u32, 1 << 4); // USART1的时钟使能位是第4位
    
    // 设置PA9和PA10为复用功能模式
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_TX_PIN * 2)); // 清除PA9现有设置
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_TX_PIN * 2));  // 设置PA9为复用功能模式
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_RX_PIN * 2)); // 清除PA10现有设置
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_RX_PIN * 2));  // 设置PA10为复用功能模式
    
    // 设置PA9和PA10的复用功能为AF7 (USART1)
    // PA9和PA10使用AFRH寄存器（控制引脚8-15）
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_TX_PIN - 8) * 4)); // 清除PA9复用功能
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_TX_PIN - 8) * 4));  // 设置PA9为AF7
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_RX_PIN - 8) * 4)); // 清除PA10复用功能
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_RX_PIN - 8) * 4));  // 设置PA10为AF7
    
    // 配置USART1
    // 设置波特率为115200 (假设系统时钟为16MHz)
    // USARTDIV = 16000000 / (16 * 115200) = 8.68
    // USART_BRR = (MANTISSA << 4) | FRACTION = (8 << 4) | 11 = 139
    USART1_BRR.* = @as(u32, 139);
    
    // 使能USART1发送器和接收器
    USART1_CR1.* |= @as(u32, (1 << 3) | (1 << 2)); // TE=1, RE=1
    
    // 使能USART1
    USART1_CR1.* |= @as(u32, 1 << 13); // UE=1
    
    // 主循环
    while (true) {
        // 打印"Hello Zig from MCU!"
        uart_print("Hello Zig from MCU!\r\n");
        
        // 延迟
        delay_ms(1000);
    }
}

// UART发送单个字符
fn uart_send_byte(byte: u8) void {
    // 等待发送数据寄存器为空
    while ((USART1_SR.* & @as(u32, 1 << 7)) == 0) {}
    
    // 发送数据
    USART1_DR.* = @as(u32, byte);
}

// UART打印字符串
fn uart_print(str: []const u8) void {
    for (str) |byte| {
        uart_send_byte(byte);
    }
}

// 简单的延迟函数
fn delay_ms(ms: u32) void {
    // 假设系统时钟为16MHz
    const cycles_per_ms = 16000;
    var i: u32 = 0;
    while (i < ms * cycles_per_ms) : (i += 1) {
        asm volatile ("nop");
    }
}
```

#### 3.2.2 代码解析

1. **寄存器定义**：定义了所需的 RCC、GPIOA 和 USART1 寄存器地址
2. **时钟使能**：使能 GPIOA 和 USART1 的时钟
3. **引脚配置**：将 PA9 和 PA10 配置为复用功能模式，并设置为 AF7（USART1）
4. **USART 配置**：设置波特率为 115200，使能发送器和接收器
5. **主循环**：每秒打印一次 "Hello Zig from MCU!" 消息
6. **辅助函数**：
   - `uart_send_byte`：发送单个字符
   - `uart_print`：打印字符串
   - `delay_ms`：简单的延迟函数

### 3.3 编译和运行

#### 3.3.1 编译项目

在 `example-project` 目录执行以下命令编译项目：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

#### 3.3.2 运行项目

使用以下命令运行项目：

```bash
run-qemu.bat
```

程序会通过 QEMU 的串口输出 "Hello Zig from MCU!" 消息，每秒打印一次。

#### 3.3.3 调试项目

1. 启动 QEMU 调试模式：

```bash
run-qemu-debug.bat
```

2. 在 VSCode 中按下 `F5` 键启动调试
3. 使用调试工具栏进行单步执行、断点设置等操作

---

## 🐛 常见问题和解决方案

### 6.1 串口输出乱码

**问题**：串口输出乱码或不正确

**解决方案**：

- 检查波特率设置是否与上位机一致
- 确认系统时钟频率是否正确
- 检查串口线连接是否正确

### 6.2 调试连接问题

**问题**：VSCode 无法连接到 QEMU 进行调试

**解决方案**：

- 确保 QEMU 调试模式已经启动
- 检查 GDB 路径是否正确配置
- 确认端口号（默认为 1234）没有被占用
- 重启 VSCode 和 QEMU

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*