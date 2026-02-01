# 搭建 Zig MCU 单步调试环境（基于 VSCode + ST-Link + pyocd）

## 🚀 开篇引言

欢迎来到 Zig 单片机教程的第五课！

上节课我们学习了 Zig 语言的基础知识，掌握了核心语法和编程概念。本节课将重点介绍如何搭建 Zig MCU 的单步调试环境，使用 VSCode + ST-Link + pyocd 实现代码的单步执行、断点设置、变量查看等功能，让你在开发过程中更加得心应手。

---

## 🎯 学习目标

通过本节课的学习，你将能够：

- ✅ 安装和配置必要的调试工具
- ✅ 在 VSCode 中设置调试环境
- ✅ 使用 ST-Link 进行硬件连接和调试
- ✅ 掌握 pyocd 调试命令和配置
- ✅ 实现 Zig 代码的单步调试
- ✅ 查看和监控变量状态

---

## 📋 工具准备

### 1.1 必要工具清单

搭建完整的调试环境需要以下工具：

| 工具 | 版本/要求 | 用途 |
|------|-----------|------|
| VSCode | 最新版本 | 代码编辑和调试界面 |
| Python | 3.7+ | 运行 pyocd |
| pyocd | 最新版本 | ARM Cortex-M 调试工具 |
| ST-Link 驱动 | 最新版本 | ST-Link 调试器驱动 |
| Cortex-Debug | VSCode 插件 | VSCode 调试支持 |
| Zig | 0.15.0+ | 编译工具链 |
| 星火1号开发板 | STM32F407 | 硬件平台 |

### 1.2 工具安装步骤

#### 1.2.1 安装 Python

1. 访问 [Python 官网](https://www.python.org/downloads/) 下载最新版本的 Python
2. 运行安装程序，勾选 "Add Python to PATH"
3. 完成安装后，打开命令提示符验证：

```bash
python --version
pip --version
```

#### 1.2.2 安装 pyocd

使用 pip 安装 pyocd：

```bash
pip install pyocd
```

验证安装：

```bash
pyocd --version
```

#### 1.2.3 安装 ST-Link 驱动

**注意：Windows 10 及以上系统通常会自动安装 ST-Link 驱动，无需手动下载和安装。**

如果系统未自动安装驱动，可以按照以下步骤手动安装：

1. 访问 [ST 官网](https://www.st.com/content/st_com/en/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-utilities/stsw-link009.html)
2. 下载并安装 ST-Link 驱动
3. 安装完成后，连接 ST-Link 调试器，系统应能正确识别

#### 1.2.4 安装 VSCode 插件

在 VSCode 中安装以下插件：

1. **Cortex-Debug** - 提供 ARM Cortex-M 调试支持
2. **Zig** - 提供 Zig 语言支持

---

## 🔧 VSCode 调试配置

### 2.1 创建调试配置文件

在项目根目录创建 `.vscode/launch.json` 文件：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug with PyOCD",
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "pyocd",
            "cwd": "${workspaceFolder}",
            "executable": "${workspaceFolder}/example-project/stm32f407",
            "runToEntryPoint": "main",
            "targetId": "stm32f412xe",
            "gdbPath": "D:/Progrem/arm-gnu-toolchain-12.2.rel1/bin/arm-none-eabi-gdb"
        }
    ]
}
```

**配置说明**：
- `targetId` 使用 `stm32f412xe` 是因为 pyocd 内置了该芯片的下载算法，可以直接烧录 F407 芯片
- `gdbPath` 需要设置为实际的 ARM GCC 工具链中的 GDB 可执行文件路径
- 编译时使用 `-O Debug` 优化等级，确保调试信息完整

### 2.2 配置说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `name` | 调试配置名称 | Debug with PyOCD |
| `type` | 调试类型 | cortex-debug |
| `request` | 调试请求类型 | launch |
| `servertype` | 调试服务器类型 | pyocd |
| `cwd` | 工作目录 | ${workspaceFolder} |
| `executable` | 可执行文件路径 | ${workspaceFolder}/example-project/stm32f407 |
| `runToEntryPoint` | 运行到入口点 | main |
| `targetId` | 目标设备ID | stm32f412xe (用于烧录F407芯片) |
| `gdbPath` | GDB可执行文件路径 | 实际的ARM GCC工具链路径 |

---

## 📁 示例项目结构

### 3.1 项目文件
本节教程的项目结构如下（与第3节教程保持一致）：

```
05-debug-environment/
├── README.md              # 课程说明
├── debug-environment.md   # 主教程内容
└── example-project/       # 示例项目
    ├── src/
    │   ├── main.zig       # 主程序文件（Zig）
    │   ├── startup.zig    # 启动文件（Zig 实现）
    │   └── link.ld        # 链接脚本
    └── .vscode/
        └── launch.json    # VSCode 调试配置
```

示例项目的完整代码可以在本教程的 `example-project` 目录中找到，与第3节教程保持一致。

**注意：** 完整的源代码实现请访问Git 仓库，查看本教程的 `example-project` 目录。

---

## 🚀 编译和调试

### 4.1 编译项目

在 `example-project` 目录执行以下命令编译项目（与第3节教程保持一致，只是优化等级改为了 Debug，方便单步调试）：

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

编译成功后，会在当前目录生成 `stm32f407`（ELF 格式）文件。

### 4.2 开始调试

1. **连接硬件**：将 ST-Link 调试器连接到星火1号开发板
2. **启动调试**：在 VSCode 中按下 `F5` 键或点击调试按钮
3. **调试操作**：
   - **单步执行**：`F10`（单步跳过）或 `F11`（单步进入）
   - **继续执行**：`F5`
   - **暂停执行**：`F6`
   - **设置断点**：点击代码行号左侧

### 4.3 查看变量和寄存器

在调试过程中，可以：

1. **查看变量**：在 VSCode 的 "变量" 面板中查看当前变量值
2. **添加监视**：右键点击变量，选择 "添加到监视"
3. **查看寄存器**：在 "调试控制台" 中输入 `info registers`
4. **查看内存**：在 "调试控制台" 中输入 `x/10x 0x20000000`

---


## 📢 下节预告

Zig 嵌入式开发进阶技巧

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*