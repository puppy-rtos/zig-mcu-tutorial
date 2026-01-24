# 快速在 MCU 上运行 Zig 程序

## 🚀 开篇引言

欢迎来到 Zig 单片机教程的第三课！

在上节课中，我们已经完成了 Zig 开发环境的搭建。本节课将带你使用 zig 直接构建一个可以在 STM32F407 微控制器上运行的最简工程。这种方式适合快速原型开发和学习，能够让我们更直观地了解 Zig 编译 MCU 程序的过程。

---

## 🎯 学习目标

通过本节课的学习，你将能够：

- ✅ 理解 Zig 编译 MCU 程序的基本原理
- ✅ 创建最简的 STM32F407 工程结构
- ✅ 编写直接操作寄存器的 LED 闪烁程序
- ✅ 编译并生成可烧录的二进制文件
- ✅ 将程序烧录到开发板并运行

---

## ⚡ 环境准备

### 2.1 软件环境

确保您已完成第二节教程中的环境搭建，包括：
- ✅ 安装了 Zig 编译器（0.15.2+）
- ✅ 配置了正确的环境变量

### 2.2 硬件环境

#### 推荐开发板

- **🔥 星火1号开发板**：基于 STM32F407VET6 芯片，支持 USB 虚拟 U 盘烧录，便于快速开发和测试

#### 其他兼容开发板

任何基于 STM32F407 系列芯片的开发板都可以使用，例如：
- STM32F407VGT6 开发板
- STM32F407ZET6 开发板
- 自定义设计的 STM32F407 硬件

#### 硬件连接要求

- 🔌 USB 数据线：用于连接开发板和电脑，进行程序烧录和调试
- （可选）调试器：如 ST-Link、J-Link 等，用于高级调试（星火1号可通过 USB 直接烧录，无需额外调试器）

---

## 📁 工程结构

在不使用 `build.zig` 的情况下，我们需要手动创建以下文件（仓库里已经提供了一个示例工程结构）：

```
example-project/
├── src/
│   ├── main.zig         # 主程序文件（Zig）
│   ├── startup.zig      # 启动文件（Zig 实现）
│   └── link.ld          # 链接脚本
└── README.md            # 项目说明
```

---

## 🔍 启动文件和链接脚本分析

### 4.1 启动文件分析

#### 4.1.1 Zig 启动文件（startup.zig）

`startup.zig` 是使用 Zig 实现的启动文件，它包含：
- 📋 简化的向量表，只包含初始栈指针和复位向量
- 🚀 `_start` 函数，负责初始化微控制器状态
- 🔗 桥接函数，调用 `main.zig` 中的 `main` 函数

**核心代码片段**：

```zig
// 简化的向量表，只包含初始栈指针和复位向量
export const vector_table: VectorTable linksection("vector") = .{
    .initial_stack_pointer = 0x20001000, // 栈顶地址
    .Reset = _start, // 复位向量
};

// 启动函数 - 程序入口点
export fn _start() callconv(.c) noreturn {
    // 设置栈指针
    asm volatile ("ldr sp, =microzig_stack_end");

    // 初始化.bss段（清零）
    @memset(&microzig_bss_start, 0, @intFromPtr(&microzig_bss_end) - @intFromPtr(&microzig_bss_start));

    // 从flash复制.data段到RAM
    @memcpy(&microzig_data_start, &microzig_data_load_start,
        @intFromPtr(&microzig_data_end) - @intFromPtr(&microzig_data_start));

    // 调用主函数
    main();
}
```

### 4.2 链接脚本分析

#### 4.2.1 Zig 项目链接脚本（link.ld）

`link.ld` 是为这个项目定制的链接脚本，它定义了：
- 🗺️ 内存布局（FLASH、RAM）
- 📦 段定义（.text、.ARM.exidx、.data、.bss 等）
- 🎯 入口点为 `_start` 函数
- 🏷️ 用于初始化的符号定义（microzig_*）

**核心代码片段**：

```ld
ENTRY(_start);

MEMORY
{
  flash0    (rx!w) : ORIGIN = 0x08000000, LENGTH = 0x00200000  /* 2MB Flash */
  ram0      (rw!x) : ORIGIN = 0x20000000, LENGTH = 0x00010000  /* 64KB RAM */
}

SECTIONS
{
  .text :
  {
    KEEP(*(vector))      /* 向量表 */
    *(.text*)            /* 代码段 */
  } > flash0

  .data :
  {
     microzig_data_start = .;  /* 数据段起始 */
     *(.rodata*)             /* 只读数据 */
     *(.data*)               /* 可读写数据 */
     microzig_data_end = .;    /* 数据段结束 */
  } > ram0 AT> flash0  /* 数据段加载到RAM，初始值存储在Flash */

  .bss (NOLOAD) :
  {
      microzig_bss_start = .;   /* BSS段起始 */
      *(.bss*)                 /* 未初始化数据 */
      microzig_bss_end = .;     /* BSS段结束 */
      . = ALIGN(4);
      microzig_stack_start = .; /* 栈起始 */
      . = . + 0x800;          /* 2KB堆栈 */
      microzig_stack_end = .;   /* 栈结束 */
  } > ram0
}
```

---

