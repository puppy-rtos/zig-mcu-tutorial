# Zig 开发环境搭建

## 🚀 开篇引言

欢迎来到 Zig 单片机教程的第二课！

在开始编写 Zig 代码之前，我们需要先搭建好开发环境。本节课将带你在 Windows 系统上完成 Zig 编译器的安装和配置，让你快速上手 Zig 开发。

---

## 🎯 学习目标

通过本节课的学习，你将能够：

- ✅ 完成 Zig 编译器安装与配置（支持两种方式）
- ✅ 配置 VS Code 开发环境
- ✅ 验证环境配置是否正确
- ✅ 编译并运行第一个 Zig 程序

---

## ⚡ 环境准备

### 硬件需求
- 💻 无需额外硬件，只需一台 Windows 电脑

### 软件需求
- 🖥️ 操作系统：Windows 10 或更高版本
- 📝 代码编辑器：VS Code（推荐）或其他衍生 IDE

---

## 📦 安装方式一：手动安装（推荐）

### 步骤 1：下载 Zig 编译器

1. 访问 Zig 官方下载页面：
   - 官网：https://ziglang.org/download/

2. 下载最新稳定版本（推荐 0.15.2+）：
   - 文件名格式：`zig-x86_64-windows-0.15.2.zip`
   - 文件大小：约 88 MB

### 步骤 2：解压文件

1. 将下载的 ZIP 文件解压到你喜欢的位置，例如：
   ```
   D:\Program\zig
   ```
   *推荐安装到 D 盘，避免 C 盘空间不足和权限问题*

2. 解压后目录结构如下：
   ```
   D:\Program\zig\
   ├── zig.exe
   ├── lib\
   └── ...
   ```

### 步骤 3：配置环境变量

1. **打开环境变量设置**：
   - 按 `Win + R`，输入 `sysdm.cpl`，回车
   - 选择「高级」选项卡，点击「环境变量」

2. **添加系统变量**：
   - 在「系统变量」区域，找到 `Path` 变量，点击「编辑」
   - 点击「新建」，添加 Zig 可执行文件路径：
     ```
     D:\Program\zig
     ```
   - 点击「确定」保存

3. **验证配置**：
   - 打开新的命令提示符（CMD）或 PowerShell
   - 输入以下命令：
     ```bash
     zig version
     ```
   - 如果显示版本号（如 `0.15.2`），说明配置成功！

---

## 📦 安装方式二：使用 Scoop 包管理器

如果你喜欢使用包管理器管理软件，可以使用 Scoop 安装 Zig。

### 步骤 1：安装 Scoop（如未安装）

1. 以管理员身份打开 PowerShell

2. 执行以下命令安装 Scoop：
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   irm get.scoop.sh | iex
   ```

### 步骤 2：安装 Zig

1. 在 PowerShell 中执行：
   ```powershell
   scoop install zig
   ```

2. 等待安装完成

3. 验证安装：
   ```powershell
   zig version
   ```

> 💡 **提示**：使用 Scoop 的好处是可以方便地更新 Zig 版本：
> ```powershell
> scoop update zig
> ```

---

## 🎨 配置 VS Code 开发环境

### 步骤 1：安装 Zig 插件

1. 打开 VS Code

2. 点击左侧「扩展」图标（或按 `Ctrl + Shift + X`）

3. 搜索「Zig」，找到由「ziglang」团队开发的插件「Zig Language」

4. 点击「安装」

## ✅ 环境验证

### 编译第一个 Zig 项目

现在让我们创建并编译一个简单的 Zig 项目 `example-project`，验证环境是否配置正确。

### 步骤 1：创建项目目录

```bash
# 创建项目目录
mkdir example-project
cd example-project

# 创建 src 目录
mkdir src
```

### 步骤 2：创建主文件

在 `src` 目录下创建 `main.zig` 文件：

```zig
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, Zig!\n", .{});
}
```

### 步骤 3：编译并运行

```bash
# 直接运行源文件（推荐用于快速测试）
zig run src/main.zig
```

如果看到输出 `Hello, Zig!`，说明环境配置成功！

---

## 🎯 快速体验：使用已准备的示例项目

我们已经为你准备了一个与教程完全一致的示例项目，可以直接使用，无需手动创建：

```bash
# 进入示例项目目录
cd example-project

# 运行示例代码
zig run src/main.zig
```

### 预期输出

```
Hello, Zig!
```

这个示例项目展示了一个完整的 Zig 程序结构，你可以在此基础上开始编写自己的代码。

---

## 🔧 常见问题

### Q1：`zig` 命令不是内部或外部命令

**原因**：环境变量配置不正确

**解决方案**：
1. 检查环境变量 `Path` 中是否添加了 Zig 的路径
2. 确保路径指向包含 `zig.exe` 的目录
3. 重启命令提示符或 PowerShell，实在不行就重启电脑

### Q2：VS Code 无法识别 Zig 语法

**原因**：未安装 Zig 插件或插件未激活

**解决方案**：
1. 确认已安装 Zig 插件
2. 重启 VS Code
3. 检查插件是否被禁用

### Q4：如何更新 Zig 版本？

**手动安装方式**：
1. 下载新版本的 Zig
2. 解压并覆盖原文件

**Scoop 方式**：
```powershell
scoop update zig
```

---

## 📖 参考资料

- Zig 安装指南：https://course.ziglang.cc/environment/install-environment

---

## 🎉 总结

恭喜你完成了 Zig 开发环境的搭建！

本节课你学会了：

- ✅ 两种 Zig 安装方式（手动安装和 Scoop）
- ✅ VS Code 开发环境配置
- ✅ 如何创建和编译 Zig 项目
- ✅ 常见问题的解决方法

现在你已经准备好开始 Zig 开发之旅了！

---

## 📢 下节预告

快速在 MCU 上运行 Zig 程序

---

*关注我们，获取更多 Zig 嵌入式开发教程！*

*如有问题，欢迎在评论区留言讨论~*
