// UART打印示例 - 直接操作寄存器

// STM32F407寄存器地址
const RCC_BASE = 0x40023800;
const GPIOA_BASE = 0x40020000;
const USART1_BASE = 0x40011000;

// RCC寄存器
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));
const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x44));

// GPIOA寄存器
const GPIOA_MODER = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x00));
const GPIOA_AFRL = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x20));
const GPIOA_AFRH = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x24));

// USART1寄存器
const USART1_SR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x00));
const USART1_DR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x04));
const USART1_BRR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x08));
const USART1_CR1 = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x0C));

// UART引脚
const UART_TX_PIN = 9; // PA9
const UART_RX_PIN = 10; // PA10

pub fn main() noreturn {
    // 启用GPIOA时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 0); // GPIOA的时钟使能位是第0位

    // 启用USART1时钟
    RCC_APB2ENR.* |= @as(u32, 1 << 4); // USART1的时钟使能位是第4位

    // 设置PA9和PA10为复用功能模式
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_TX_PIN * 2)); // 清除PA9现有设置
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_TX_PIN * 2)); // 设置PA9为复用功能模式
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_RX_PIN * 2)); // 清除PA10现有设置
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_RX_PIN * 2)); // 设置PA10为复用功能模式

    // 设置PA9和PA10的复用功能为AF7 (USART1)
    // PA9和PA10使用AFRH寄存器（控制引脚8-15）
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_TX_PIN - 8) * 4)); // 清除PA9复用功能
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_TX_PIN - 8) * 4)); // 设置PA9为AF7
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_RX_PIN - 8) * 4)); // 清除PA10复用功能
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_RX_PIN - 8) * 4)); // 设置PA10为AF7

    // 配置USART1
    // 设置波特率为115200 (假设系统时钟为16MHz)
    // USARTDIV = 16000000 / (16 * 115200) = 8.68
    // USART_BRR = (MANTISSA << 4) | FRACTION = (8 << 4) | 11 = 139
    USART1_BRR.* = @as(u32, 139);

    // 使能USART1发送器和接收器
    USART1_CR1.* |= @as(u32, (1 << 3) | (1 << 2)); // TE=1, RE=1

    // 使能USART1
    USART1_CR1.* |= @as(u32, 1 << 13); // UE=1

    // 主循环
    while (true) {
        // 打印"Hello Zig from MCU!"
        uart_print("Hello Zig from MCU!\r\n");

        // 延迟
        delay_ms(1000);
    }
}

// UART发送单个字符
fn uart_send_byte(byte: u8) void {
    // 等待发送数据寄存器为空
    while ((USART1_SR.* & @as(u32, 1 << 7)) == 0) {}

    // 发送数据
    USART1_DR.* = @as(u32, byte);
}

// UART打印字符串
fn uart_print(str: []const u8) void {
    for (str) |byte| {
        uart_send_byte(byte);
    }
}

// 简单的延迟函数
fn delay_ms(ms: u32) void {
    // 假设系统时钟为16MHz
    const cycles_per_ms = 16000;
    var i: u32 = 0;
    while (i < ms * cycles_per_ms) : (i += 1) {
        asm volatile ("nop");
    }
}
