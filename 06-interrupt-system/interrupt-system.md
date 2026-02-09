# 中断系统实战：按键控制 LED

## 🚀 开篇引言

欢迎来到 Zig 单片机教程的第六课！

上节课我们学习了如何搭建 Zig MCU 的单步调试环境，掌握了使用 VSCode + ST-Link + pyocd 进行调试的方法。本节课将重点介绍如何在 Zig 中实现 STM32F407 的外部中断系统，通过按键控制 LED 的亮灭状态，让你深入了解嵌入式系统中中断的工作原理和实现方法。

---

## 🎯 学习目标

通过本节课的学习，你将能够：

- ✅ 理解 STM32F407 中断系统的工作原理
- ✅ 掌握外部中断/事件控制器（EXTI）的配置方法
- ✅ 了解系统配置控制器（SYSCFG）的使用
- ✅ 实现中断处理函数和中断向量表扩展
- ✅ 掌握按键状态检测的方法
- ✅ 通过中断方式实现硬件事件的响应

---

## 📋 工具准备

### 1.1 必要工具清单

| 工具 | 版本/要求 | 用途 |
|------|-----------|------|
| VSCode | 最新版本 | 代码编辑和调试界面 |
| Zig | 0.15.0+ | 编译工具链 |
| ARM GCC | 12.2+ | 提供 GDB 调试工具 |
| pyocd | 最新版本 | ARM Cortex-M 调试工具 |
| ST-Link 驱动 | 最新版本 | ST-Link 调试器驱动 |
| Cortex-Debug | VSCode 插件 | 提供 ARM Cortex-M 调试支持 |

### 1.2 硬件准备

| 硬件 | 说明 |
|------|------|
| 星火1号开发板 | STM32F407 |
| ST-Link 调试器 | 用于烧录和调试 |
| 按键 | PC5（有上拉电阻） |
| LED | PF11 |

---

## 🔧 中断系统基础知识

### 2.1 STM32F407 中断系统架构

STM32F407 采用嵌套向量中断控制器（NVIC）和外部中断/事件控制器（EXTI）来管理中断系统：

- **NVIC**：负责中断的优先级管理和中断的使能/禁用
- **EXTI**：负责外部中断的配置和触发方式设置
- **SYSCFG**：负责将 GPIO 引脚连接到 EXTI 线

### 2.2 外部中断的工作原理

1. **GPIO 配置**：将 GPIO 引脚配置为输入模式，并设置上拉/下拉电阻
2. **SYSCFG 配置**：将 GPIO 引脚连接到对应的 EXTI 线
3. **EXTI 配置**：设置中断的触发方式（上升沿、下降沿或双边沿）
4. **NVIC 配置**：设置中断的优先级并使能中断
5. **中断处理**：当外部事件触发时，CPU 会跳转到对应的中断处理函数执行
6. **主循环处理**：在主循环中根据中断处理函数设置的状态执行相应的操作

### 2.3 中断向量表

中断向量表是存储中断处理函数地址的表格，当中断发生时，CPU 会根据中断号从向量表中找到对应的处理函数地址并执行。

---

## 📁 示例项目结构

### 3.1 项目文件

示例项目的完整代码可以在本教程的 `example-project` 目录中找到。

**注意：** 完整的源代码实现请参考本教程的 `example-project` 目录。

---

## 🚀 代码实现详解

### 4.1 启动文件修改 (`startup.zig`)

启动文件主要负责初始化系统和设置中断向量表。在本示例中，我们需要扩展向量表以包含 EXTI5-9 中断向量：

```zig
// 扩展的向量表，包含初始栈指针、复位向量和EXTI5中断向量
pub const VectorTable = extern struct {
    initial_stack_pointer: u32,
    Reset: *const fn () callconv(.c) noreturn,
    // ... 其他中断向量 ...
    // 外部中断
    WWDG: *const fn () callconv(.c) noreturn,
    PVD: *const fn () callconv(.c) noreturn,
    // ... 其他外部中断 ...
    EXTI5_9: *const fn () callconv(.c) void, // EXTI5-9共用一个中断
    EXTI10_15: *const fn () callconv(.c) noreturn, // EXTI10-15共用一个中断
};

// 声明外部EXTI5-9中断处理函数
extern fn exti5_9_handler() callconv(.c) void;

// 向量表实例，指向初始栈指针和各种中断处理函数
export const vector_table: VectorTable linksection("vector") = .{
    .initial_stack_pointer = 0x20001000, // 栈顶地址
    .Reset = _start, // 复位向量
    // ... 其他中断向量 ...
    .EXTI5_9 = exti5_9_handler, // EXTI5-9中断处理
    // ... 其他外部中断 ...
};
```

