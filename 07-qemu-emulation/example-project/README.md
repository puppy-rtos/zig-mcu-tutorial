# Zig MCU 调试环境示例

这是一个基于Zig语言的STM32F407调试环境示例，用于演示如何搭建和使用VSCode + ST-Link + pyocd进行单步调试。

## 功能说明

该示例实现了一个简单的LED闪烁功能，使用PF11引脚控制LED，每秒闪烁一次。同时，该示例配置了完整的调试环境，可以在VSCode中进行单步调试、断点设置、变量监控等操作。

## 编译步骤

### 1. 编译ELF文件

在项目根目录执行以下命令：

```bash
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
```

## 调试步骤

### 1. 硬件连接

- 将ST-Link调试器连接到星火1号开发板
- 确保开发板电源正常

### 2. VSCode 调试配置

项目已经包含了 `.vscode/launch.json` 配置文件，配置内容如下：

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
            "executable": "${workspaceFolder}/stm32f407",
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

### 3. 开始调试

1. 在VSCode中打开该项目
2. 按下 `F5` 键或点击调试按钮
3. 开始进行调试操作：
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
   - Python 3.7+
   - pyocd（使用 `pip install pyocd` 安装）
   - ST-Link 驱动
   - Cortex-Debug VSCode 插件
   - Zig 编译器（0.15.0+）

2. 该示例针对STM32F407芯片，如果你使用其他芯片，可能需要调整寄存器地址和链接脚本

3. 确保ST-Link调试器正确连接到开发板，并且驱动已正确安装

4. 调试过程中，如果遇到连接问题，可以尝试：
   - 检查硬件连接
   - 重新安装ST-Link驱动
   - 重启VSCode和调试器

5. 该示例与第3节教程使用相同的LED闪烁代码，只是添加了完整的调试环境配置
