# Zig 开发环境搭建

## 所属模块
模块一：入门基础篇

## 学习目标
- 完成 Zig 编译器安装与配置（下载工具链手动安装和 scoop两种方式）
- 配置 VS Code 开发环境（也可以使用其他衍生 IDE 如 TRAE 等等）
- 验证环境配置是否正确

## 内容要点
- Zig 编译器安装（Windows）
- VS Code 插件推荐（Zig 语法高亮）
- 环境验证（编译第一个空项目）

## 硬件需求
- 无需硬件

## 软件需求
- 操作系统：Windows 10+
- Zig 编译器（0.15.2+）
- VS Code（推荐）

## 学习时长
约 10 分钟

## 目录结构
```
02-environment-setup/
├── environment-setup.md          # 详细教程文档
├── example-project/
│   ├── src/
│   │   └── main.zig             # 示例代码
└── README.md                    # 本文件
```

## 快速开始

### 方式一：阅读详细教程
打开 [environment-setup.md](environment-setup.md) 查看详细的环境搭建步骤，包括如何手动创建 Zig 项目 `example-project`。

### 方式二：直接运行示例项目
如果不想手动创建项目，可以直接使用我们准备好的示例项目：

```bash
cd example-project
zig run src/main.zig
```

**预期输出**：
```
Hello, Zig!
```
## 常见问题

### Q1：`zig` 命令不是内部或外部命令
**解决方案**：检查环境变量 `Path` 中是否添加了 Zig 的路径

### Q2：VS Code 无法识别 Zig 语法
**解决方案**：确保已安装 Zig 插件（ziglang.zig）

### Q3：编译时提示找不到文件
**解决方案**：确保在包含 `build.zig` 的目录执行命令

## 配套资源
- 示例代码：[example-project/src/main.zig](example-project/src/main.zig)

## 参考资料
- https://course.ziglang.cc/environment/install-environment

## 下节预告
[快速在 MCU 上运行 Zig 程序](../03-quick-mcu-run/README.md)

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
