const ct = @import("clock_tree.zig");

// USART1 base address
const USART1_BASE: u32 = 0x40011000;

// USART1 registers
const USART1_SR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x00));
const USART1_DR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x04));
const USART1_BRR = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x08));
const USART1_CR1 = @as(*volatile u32, @ptrFromInt(USART1_BASE + 0x0C));

// GPIOA registers
const GPIOA_BASE: u32 = 0x40020000;
const GPIOA_MODER = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x00));
const GPIOA_AFRH = @as(*volatile u32, @ptrFromInt(GPIOA_BASE + 0x24));

// RCC registers
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(0x40023800 + 0x30));
const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(0x40023800 + 0x44));

// UART pin definitions
const UART_TX_PIN: u5 = 9;
const UART_RX_PIN: u5 = 10;

/// Initialize UART1
pub fn uart_init() void {
    // Enable GPIOA and USART1 clocks
    RCC_AHB1ENR.* |= (1 << 0);
    RCC_APB2ENR.* |= (1 << 4);

    // Configure PA9/PA10 as alternate function
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_TX_PIN * 2));
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_TX_PIN * 2));
    GPIOA_MODER.* &= ~@as(u32, 0b11 << (UART_RX_PIN * 2));
    GPIOA_MODER.* |= @as(u32, 0b10 << (UART_RX_PIN * 2));

    // Configure AF7 (USART1)
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_TX_PIN - 8) * 4));
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_TX_PIN - 8) * 4));
    GPIOA_AFRH.* &= ~@as(u32, 0xF << ((UART_RX_PIN - 8) * 4));
    GPIOA_AFRH.* |= @as(u32, 0x7 << ((UART_RX_PIN - 8) * 4));

    // Calculate baud rate
    const pclk2_freq = ct.clk_get_pclk2();
    const baud_rate: u32 = 115200;
    USART1_BRR.* = pclk2_freq / baud_rate;

    // Configure USART1
    USART1_CR1.* = 0;
    USART1_CR1.* |= (1 << 3); // TE: Transmitter enable
    USART1_CR1.* |= (1 << 2); // RE: Receiver enable
    USART1_CR1.* |= (1 << 13); // UE: USART enable
}

/// Send string
pub fn uart_print(str: []const u8) void {
    for (str) |byte| {
        uart_send_byte(byte);
    }
}

/// Send single byte
pub fn uart_send_byte(byte: u8) void {
    while ((USART1_SR.* & (1 << 7)) == 0) { // Wait for TXE flag
        asm volatile ("nop");
    }
    USART1_DR.* = byte;
}

/// Print hex value
pub fn print_hex(val: u8) void {
    const hex_chars = "0123456789ABCDEF";
    uart_send_byte('0');
    uart_send_byte('x');
    uart_send_byte(hex_chars[(val >> 4) & 0x0F]);
    uart_send_byte(hex_chars[val & 0x0F]);
}

/// Print 32-bit hex value
pub fn print_hex32(val: u32) void {
    const hex_chars = "0123456789ABCDEF";
    uart_print("0x");
    var i: u5 = 0;
    while (i < 8) : (i += 1) {
        uart_send_byte(hex_chars[(val >> @as(u5, @intCast(28 - i * 4))) & 0x0F]);
    }
}

/// Print unsigned integer
pub fn print_u32(val: u32) void {
    if (val == 0) {
        uart_send_byte('0');
        return;
    }

    var buf: [12]u8 = undefined;
    var v = val;
    var len: usize = 0;

    while (v > 0) : (len += 1) {
        v /= 10;
    }

    v = val;
    var i = len;
    while (i > 0) : (i -= 1) {
        buf[i - 1] = @as(u8, @intCast(v % 10)) + '0';
        v /= 10;
    }

    for (buf[0..len]) |byte| {
        uart_send_byte(byte);
    }
}
