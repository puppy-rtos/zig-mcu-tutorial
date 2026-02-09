# 第6节 中断系统实战：按键控制 LED

## 课程说明

本节课程将介绍如何在Zig中实现STM32F407的外部中断系统，通过按键控制LED的亮灭状态。

### 课程内容

- 外部中断/事件控制器（EXTI）的配置
- 系统配置控制器（SYSCFG）的使用
- 中断向量表的扩展
- 中断处理函数的实现
- 按键状态检测
- 中断优先级的设置

### 学习目标

通过本节课程的学习，您将能够：

- 理解STM32F407的中断系统工作原理
- 掌握如何配置外部中断
- 实现中断处理函数
- 理解中断优先级的概念
- 通过中断方式实现硬件事件的响应

### 示例代码清单

- `example-project/src/startup.zig` - 启动文件，包含扩展的向量表
- `example-project/src/main.zig` - 主程序，实现中断处理和LED控制
- `example-project/src/link.ld` - 链接脚本
- `example-project/.vscode/launch.json` - VSCode调试配置

### 硬件要求

- 星火1号开发板（STM32F407）
- ST-Link调试器
- 按键（PC5，有上拉电阻）
- LED（PF11）

### 软件要求

- Zig 0.15.0+
- VSCode
- Cortex-Debug插件
- ARM GCC工具链
- pyocd
