# Zig MCU QEMU仿真示例

这是一个基于Zig语言的STM32F407 QEMU仿真示例，用于演示如何使用QEMU进行Zig代码的在线仿真和调试。

## 功能说明

该示例实现了一个简单的UART打印功能，使用USART1（PA9/PA10）通过串口打印"Hello Zig from MCU!"消息，每秒打印一次。同时，该示例配置了完整的调试环境，可以在VSCode中进行单步调试、断点设置、变量监控等操作。

## 编译步骤

### 1. 编译ELF文件

在项目根目录执行以下命令：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

## 调试步骤

### 1. 启动QEMU调试模式

在项目根目录执行以下命令启动QEMU调试模式：

```bash
.\run-qemu-debug.bat
```

### 2. VSCode 调试配置

项目已经包含了 `.vscode/launch.json` 配置文件，配置内容如下：

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
- `servertype` 设置为 `external`，表示使用外部GDB服务器（QEMU）
- `gdbTarget` 设置为 `localhost:1234`，连接到QEMU的GDB服务器
- `gdbPath` 需要设置为实际的 ARM GCC 工具链中的 GDB 可执行文件路径
- 编译时使用 `-O Debug` 优化等级，确保调试信息完整

### 3. 开始调试

1. 首先启动QEMU调试模式：`.\run-qemu-debug.bat`
2. 在VSCode中打开该项目
3. 按下 `F5` 键或点击调试按钮
4. 开始进行调试操作：
   - **单步执行**：`F10`（单步跳过）或 `F11`（单步进入）
   - **继续执行**：`F5`
   - **暂停执行**：`F6`
   - **设置断点**：点击代码行号左侧

### 4. 查看变量和寄存器

在调试过程中，可以：

1. **查看变量**：在VSCode的 "变量" 面板中查看当前变量值
2. **添加监视**：右键点击变量，选择 "添加到监视"
3. **查看寄存器**：在 "调试控制台" 中输入 `info registers`
4. **查看内存**：在 "调试控制台" 中输入 `x/10x 0x20000000`

### 5. 运行程序（非调试模式）

如果只是想运行程序而不进行调试，可以执行：

```bash
.\run-qemu.bat
```

程序会通过QEMU的串口输出"Hello Zig from MCU!"消息。

## 目录结构

```
example-project/
├── src/
│   ├── main.zig       # 主程序文件
│   ├── startup.zig    # 启动文件
│   └── link.ld        # 链接脚本
├── .vscode/
│   └── launch.json    # VSCode 调试配置
└── README.md          # 说明文档
```

## 注意事项

1. 确保你已经安装了以下工具：
   - VSCode
   - QEMU（本教程使用路径：`D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe`）
   - ARM GCC 工具链
   - Cortex-Debug VSCode 插件
   - Zig 编译器（0.15.0+）

2. 该示例针对STM32F407芯片，使用QEMU的olimex-stm32-h405机器类型进行仿真

3. 如果你的QEMU安装路径不同，请修改 `run-qemu.bat` 和 `run-qemu-debug.bat` 中的路径

4. 调试过程中，如果遇到连接问题，可以尝试：
   - 确保QEMU调试模式已经启动
   - 检查GDB路径是否正确
   - 确认端口号（默认为1234）没有被占用
   - 重启VSCode和QEMU

5. 该示例与第5节教程使用相同的代码结构，只是将LED闪烁功能改为UART打印功能，并配置了QEMU调试环境

6. QEMU的串口输出会重定向到控制台，运行 `run-qemu.bat` 后可以看到"Hello Zig from MCU!"的输出
