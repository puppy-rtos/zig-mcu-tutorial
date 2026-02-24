# 第7节：使用QEMU在线仿真学习Zig

## 📚 课程说明

本节教程是 Zig 单片机教程的第七课，由于春节假期没有带硬件开发板，我们调整为使用 QEMU 在线仿真来学习 Zig。

## 🎯 课程目标

- 安装和配置 QEMU 仿真环境
- 理解 QEMU 仿真原理和基本概念
- 使用 QEMU 运行 Zig 编译的程序
- 掌握 QEMU 单步调试技巧
- 结合 VSCode 进行高效的开发和调试

## 📁 目录结构

```
07-qemu-emulation/
├── README.md              # 课程说明
├── qemu-emulation.md      # 主教程内容
└── example-project/       # 示例项目
    ├── src/
    │   ├── main.zig       # 主程序文件（Zig）
    │   ├── startup.zig    # 启动文件（Zig 实现）
    │   └── link.ld        # 链接脚本
    └── .vscode/
        └── launch.json    # VSCode 调试配置
```

## 🚀 快速开始

1. **安装必要工具**：
   - VSCode
   - Zig 0.15.0+
   - QEMU 7.0+
   - ARM GCC 工具链 12.2+
   - VSCode 插件：Cortex-Debug、Zig

2. **编译项目**：
   ```bash
   cd example-project
   zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O Debug --name stm32f407
   ```

3. **运行项目**：
   ```bash
   cd example-project
   run-qemu.bat
   ```

4. **调试项目**：
   - 启动 QEMU 调试模式
   - 在 VSCode 中按下 `F5` 键启动调试

## 🔧 工具配置

### QEMU 路径

本教程使用的 QEMU 路径为：
```
D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe
```

如果你的 QEMU 安装在不同路径，请修改 `run-qemu.bat` 脚本中的路径。

### VSCode 调试配置

在 `example-project/.vscode/launch.json` 文件中配置调试参数，确保：
- `executable` 路径指向编译生成的可执行文件
- `gdbPath` 指向 ARM GCC 工具链中的 GDB 可执行文件

## 📖 学习资源

- [QEMU 官网](https://www.qemu.org/)
- [ARM GCC 工具链下载](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
- [Zig 官方文档](https://ziglang.org/documentation/master/)
- [Cortex-Debug 插件文档](https://github.com/Marus/cortex-debug)

## 🐛 常见问题

### QEMU 启动失败
- 检查 QEMU 路径是否正确
- 确保编译的程序与 QEMU 模拟的硬件兼容

### 调试连接问题
- 确保 QEMU 已在调试模式下启动
- 检查 GDB 路径是否正确配置
- 确认端口号（默认为 1234）没有被占用

## 📢 下节预告

UART通信实战：使用Zig实现串口打印

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*