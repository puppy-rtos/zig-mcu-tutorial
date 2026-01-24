# 最简STM32F407点灯示例

这是一个基于Zig语言的STM32F407最简点灯示例，只包含3个核心文件：
- `startup.zig` - 启动代码和向量表
- `main.zig` - 主程序，实现点灯逻辑
- `link.ld` - 链接脚本

## 功能说明

该示例实现了一个简单的LED闪烁功能，使用PF11引脚控制LED，每秒闪烁一次。

## 编译步骤

### 1. 编译ELF文件

在项目根目录执行以下命令：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -O ReleaseSmall -T src/link.ld --name stm32f407
```

### 2. 生成BIN文件

**注意：** 由于 0.15.0 以上版本 `zig objcopy`生成的bin文件有问题，建议使用`arm-none-eabi-objcopy`来生成bin文件：

```bash
arm-none-eabi-objcopy -O binary stm32f407 stm32f407.bin
```

如果使用 0.15.0 以下版本 `zig objcopy`，可以使用以下命令：

```bash
zig objcopy -O binary stm32f407 stm32f407.bin
```

## 烧录

### 星火1号开发板（推荐）

1. 将开发板通过 USB 连接到电脑
2. 开发板会被识别为一个虚拟 U 盘
3. 直接将生成的 `stm32f407.bin` 文件拖拽到这个虚拟 U 盘中
4. 系统会自动完成程序下载和烧录

### 其他开发板

使用你喜欢的烧录工具（如ST-Link Utility、pyocd等）将生成的BIN文件烧录到STM32F407开发板中。

## 目录结构

```
example-project/
├── src/
│   ├── main.zig       # 主程序
│   ├── link.ld        # 链接脚本
│   └── startup.zig    # 启动代码
└── README.md          # 说明文档
```

## 注意事项

1. 确保你已经安装了Zig编译器（推荐0.14.1或更高版本）
2. 该示例针对STM32F407芯片，如果你使用其他芯片，可能需要调整寄存器地址和链接脚本
3. 0.15.0 以上版本 `zig objcopy`生成的bin文件有问题，建议使用`arm-none-eabi-objcopy`。问题详见：https://github.com/ziglang/zig/issues/25653

