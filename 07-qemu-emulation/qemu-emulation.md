# 使用QEMU在线仿真学习Zig

## 🚀 开篇引言

欢迎来到 Zig 单片机教程的第七课！

由于春节假期没有带硬件开发板，本节课我们将调整为使用 QEMU 在线仿真来学习 Zig。QEMU 是一款功能强大的开源模拟器，可以模拟多种硬件平台，包括 ARM Cortex-M 系列处理器，这使得我们可以在没有实际硬件的情况下进行 Zig 代码的开发和调试。

本节课将重点介绍如何使用 QEMU 进行 Zig 代码的在线仿真和调试，包括 QEMU 的安装、运行、单步调试等相关内容。示例工程我们将直接使用第5节的LED闪烁代码，调试相关的内容也可以参考第5节的教程。

---

## 🎯 学习目标

通过本节课的学习，你将能够：

- ✅ 安装和配置 QEMU 仿真环境
- ✅ 理解 QEMU 仿真原理和基本概念
- ✅ 使用 QEMU 运行 Zig 编译的程序
- ✅ 掌握 QEMU 单步调试技巧
- ✅ 结合 VSCode 进行高效的开发和调试

---

## 📋 工具准备

### 1.1 必要工具清单

搭建完整的 QEMU 仿真环境需要以下工具：

| 工具 | 版本/要求 | 用途 |
|------|-----------|------|
| VSCode | 最新版本 | 代码编辑和调试界面 |
| Zig | 0.15.0+ | 编译工具链 |
| QEMU | 7.0+ | ARM Cortex-M 仿真器 |
| ARM GCC 工具链 | 12.2+ | 提供 GDB 调试工具 |
| Cortex-Debug | VSCode 插件 | VSCode 调试支持 |

### 1.2 QEMU 安装步骤

#### 1.2.1 下载 QEMU

1. 访问 [QEMU 官网](https://www.qemu.org/download/) 下载最新版本的 QEMU
2. 或者使用已安装的 QEMU（本教程使用路径：`D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe`，版本为 8.0.94）

#### 1.2.2 验证 QEMU 安装

打开命令提示符，执行以下命令验证 QEMU 是否安装成功：

```bash
qemu-system-arm --version
```

如果安装成功，你将看到 QEMU 的版本信息。本教程使用的 QEMU 版本为 8.0.94。

#### 1.2.3 安装 VSCode 插件

在 VSCode 中安装以下插件：

1. **Cortex-Debug** - 提供 ARM Cortex-M 调试支持
2. **Zig** - 提供 Zig 语言支持

---

## 🖥️ QEMU 基本用法

### 2.1 QEMU 仿真原理

QEMU 通过软件模拟硬件平台的运行环境，包括：

- CPU 指令集仿真
- 内存系统仿真
- 外设寄存器仿真
- 中断系统仿真

对于 ARM Cortex-M 系列，QEMU 支持多种开发板的仿真，如 `stellaris lm3s6965evb`、`olimex-stm32-h405` 等。

### 2.2 常用 QEMU 命令行参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `-machine` | 指定仿真的机器类型 | `-machine olimex-stm32-h405` |
| `-cpu` | 指定仿真的 CPU 类型 | `-cpu cortex-m4` |
| `-kernel` | 指定要运行的内核/程序 | `-kernel stm32f407` |
| `-gdb` | 启用 GDB 调试端口 | `-gdb tcp::1234` |
| `-S` | 启动时暂停执行，等待 GDB 连接 | `-S` |
| `-nographic` | 无图形界面模式 | `-nographic` |
| `-serial` | 串口配置 | `-serial stdio` |

### 2.3 QEMU 支持的开发板清单

本教程使用的 QEMU 版本（8.0.94）支持以下开发板类型：

| 开发板 | 机器类型 | CPU类型 | 说明 |
|--------|----------|--------|------|
| stellaris lm3s6965evb | lm3s6965evb | Cortex-M3 | Stellaris LM3S6965评估板 |
| lm3s811evb | lm3s811evb | Cortex-M3 | Stellaris LM3S811评估板 |
| olimex-stm32-h405 | olimex-stm32-h405 | Cortex-M4 | Olimex STM32-H405开发板（本教程使用） |
| stm32vldiscovery | stm32vldiscovery | Cortex-M3 | ST STM32VLDISCOVERY |
| mps2-an385 | mps2-an385 | Cortex-M3 | ARM MPS2 with AN385 FPGA |
| mps2-an386 | mps2-an386 | Cortex-M4 | ARM MPS2 with AN386 FPGA |
| mps2-an500 | mps2-an500 | Cortex-M7 | ARM MPS2 with AN500 FPGA |
| microbit | microbit | Cortex-M0 | BBC micro:bit |
| netduino2 | netduino2 | Cortex-M3 | Netduino 2 Machine |
| netduinoplus2 | netduinoplus2 | Cortex-M4 | Netduino Plus 2 Machine |

**注意**：本教程使用 `olimex-stm32-h405` 机器类型，因为它支持 Cortex-M4 处理器，适合 STM32F407 的仿真。

### 2.3 启动 QEMU 仿真

使用以下命令启动 QEMU 仿真（以 STM32F407 为例）：

```bash
qemu-system-arm.exe \
    -machine olimex-stm32-h405 \
    -cpu cortex-m4 \
    -kernel stm32f407 \
    -serial stdio
```

### 2.4 启动 QEMU 调试模式

使用以下命令启动 QEMU 调试模式：

```bash
qemu-system-arm.exe \
    -machine olimex-stm32-h405 \
    -cpu cortex-m4 \
    -kernel stm32f407 \
    -gdb tcp::1234 \
    -S \
    -serial stdio
```

参数说明：
- `-gdb tcp::1234`：启用 GDB 调试端口，监听 1234 端口
- `-S`：启动时暂停执行，等待 GDB 连接

---

## 🔧 VSCode 调试配置

### 3.1 创建调试配置文件

在项目根目录创建 `.vscode/launch.json` 文件：

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
            "gdbPath": "arm-none-eabi-gdb",
            "gdbTarget": "localhost:1234"
        }
    ]
}
```

### 3.2 配置说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `name` | 调试配置名称 | Debug with QEMU |
| `type` | 调试类型 | cortex-debug |
| `request` | 调试请求类型 | launch |
| `servertype` | 调试服务器类型 | external |
| `cwd` | 工作目录 | ${workspaceFolder} |
| `executable` | 可执行文件路径 | ${workspaceFolder}/stm32f407 |
| `runToEntryPoint` | 运行到入口点 | main |
| `targetId` | 目标设备ID | cortex-m4 |
| `gdbPath` | GDB可执行文件路径 | arm-none-eabi-gdb |
| `gdbTarget` | GDB连接目标 | localhost:1234 |

---

## 📁 示例项目

### 4.1 项目结构

本节教程的项目结构如下（与第5节教程保持一致，添加了QEMU相关运行脚本）：

```
07-qemu-emulation/
├── README.md              # 课程说明
├── qemu-emulation.md      # 主教程内容
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

