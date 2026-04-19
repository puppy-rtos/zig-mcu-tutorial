# SPI通信实战：使用Zig实现SPI Flash驱动

## 开篇引言

欢迎来到 Zig 单片机教程的第十课！

在前几节课中，我们学习了 Zig 语言的基础知识、搭建了调试环境、实现了 LED 闪烁、UART 通信和时钟树配置。本节课我们将重点介绍 STM32F407 的 SPI 通信，这是嵌入式系统中非常重要的一种通信协议。

SPI（Serial Peripheral Interface）是一种高速、全双工、同步的通信总线，由 Motorola 公司开发。它使用四根信号线进行通信，具有传输速度快、协议简单、全双工通信等优点，广泛应用于 Flash 存储器、传感器、显示屏、SD 卡等外设的连接。

---

## 学习目标

通过本节课的学习，你将能够：

- 理解 SPI 通信协议的基本原理
- 掌握 STM32F407 SPI 外设的寄存器配置
- 理解 SPI 主机模式的配置方法
- 掌握 SPI 数据收发的实现
- 使用 Zig 实现 SPI Flash ID 读取
- 在开发板上测试 SPI 通信

---

## SPI 协议原理

### 1.1 SPI 基本概念

SPI 是一种同步串行通信协议，主要特点如下：

1. **全双工通信**：可以同时发送和接收数据
2. **同步传输**：使用时钟信号同步数据传输
3. **主从模式**：一个主机可以连接多个从机
4. **高速传输**：传输速率可达数 Mbps

### 1.2 SPI 信号线

SPI 使用四根信号线进行通信：

| 信号线 | 名称 | 方向（主机视角） | 功能描述 |
|--------|------|------------------|----------|
| SCK | 时钟线 | 输出 | 主机产生的时钟信号 |
| MOSI | 主出从入 | 输出 | 主机发送数据到从机 |
| MISO | 主入从出 | 输入 | 从机发送数据到主机 |
| NSS/CS | 片选线 | 输出 | 选择通信的从机 |

### 1.3 SPI 时钟极性和相位

SPI 有四种工作模式，由时钟极性（CPOL）和时钟相位（CPHA）决定：

| 模式 | CPOL | CPHA | 空闲时钟电平 | 采样边沿 |
|------|------|------|--------------|----------|
| Mode 0 | 0 | 0 | 低电平 | 上升沿采样 |
| Mode 1 | 0 | 1 | 低电平 | 下降沿采样 |
| Mode 2 | 1 | 0 | 高电平 | 下降沿采样 |
| Mode 3 | 1 | 1 | 高电平 | 上升沿采样 |

### 1.4 SPI 数据传输过程

SPI 数据传输的基本过程：

1. 主机拉低 NSS 片选信号，选中从机
2. 主机产生时钟信号（SCK）
3. 主机通过 MOSI 发送数据，同时从 MISO 接收数据
4. 传输完成后，主机拉高 NSS 片选信号

---

## STM32F407 SPI 外设

### 2.1 SPI 外设概述

STM32F407 包含 3 个 SPI 外设：

| 外设 | 基地址 | 总线 | 最高速率 |
|------|--------|------|----------|
| SPI1 | 0x40013000 | APB2 | 42 Mbps |
| SPI2 | 0x40003800 | APB1 | 21 Mbps |
| SPI3 | 0x40003C00 | APB1 | 21 Mbps |

### 2.2 SPI 寄存器

STM32F407 SPI 外设的主要寄存器：

| 寄存器 | 偏移 | 功能描述 |
|--------|------|----------|
| CR1 | 0x00 | 控制寄存器 1 |
| CR2 | 0x04 | 控制寄存器 2 |
| SR | 0x08 | 状态寄存器 |
| DR | 0x0C | 数据寄存器 |

### 2.3 CR1 寄存器位定义

CR1 寄存器是 SPI 配置的核心寄存器：

| 位 | 名称 | 功能描述 |
|----|------|----------|
| 0 | CPHA | 时钟相位 |
| 1 | CPOL | 时钟极性 |
| 2 | MSTR | 主模式选择 |
| 3-5 | BR[2:0] | 波特率控制 |
| 6 | SPE | SPI 使能 |
| 9 | SSM | 软件从机管理 |
| 11 | DFF | 数据帧格式（0:8位, 1:16位） |

### 2.4 SR 寄存器位定义

SR 寄存器用于查询 SPI 状态：

| 位 | 名称 | 功能描述 |
|----|------|----------|
| 0 | RXNE | 接收缓冲区非空 |
| 1 | TXE | 发送缓冲区空 |
| 7 | BSY | 忙标志 |

---

## 示例项目

### 3.1 项目结构

```
10-spi-communication/
├── README.md              # 课程说明
├── spi-communication.md   # 主教程内容
└── example-project/       # 示例项目
    ├── src/
    │   ├── main.zig       # 主程序文件
    │   ├── startup.zig    # 启动文件
    │   ├── spi.zig        # SPI 驱动模块
    │   ├── uart.zig       # UART 驱动模块
    │   ├── clock_tree.zig # 时钟树模块
    │   └── link.ld        # 链接脚本
    └── .vscode/
        └── launch.json    # VSCode 调试配置
```

### 3.2 核心代码解析

#### 3.2.1 SPI 驱动模块（spi.zig）

**SPI 配置结构体和常量定义：**

```zig
// SPI 模式定义
pub const SPI_MODE_0: u8 = 0;
pub const SPI_DATASIZE_8BIT: u8 = 0;
pub const SPI_BAUDRATEPRESCALER_8: u8 = 2;

// SPI 配置结构体
pub const SpiConfig = struct {
    mode: u8 = SPI_MODE_0,
    datasize: u8 = SPI_DATASIZE_8BIT,
    baudrate_prescaler: u8 = SPI_BAUDRATEPRESCALER_8,
    firstbit: u8 = 0,
};
```

