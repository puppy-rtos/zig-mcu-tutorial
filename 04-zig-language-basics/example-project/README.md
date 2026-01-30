# 第4课：Zig 语言基础

## 课程内容

- [zig-language-basics.md](zig-language-basics.md) - 主教程内容
- [example-project/](example-project/) - 示例代码

## 学习目标

掌握 Zig 语言的基础语法知识：
- 基本数据类型
- 变量声明和初始化
- 控制流语句（条件、循环等）
- 函数定义和调用
- 指针和内存操作
- 错误处理机制
- 编译期特性（comptime）

## 示例代码

示例项目包含以下文件：

- `src/basics.zig` - 基本语法综合示例

## 编译运行

```bash
cd example-project
zig build-exe src/basics.zig -O ReleaseSmall

# 运行示例
.\basics.exe
```

## 代码说明

**basics.zig**：包含Zig语言基础语法的综合示例
- 变量声明与初始化
- 类型声明和类型转换
- 条件语句和循环语句
- 函数定义和调用
- 指针操作
- 错误处理
- 编译期计算

## 下节预告

搭建 Zig MCU 单步调试环境（基于VSCode + ST-Link + pyocd）

