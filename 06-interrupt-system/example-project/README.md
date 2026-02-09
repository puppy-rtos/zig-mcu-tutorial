# Zig 中断系统示例

这是一个基于Zig语言的STM32F407中断系统示例，用于演示如何使用外部中断控制LED。

## 功能说明

该示例实现了以下功能：
- 配置PC5为输入模式（按键，有上拉电阻）
- 配置PF11为输出模式（LED）
- 配置EXTI5中断，实现按键双边沿触发（上升沿和下降沿）
- 通过中断方式检测按键状态
- 在主循环中根据按键状态控制LED的亮灭

## 硬件连接

- **按键**：PC5（有上拉电阻）
- **LED**：PF11
- **调试器**：ST-Link

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

### 3. 开始调试

1. 在VSCode中打开该项目
2. 按下 `F5` 键或点击调试按钮
3. 开始进行调试操作：
   - **单步执行**：`F10`（单步跳过）或 `F11`（单步进入）
   - **继续执行**：`F5`
   - **暂停执行**：`F6`
   - **设置断点**：点击代码行号左侧

### 4. 测试方法

- 按下开发板上的PC5按键，观察LED是否点亮
- 释放按键，观察LED是否熄灭
- 在VSCode中可以设置断点，观察中断处理函数的执行过程

## 目录结构

```
example-project/
├── src/
│   ├── main.zig       # 主程序文件
│   ├── link.ld        # 链接脚本
│   └── startup.zig    # 启动代码
└── README.md          # 说明文档
```

## 注意事项

1. 确保你已经安装了Zig编译器（0.15.0+）
2. 确保你已经安装了ARM GCC工具链，用于GDB调试
3. 确保你已经安装了ST-Link驱动和pyocd
4. 该示例针对STM32F407芯片，如果你使用其他芯片，可能需要调整寄存器地址和中断配置
5. 按键使用PC5引脚，已经配置为内部上拉输入