**SPI 初始化函数：**

```zig
pub fn spi_init(spi_base: u32, config: *const SpiConfig) void {
    const cr1 = get_reg(spi_base, SPI_CR1_OFFSET);
    
    cr1.* = 0;
    // 配置时钟极性和相位
    if (config.mode & 0x01 != 0) cr1.* |= SPI_CR1_CPHA;
    if (config.mode & 0x02 != 0) cr1.* |= SPI_CR1_CPOL;
    // 配置波特率、主模式、软件NSS
    cr1.* |= @as(u32, config.baudrate_prescaler & 0x07) << 3;
    cr1.* |= SPI_CR1_MSTR | SPI_CR1_SSM | SPI_CR1_SSI;
    cr1.* |= SPI_CR1_SPE;
}
```

**SPI 数据收发函数：**

```zig
pub fn spi_transmit_byte(spi_base: u32, data: u8) u8 {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    const dr = get_reg(spi_base, SPI_DR_OFFSET);
    
    while ((sr.* & SPI_SR_TXE) == 0) {}  // 等待发送缓冲区空
    @as(*volatile u8, @ptrCast(dr)).* = data;
    while ((sr.* & SPI_SR_RXNE) == 0) {} // 等待接收缓冲区非空
    return @as(*volatile u8, @ptrCast(dr)).*;
}
```

#### 3.2.2 UART 驱动模块（uart.zig）

**UART 初始化：**

```zig
pub fn uart_init() void {
    // 使能时钟、配置GPIO复用、设置波特率
    RCC_AHB1ENR.* |= (1 << 0);
    RCC_APB2ENR.* |= (1 << 4);
    USART1_BRR.* = ct.clk_get_pclk2() / 115200;
    USART1_CR1.* |= (1 << 3) | (1 << 2) | (1 << 13); // TE|RE|UE
}
```

**UART 发送函数：**

```zig
pub fn uart_print(str: []const u8) void {
    for (str) |byte| {
        while ((USART1_SR.* & (1 << 7)) == 0) {}
        USART1_DR.* = byte;
    }
}
```

#### 3.2.3 主程序文件（main.zig）

**SPI2 引脚配置：**

| 引脚 | 功能 | 说明 |
|------|------|------|
| PC2 | SPI2_MISO | AF5 |
| PC3 | SPI2_MOSI | AF5 |
| PB13 | SPI2_SCK | AF5 |
| PB12 | CS | GPIO输出 |

**SPI Flash ID 读取：**

```zig
fn spi_flash_read_id() void {
    var id: [3]u8 = undefined;
    
    flash_cs_low();                                    // 选中Flash
    _ = spi.spi_transmit_byte(spi.SPI2_BASE, 0x9F);    // 发送读ID命令
    id[0] = spi.spi_transmit_byte(spi.SPI2_BASE, 0xFF);
    id[1] = spi.spi_transmit_byte(spi.SPI2_BASE, 0xFF);
    id[2] = spi.spi_transmit_byte(spi.SPI2_BASE, 0xFF);
    flash_cs_high();                                   // 释放Flash
    
    uart.uart_print("SPI Flash ID: ");
    uart.print_hex(id[0]);
    // ...
}
```

#### 3.2.4 关键知识点

1. **SPI Flash ID 读取流程**：拉低CS → 发送0x9F命令 → 读取3字节ID → 拉高CS
2. **SPI2 引脚配置**：PC2(MISO)、PC3(MOSI)、PB13(SCK)、PB12(CS)
3. **SPI 时钟配置**：SPI2挂载在APB1总线，波特率 = PCLK1 / 8

### 3.3 编译和运行

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

---

## SPI 配置详解

### 4.1 SPI 时钟使能

```zig
RCC_APB2ENR.* |= (1 << 12); // SPI1EN (APB2)
RCC_APB1ENR.* |= (1 << 14); // SPI2EN (APB1)
```

### 4.2 波特率配置

| BR[2:0] | 分频系数 |
|---------|----------|
| 000 | 2 |
| 010 | 8 |
| 011 | 16 |
| 111 | 256 |

---

## SPI Flash 操作

### 5.1 常见 SPI Flash ID

| 制造商 | ID[0] | ID[1] |
|--------|-------|-------|
| Winbond | 0xEF | 0x40 |
| Micron | 0x20 | 0x20 |
| Macronix | 0xC2 | 0x20 |

### 5.2 SPI Flash 常用命令

| 命令 | 代码 | 功能 |
|------|------|------|
| READ_ID | 0x9F | 读取JEDEC ID |
| READ | 0x03 | 读取数据 |
| PAGE_PROGRAM | 0x02 | 页编程 |
| SECTOR_ERASE | 0x20 | 扇区擦除 |
| WRITE_ENABLE | 0x06 | 写使能 |

---

## 常见问题

### SPI 初始化失败
- 检查 SPI 时钟是否正确使能
- 确认 GPIO 引脚配置是否正确
- 检查 SPI 模式配置是否与从机匹配

### Flash ID 读取失败
- 检查 CS 片选信号是否正确控制
- 确认 SPI Flash 是否正确连接
- 验证 SPI Flash 是否支持 0x9F 命令

---

## 扩展学习

- **SPI DMA 传输**：提高传输效率，减少 CPU 占用
- **SPI 中断模式**：实现非阻塞传输
- **SPI Flash 其他操作**：读取数据、页编程、扇区擦除等

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
