const ct = @import("clock_tree.zig");

// 外设基地址
const GPIOA_BASE: u32 = 0x40020000;
const USART1_BASE: u32 = 0x40011000;
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(0x40023800 + 0x30)); // AHB1 时钟使能
const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(0x40023800 + 0x44)); // APB2 时钟使能

// GPIO 寄存器
const GPIOA_MODER = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x00)); // 模式寄存器
const GPIOA_AFRH = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x24)); // 复用功能寄存器

// USART1 寄存器
const USART1_SR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x00)); // 状态寄存器
const USART1_DR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x04)); // 数据寄存器
const USART1_BRR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x08)); // 波特率寄存器
const USART1_CR1 = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x0C)); // 控制寄存器1

// UART 引脚定义
const UART_TX_PIN = 9; // PA9
const UART_RX_PIN = 10; // PA10

/// 主函数
pub fn main() noreturn {
    // 初始化时钟树
    ct.clk_init();

    // 初始化 UART
    uart_init();

    // 打印欢迎信息
    uart_print("=== STM32F407 时钟树演示 ===\r\n\r\n");

    // 打印系统时钟频率
    const sysfreq = ct.clk_get_sysfreq();
    uart_print("SYSCLK: ");
    print_u32(sysfreq);
    uart_print(" Hz\r\n");

    // 打印 PCLK2 频率
    const pclk2_freq = ct.clk_get_pclk2();
    uart_print("PCLK2: ");
    print_u32(pclk2_freq);
    uart_print(" Hz\r\n\r\n");

    uart_print("时钟树配置成功！\r\n");
    while (true) {
        delay_ms(1000);
    }
}

/// 初始化 UART1
fn uart_init() void {
    // 使能 GPIOA 和 USART1 时钟
    RCC_AHB1ENR.* |= (1 << 0); // GPIOA 时钟使能
    RCC_APB2ENR.* |= (1 << 4); // USART1 时钟使能

    // 配置 PA9/PA10 为复用功能
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_TX_PIN * 2));
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_TX_PIN * 2));
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_RX_PIN * 2));
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_RX_PIN * 2));

    // 配置 PA9/PA10 复用功能为 USART1
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_TX_PIN - 8) * 4));
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_TX_PIN - 8) * 4)); // AF7 (USART1)
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_RX_PIN - 8) * 4));
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_RX_PIN - 8) * 4)); // AF7 (USART1)

    // 计算波特率
    const pclk2_freq = ct.clk_get_pclk2();
    const baud_rate: u32 = 115200;
    const brr_val = pclk2_freq / baud_rate;
    USART1_BRR.* = brr_val;

    // 配置 USART1
    USART1_CR1.* = 0; // 清零控制寄存器
    USART1_CR1.* |= (1 << 3); // TE: 发送使能
    USART1_CR1.* |= (1 << 2); // RE: 接收使能
    USART1_CR1.* |= (1 << 13); // UE: USART 使能
}

/// 发送字符串
fn uart_print(str: []const u8) void {
    for (str) |byte| {
        uart_send_byte(byte);
    }
}

/// 发送单个字节
fn uart_send_byte(byte: u8) void {
    while ((USART1_SR.* & (1 << 7)) == 0) { // 等待 TXE 标志
        asm volatile ("nop");
    }
    USART1_DR.* = byte;
}

/// 延时函数
fn delay_ms(ms: u32) void {
    const sysclk_freq = ct.clk_get_sysfreq();
    const cycles_per_ms = sysclk_freq / 1000;
    var i: u32 = 0;
    while (i < ms * cycles_per_ms) : (i += 1) {
        asm volatile ("nop");
    }
}

/// 打印无符号整数
fn print_u32(val: u32) void {
    var buf: [12]u8 = undefined;
    var i: usize = 0;
    if (val == 0) {
        uart_send_byte('0');
        return;
    }
    var v = val;
    var len: usize = 0;
    while (v > 0) {
        v /= 10;
        len += 1;
    }
    i = len;
    v = val;
    while (len > 0) {
        len -= 1;
        buf[len] = @as(u8, @intCast(v % 10)) + '0';
        v /= 10;
    }
    for (buf[0..i]) |byte| {
        uart_send_byte(byte);
    }
}
