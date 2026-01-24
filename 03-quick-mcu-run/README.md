# 快速在 MCU 上运行 Zig 程序

## 所属模块
模块一：入门基础篇

## 学习目标
- 了解基于 `zig build-exe` 命令构建 MCU 程序的方法
- 掌握在不使用 `build.zig` 的情况下创建 STM32F407 工程的步骤
- 编译并生成可在 STM32F407 上运行的二进制文件

## 内容要点
- 使用 `zig build-exe` 命令构建裸机程序
- STM32F407 最简工程结构
- 编译命令参数详解
- 二进制文件生成与验证

## 硬件需求
- STM32F407 开发板（可选，用于实际运行验证）

## 软件需求
- 操作系统：Windows 10+
- Zig 编译器（0.15.2+）
- VS Code（推荐）

## 学习时长
约 15 分钟

## 目录结构
```
03-quick-mcu-run/
├── quick-mcu-run.md          # 详细教程文档
├── example-project/
│   ├── src/
│   │   └── main.zig         # STM32F407 示例代码
└── README.md                # 本文件
```

## 快速开始

### 方式一：阅读详细教程
打开 [quick-mcu-run.md](quick-mcu-run.md) 查看详细的教程内容，包括如何手动创建和编译 STM32F407 项目。

### 方式二：直接运行示例项目
如果不想手动创建项目，可以直接使用我们准备好的示例项目：

```bash
cd example-project
gcc -c startup_stm32f407xx.s -o startup_stm32f407xx.o
zig build-exe src/main.zig -target thumb-freestanding-none -mcpu cortex_m4 -T linker.ld startup_stm32f407xx.o -O ReleaseSmall
```

**预期输出**：
```
生成 main.elf 和 main.bin 文件
```

## 常见问题

### Q1：编译时提示找不到文件
**解决方案**：确保在示例项目目录下执行命令，并检查所有依赖文件是否存在

### Q2：如何验证生成的二进制文件
**解决方案**：可以使用 `objdump` 或 `readelf` 工具查看生成的 ELF 文件信息

## 配套资源
- 示例代码：[example-project/src/main.zig](example-project/src/main.zig)

## 参考资料
- https://ziglang.org/documentation/master/

## 下节预告
STM32F407 基础外设开发

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