## 💡 创建主程序文件

主程序是我们的应用逻辑，这里我们创建一个 LED 闪烁的示例，展示了如何直接操作寄存器控制硬件。

创建 `src/main.zig` 文件：

```zig
// STM32F407寄存器地址
const RCC_BASE = 0x40023800;
const GPIOF_BASE = 0x40021400;

// RCC寄存器
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));

// GPIOF寄存器
const GPIOF_MODER = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x00));
const GPIOF_ODR = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x14));

// LED引脚
const LED_PIN = 11;

pub fn main() noreturn {
    // 启用GPIOF时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 5); // GPIOF的时钟使能位是第5位
    
    // 设置PF11为输出模式
    GPIOF_MODER.* &= ~@as(u32, 0b11 << (LED_PIN * 2)); // 清除现有设置
    GPIOF_MODER.* |= @as(u32, 0b01 << (LED_PIN * 2));  // 设置为输出模式
    
    // 主循环
    while (true) {
        // 点亮LED (低电平)
        GPIOF_ODR.* &= ~@as(u32, 1 << LED_PIN);
        
        // 延迟
        delay_ms(1000);
        
        // 熄灭LED（高电平）
        GPIOF_ODR.* |= @as(u32, 1 << LED_PIN);
        
        // 延迟
        delay_ms(1000);
    }
}
```

> 💡 **提示**：这个示例展示了 zig 也具有和 c 一样的直接操作硬件寄存器的能力，展示了嵌入式开发的底层原理。在实际项目中，你可以使用更高级的抽象来简化开发。

---

## 🔨 编译项目

使用 `zig build-exe` 命令直接编译项目，生成可执行文件：

```bash
cd example-project
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O ReleaseSmall --name stm32f407
```

**命令参数详解**：
- `src/startup.zig`：主程序入口文件（包含启动代码和向量表）
- `-target thumb-freestanding-none`：目标架构为 thumb 指令集，无操作系统
- `-mcpu cortex_m4`：目标 CPU 为 Cortex-M4
- `-T src/link.ld`：指定链接脚本路径
- `-O ReleaseSmall`：优化级别为 ReleaseSmall，生成最小的二进制文件
- `--name stm32f407`：指定生成的可执行文件名称为 `stm32f407`

编译完成后，会在当前目录生成 `stm32f407`（ELF 格式）文件。

---

## 📦 生成二进制文件

### ⚠️ 注意事项

**重要：** 由于 Zig 0.15.0 以上版本 `zig objcopy` 生成的 bin 文件存在问题，建议使用 Zig 0.14.1 版本或者  `arm-none-eabi-objcopy` 来生成 bin 文件。问题详见：https://github.com/ziglang/zig/issues/25653

### 使用 `zig objcopy`（仅适用于 0.15.0 以下版本）

```bash
zig objcopy -O binary stm32f407 stm32f407.bin
```

### 使用 `arm-none-eabi-objcopy`

```bash
arm-none-eabi-objcopy -O binary stm32f407 stm32f407.bin
```

---

## ✅ 验证生成的文件

可以使用 `arm-none-eabi-objdump` 或 `arm-none-eabi-readelf` 工具查看生成的 ELF 文件信息：

```bash
arm-none-eabi-objdump -h stm32f407
```

**预期输出**：
```
stm32f407:     file format elf32-littlearm

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         000000be  08000000  08000000  00010000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .ARM.exidx    00000028  080000c0  080000c0  000100c0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .data         00000000  20000000  20000000  000100e8  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .bss          00000800  20000000  20000000  00020000  2**0
                  ALLOC
  4 .ARM.attributes 0000003d  00000000  00000000  00020000  2**0
                  CONTENTS, READONLY
  5 .comment      00000067  00000000  00000000  0002003d  2**0
                  CONTENTS, READONLY
```

---

## ❓ 常见问题及解决方法

### Q1：LED 不闪烁

**现象**：程序编译成功并烧录到 MCU 中，但 LED 不闪烁。

**原因**：
1. 引脚配置错误
2. 时钟使能错误
3. 延迟函数参数不正确

**解决方法**：
1. 检查 LED 连接的引脚号是否正确
2. 确保对应的 GPIO 时钟已被正确使能
3. 调整延迟函数中的 `cycles_per_ms` 值，使其适应实际的系统时钟频率

---

## 📤 烧录程序到 MCU

### 11.1 星火1号开发板（推荐）

如果您使用的是 **🔥 星火1号开发板**，可以直接通过以下方式烧录程序：
1. 将开发板通过 USB 连接到电脑
2. 开发板会被识别为一个虚拟 U 盘
3. 直接将生成的 `stm32f407.bin` 文件拖拽到这个虚拟 U 盘中
4. 系统会自动完成程序下载和烧录

> 💡 **提示**：星火1号开发板的虚拟 U 盘烧录方式非常便捷，无需额外的调试器或烧录软件。

### 11.2 其他开发板

对于其他 STM32F407 开发板，可以使用以下工具烧录程序：
- ST-Link Utility
- J-Link
- pyocd

具体烧录方法请参考您使用的调试工具的文档。

---

## 📢 下节预告

Zig 语言基础（了解嵌入式开发必备语法）

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