### 4.2 主程序实现 (`main.zig`)

主程序主要负责配置硬件和实现中断处理函数：

#### 4.2.1 寄存器定义

```zig
// STM32F407寄存器地址
const RCC_BASE = 0x40023800;
const GPIOF_BASE = 0x40021400;
const GPIOC_BASE = 0x40020800;
const SYSCFG_BASE = 0x40013800;
const EXTI_BASE = 0x40013C00;
const NVIC_BASE = 0xE000E100;

// 各种寄存器定义
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));
const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x44));
const GPIOF_MODER = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x00));
const GPIOF_ODR = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x14));
const GPIOC_MODER = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x00));
const GPIOC_PUPDR = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x0C));
const GPIOC_IDR = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x10));
const SYSCFG_EXTICR2 = @as(*volatile u32, @ptrFromInt(SYSCFG_BASE + 0x0C));
const EXTI_IMR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x00));
const EXTI_FTSR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x0C));
const EXTI_RTSR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x08));
const EXTI_PR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x14));
const NVIC_ISER0 = @as(*volatile u32, @ptrFromInt(NVIC_BASE + 0x00));
```

#### 4.2.2 全局变量和枚举类型

```zig
// 按键状态枚举类型
const ButtonState = enum {
    Released,
    Pressed,
};

// 全局变量，用于在中断和主函数之间共享状态
var button_state: ButtonState = .Released;
```

#### 4.2.3 中断处理函数

```zig
// EXTI5-9中断处理函数
pub export fn exti5_9_handler() callconv(.c) void {
    // 检查是否是EXTI5中断（对应PC5引脚）
    if (EXTI_PR.* & (1 << BUTTON_PIN) != 0) {
        // 清除中断标志
        EXTI_PR.* |= (1 << BUTTON_PIN);

        // 读取按键状态
        if (GPIOC_IDR.* & (1 << BUTTON_PIN) == 0) {
            // 按键被按下（低电平）
            button_state = .Pressed;
        } else {
            // 按键被释放（高电平，因为有上拉电阻）
            button_state = .Released;
        }
    }
}
```

#### 4.2.4 主函数

```zig
pub fn main() noreturn {
    // 启用各种时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 5); // GPIOF时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 2); // GPIOC时钟
    RCC_APB2ENR.* |= @as(u32, 1 << 14); // SYSCFG时钟
    
    // 配置GPIO
    GPIOF_MODER.* &= ~@as(u32, 0b11 << (LED_PIN * 2));
    GPIOF_MODER.* |= @as(u32, 0b01 << (LED_PIN * 2));
    
    // 配置PC5为输入模式并启用上拉电阻
    GPIOC_MODER.* &= ~@as(u32, 0b11 << (BUTTON_PIN * 2));
    GPIOC_PUPDR.* &= ~@as(u32, 0b11 << (BUTTON_PIN * 2));
    GPIOC_PUPDR.* |= @as(u32, 0b01 << (BUTTON_PIN * 2));
    
    // 配置SYSCFG，将PC5连接到EXTI5
    const exticr_shift = (BUTTON_PIN % 4) * 4;
    SYSCFG_EXTICR2.* &= ~(@as(u32, 0xF) << exticr_shift);
    SYSCFG_EXTICR2.* |= (@as(u32, 2) << exticr_shift); // 2表示GPIOC
    
    // 配置EXTI为双边沿触发
    EXTI_FTSR.* |= (1 << BUTTON_PIN); // 下降沿触发
    EXTI_RTSR.* |= (1 << BUTTON_PIN); // 上升沿触发
    EXTI_IMR.* |= (1 << BUTTON_PIN); // 启用中断
    
    // 启用NVIC中断
    const EXTI5_9_IRQn = 23;
    NVIC_ISER0.* |= (1 << EXTI5_9_IRQn);
    
    // 启用全局中断
    asm volatile ("cpsie i");
    
    // 初始化LED状态
    GPIOF_ODR.* |= @as(u32, 1 << LED_PIN);
    
    // 主循环
    while (true) {
        // 根据按键状态控制LED
        switch (button_state) {
            .Pressed => {
                // 按键被按下，点亮LED
                GPIOF_ODR.* &= ~@as(u32, 1 << LED_PIN);
            },
            .Released => {
                // 按键被释放，熄灭LED
                GPIOF_ODR.* |= @as(u32, 1 << LED_PIN);
            },
        }
        
        // 主循环中可以添加其他任务
        delay_ms(10);
    }
}
```