### 4.2 编译项目

在 `example-project` 目录执行以下命令编译项目（与第5节教程保持一致）：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

### 4.3 运行项目

#### 4.3.1 使用脚本运行

项目已经包含了 `run-qemu.bat` 脚本，直接执行即可运行项目：

```bash
run-qemu.bat
```

脚本内容如下：

```batch
@echo off
"D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe" ^
    -machine olimex-stm32-h405 ^
    -cpu cortex-m4 ^
    -kernel stm32f407 ^
    -serial stdio
```

#### 4.3.2 调试项目

项目已经包含了 `run-qemu-debug.bat` 脚本，用于启动 QEMU 调试模式：

```bash
run-qemu-debug.bat
```

脚本内容如下：

```batch
@echo off
"D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe" ^
    -machine olimex-stm32-h405 ^
    -cpu cortex-m4 ^
    -kernel stm32f407 ^
    -gdb tcp::1234 ^
    -S ^
    -serial stdio
```

然后在 VSCode 中按下 `F5` 键启动调试，使用调试工具栏进行单步执行、断点设置等操作。

### 4.4 VSCode 调试配置

项目已经配置了 VSCode 调试环境，`launch.json` 文件内容如下：

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

**配置说明**：
- `servertype`: 设置为 `external`，表示使用外部GDB服务器（QEMU）
- `gdbTarget`: 设置为 `localhost:1234`，连接到QEMU的GDB服务器
- `gdbPath`: 设置为实际的ARM GCC工具链中的GDB可执行文件路径

---

## 🐛 常见问题和解决方案

### 5.1 QEMU 启动失败

**问题**：QEMU 启动时出现错误

**解决方案**：
- 检查 QEMU 路径是否正确
- 确保编译的程序与 QEMU 模拟的硬件兼容
- 尝试使用不同的机器类型，如 `stellaris lm3s6965evb`

### 5.2 调试连接问题

**问题**：VSCode 无法连接到 QEMU 进行调试

**解决方案**：
- 确保 QEMU 已在调试模式下启动
- 检查 GDB 路径是否正确配置
- 确认端口号（默认为 1234）没有被占用

### 5.3 性能优化

**问题**：QEMU 仿真速度较慢

**解决方案**：
- 关闭不必要的图形界面，使用 `-nographic` 参数
- 减少调试信息，适当调整编译优化级别
- 确保计算机资源充足（CPU 和内存）

### 5.4 硬件差异

**问题**：QEMU 仿真结果与实际硬件不一致

**解决方案**：
- 理解 QEMU 是软件仿真，与实际硬件存在差异
- 对于关键功能，最终还是需要在实际硬件上验证
- 参考 QEMU 文档了解支持的硬件特性

---

## 📢 下节预告

UART通信实战：使用Zig实现串口打印

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*