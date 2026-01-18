# Zig 核心特性示例工程

本工程包含 Zig 语言核心特性的示例代码，展示了 Zig 在嵌入式开发中的优势。

## 📋 目录结构

```
example-project/
├── src/
│   ├── example1_memory_safety.zig         # 示例 1：内存安全（基础）
│   ├── example1_memory_safety_debug.zig    # 示例 1：内存安全（边界检查演示）
│   ├── example2_comptime.zig              # 示例 2：编译期计算
│   ├── example3_c_interop.zig             # 示例 3：C 兼容性
│   ├── example4_bare_metal.zig            # 示例 4：裸机开发
└── build.zig                            # 项目配置
```

## 🔧 环境要求

- Zig 0.15.2 或更高版本

## 🚀 运行示例

### 示例 1：内存安全 - 可选类型与边界检查

展示 Zig 的可选类型和边界检查机制。

#### 基础示例

```bash
zig run src/example1_memory_safety.zig
```

**预期输出**：
```
Optional type value: 42
Array valid index value: 3
Boundary check is enabled in Debug mode
In Release mode, boundary checks are disabled for better performance
```

**关键特性**：
- `?i32` 可选类型，避免空指针
- `if (optional) |value|` 安全解包
- 编译期边界检查

#### Debug 模式边界检查演示

Zig 在 Debug 模式下会自动启用运行时边界检查，帮助开发者快速发现数组越界等错误。

**演示边界检查错误**：

```bash
zig run src/example1_memory_safety_debug.zig
```

**预期输出（Debug 模式）**：
```
Optional type value: 42
Array valid index value: 3
thread 3088 panic: index out of bounds: index 10, len 5
E:\...\src\example1_memory_safety_debug.zig:19:46: 0x... in main
    print("Array out of bounds: {d}\n", .{arr[invalid_index]});
                                             ^
...
```

**预期输出（Release 模式）**：
```
Optional type value: 42
Array valid index value: 3
Array out of bounds: 00
```

**关键差异**：

| 模式 | 边界检查 | 行为 |
|------|---------|------|
| Debug | ✅ 启用 | 检测到越界时立即 panic，提供清晰的错误信息 |
| Release | ❌ 禁用 | 不检查边界，可能导致未定义行为或崩溃 |

**编译 Release 版本**：

```bash
# 编译 ReleaseFast 版本（禁用边界检查）
zig build-exe src/example1_memory_safety_debug.zig -O ReleaseFast

# 运行编译后的程序
.\example1_memory_safety_debug.exe
```

**为什么需要边界检查**：

1. **开发阶段**：Debug 模式的边界检查帮助快速发现错误
2. **生产环境**：Release 模式禁用检查以获得最佳性能
3. **嵌入式开发**：在资源受限的环境中，性能优化至关重要

**注意事项**：

- Debug 模式下的边界检查会有轻微的性能开销
- Release 模式下禁用检查后，数组越界可能导致未定义行为
- 建议在开发阶段使用 Debug 模式，发布时使用 Release 模式

---

### 示例 2：编译期计算 - 少跑运行时，多省单片机资源

展示 Zig 的编译期计算能力。

```bash
zig run src/example2_comptime.zig
```

**预期输出**：
```
MCU LED max count: 24
UART baud rate: 19200
```

**关键特性**：
- `comptime_int` 编译期整数类型
- `comptime` 关键字强制编译期执行
- 零运行时开销

---

### 示例 3：完美兼容 C - 旧驱动直接用，不用重写

展示 Zig 如何直接调用 C 代码。

```bash
zig run src/example3_c_interop.zig -lc
```

**预期输出**：
```
Zig calling C standard library function
STM32 LED initialization complete
LED 0 turned on
LED 0 turned off
```

**关键特性**：
- `@cImport` 导入 C 头文件
- `@cInclude` 包含 C 文件
- 无缝调用 C 函数

**注意**：此示例调用 C 标准库的 `printf` 函数，展示了 Zig 与 C 的互操作能力。

---

### 示例 4：裸机开发 - 寄存器操作简洁又安全

展示 Zig 在裸机开发中的应用。

```bash
zig run src/example4_bare_metal.zig
```

**预期输出**：
```
Bare metal development example: register operations
GPIOA base address: 0x40010800
Note: This example only shows register operation code structure
When running on actual hardware, correct hardware address is needed
```