---

## 🔨 编译和调试

### 5.1 编译项目

在 `example-project` 目录执行以下命令编译项目：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

**命令参数详解**：
- `src/startup.zig`：主程序入口文件（包含启动代码和向量表）
- `-target thumb-freestanding-none`：目标架构为 thumb 指令集，无操作系统
- `-mcpu cortex_m4`：目标 CPU 为 Cortex-M4
- `-T src/link.ld`：指定链接脚本路径
- `-O Debug`：优化级别为 Debug，确保调试信息完整
- `--name stm32f407`：指定生成的可执行文件名称为 `stm32f407`

### 5.2 开始调试

1. **硬件连接**：将 ST-Link 调试器连接到星火1号开发板
2. **启动调试**：在 VSCode 中按下 `F5` 键或点击调试按钮
3. **调试操作**：
   - **单步执行**：`F10`（单步跳过）或 `F11`（单步进入）
   - **继续执行**：`F5`
   - **暂停执行**：`F6`
   - **设置断点**：点击代码行号左侧

### 5.3 测试方法

1. **编译并烧录**：使用上述编译命令编译项目，然后通过 ST-Link 烧录到开发板
2. **测试按键**：按下开发板上的 PC5 按键，观察 LED 是否点亮；释放按键，观察 LED 是否熄灭
3. **调试中断**：在 VSCode 中设置断点，观察中断处理函数的执行过程

---

## 🔍 中断调试技巧

### 6.1 中断断点设置

- 在中断处理函数中设置断点，观察中断触发时的执行流程
- 使用条件断点，只在特定条件下触发中断断点

### 6.2 中断状态查看

- 在调试控制台中使用 `info registers` 查看 CPU 寄存器状态
- 查看中断控制器相关寄存器的状态

### 6.3 变量监控

- 在 VSCode 的 "变量" 面板中监控全局变量的变化
- 使用 "监视" 功能监控特定变量

---

## ❌ 常见问题和解决方案

### 7.1 中断不触发

**问题**：按键按下后，中断没有触发

**解决方案**：
- 检查 GPIO 配置是否正确
- 检查 SYSCFG 配置是否正确，确保 GPIO 引脚正确连接到 EXTI 线
- 检查 EXTI 配置是否正确，确保中断触发方式和中断使能设置正确
- 检查 NVIC 配置是否正确，确保中断优先级和中断使能设置正确

### 7.2 按键状态检测问题

**问题**：按键状态检测不准确

**解决方案**：
- 确保正确配置了上拉/下拉电阻
- 可以考虑添加延时消抖
- 检查中断触发方式是否适合你的应用场景

### 7.3 中断优先级问题

**问题**：多个中断同时触发时，优先级较低的中断被忽略

**解决方案**：
- 合理设置中断优先级
- 确保中断处理函数执行时间尽可能短

### 7.4 编译错误

**问题**：编译时出现错误

**解决方案**：
- 检查 Zig 版本是否为 0.15.0+
- 检查代码中的语法错误
- 检查寄存器地址是否正确

---

## 📁 项目结构

本节教程的项目结构如下：

```
06-interrupt-system/
├── README.md              # 课程说明
├── interrupt-system.md   # 主教程内容
└── example-project/       # 示例项目
    ├── src/
    │   ├── main.zig       # 主程序文件（Zig）
    │   ├── startup.zig    # 启动文件（包含扩展的向量表）
    │   └── link.ld        # 链接脚本
    └── .vscode/
        └── launch.json    # VSCode 调试配置
```

---

## 📢 下节预告

定时器应用：精准延时与 LED 闪烁

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
