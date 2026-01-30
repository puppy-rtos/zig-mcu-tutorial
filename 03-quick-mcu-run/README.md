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
│   │   ├── main.zig         # 主程序文件（Zig）
│   │   ├── startup.zig      # 启动文件（Zig 实现）
│   │   └── link.ld          # 链接脚本
└── README.md                # 本文件
```

## 快速开始

### 方式一：阅读详细教程
打开 [quick-mcu-run.md](quick-mcu-run.md) 查看详细的教程内容，包括如何手动创建和编译 STM32F407 项目。

### 方式二：直接运行示例项目
如果不想手动创建项目，可以直接使用我们准备好的示例项目：

```bash
cd example-project
zig build-exe src/startup.zig -target thumb-freestanding-none -mcpu cortex_m4 -T src/link.ld -O ReleaseSmall --name stm32f407
```

**预期输出**：
```
生成 stm32f407（ELF 格式）文件
```

## 常见问题

### Q1：编译时提示找不到文件
**解决方案**：确保在示例项目目录下执行命令，并检查所有依赖文件是否存在

### Q2：如何验证生成的二进制文件
**解决方案**：可以使用 `objdump` 或 `readelf` 工具查看生成的 ELF 文件信息

### Q3：LED 不闪烁
**解决方案**：
1. 检查 LED 连接的引脚号是否正确
2. 确保对应的 GPIO 时钟已被正确使能
3. 调整延迟函数中的 `cycles_per_ms` 值，使其适应实际的系统时钟频率

## 配套资源
- 示例代码：[example-project/src/main.zig](example-project/src/main.zig)
- 启动文件：[example-project/src/startup.zig](example-project/src/startup.zig)
- 链接脚本：[example-project/src/link.ld](example-project/src/link.ld)

## 参考资料
- https://ziglang.org/documentation/master/

## 下节预告
Zig 语言基础（了解嵌入式开发必备语法）

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