**关键特性**：
- `const` 定义寄存器基地址
- `struct` 封装寄存器结构
- `@ptrFromInt` 映射物理地址
- `volatile` 确保硬件操作不被优化

**注意**：此示例展示了寄存器操作的代码结构，在 Windows 环境下运行不会实际访问硬件。在实际嵌入式硬件上运行时，需要根据具体硬件调整基地址。

---

## 🎯 代码验证

所有示例代码都可以在 Zig 0.15.2 环境下成功编译和运行：

```bash
# 验证基础示例
zig run src/example1_memory_safety.zig
zig run src/example2_comptime.zig
zig run src/example3_c_interop.zig -lc
zig run src/example4_bare_metal.zig

# 验证 Debug 模式边界检查（会触发 panic）
zig run src/example1_memory_safety_debug.zig

# 验证 Release 模式边界检查（禁用检查，可能输出错误值）
zig build-exe src/example1_memory_safety_debug.zig -O ReleaseFast
.\example1_memory_safety_debug.exe
```

## 📚 相关文档

- [Zig 官方文档](https://ziglang.org/documentation/master/)
- [Zig 学习资源](https://ziglearn.org/)
- [嵌入式 Zig 开发指南](https://github.com/ziglang/zig/wiki/Embedded)

## ⚠️ 注意事项

1. **示例 1 边界检查**
   - `example1_memory_safety.zig` 展示了安全的数组访问
   - `example1_memory_safety_debug.zig` 演示了 Debug 和 Release 模式的边界检查差异
   - Debug 模式会检测数组越界并 panic，Release 模式禁用检查以提升性能

2. **示例 3 需要实际的 C 实现**
   - `led_driver.h` 仅定义接口
   - 实际运行需要提供 `led_driver.c` 的实现

3. **示例 4 是寄存器定义**
   - 仅展示寄存器操作函数的定义
   - 实际使用需要根据具体硬件调整基地址

4. **编译器优化**
   - Release 模式会关闭边界检查
   - Debug 模式会启用所有安全检查

## 🔍 调试技巧

### 查看编译期计算结果

```bash
zig run src/example2_comptime.zig --verbose-ir
```

### 查看生成的汇编代码

```bash
zig build-obj src/example2_comptime.zig -femit-asm=output.s
```

### 启用详细错误信息

```bash
zig run src/example1_memory_safety.zig --verbose-cimport
```

### 调试边界检查问题

**启用 Debug 模式边界检查**（默认）：

```bash
# Debug 模式自动启用边界检查
zig run src/example1_memory_safety_debug.zig
```

**禁用边界检查（Release 模式）**：

```bash
# 编译 Release 版本，禁用边界检查
zig build-exe src/example1_memory_safety_debug.zig -O ReleaseFast

# 运行 Release 版本
.\example1_memory_safety_debug.exe
```

**使用不同的优化级别**：

```bash
# Debug 模式（启用所有安全检查）
zig build-exe src/example1_memory_safety_debug.zig -O Debug

# ReleaseSafe 模式（优化 + 安全检查）
zig build-exe src/example1_memory_safety_debug.zig -O ReleaseSafe

# ReleaseFast 模式（最大优化，禁用安全检查）
zig build-exe src/example1_memory_safety_debug.zig -O ReleaseFast

# ReleaseSmall 模式（最小代码体积）
zig build-exe src/example1_memory_safety_debug.zig -O ReleaseSmall
```

**边界检查性能对比**：

| 模式 | 边界检查 | 性能 | 安全性 | 适用场景 |
|------|---------|------|--------|---------|
| Debug | ✅ 启用 | 慢 | 高 | 开发调试 |
| ReleaseSafe | ✅ 启用 | 中 | 高 | 生产环境（需要安全） |
| ReleaseFast | ❌ 禁用 | 快 | 低 | 生产环境（需要性能） |
| ReleaseSmall | ❌ 禁用 | 快 | 低 | 生产环境（需要体积小） |

## 📞 问题反馈

如果遇到问题，请检查：
1. Zig 版本是否为 0.15.2 或更高
2. C 编译器是否正确安装
3. 文件路径是否正确

---

*本示例工程展示了 Zig 语言的核心特性，适合嵌入式开发者学习和参考。*
