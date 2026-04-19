const ct = @import("clock_tree.zig");
const spi = @import("spi.zig");
const uart = @import("uart.zig");

// Peripheral base addresses
const GPIOB_BASE: u32 = 0x40020400;
const GPIOC_BASE: u32 = 0x40020800;
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(0x40023800 + 0x30));
const RCC_APB1ENR = @as(*volatile u32, @ptrFromInt(0x40023800 + 0x40));

// GPIOB registers
const GPIOB_MODER = @as(*volatile u32, @ptrFromInt(GPIOB_BASE + 0x00));
const GPIOB_BSRR = @as(*volatile u32, @ptrFromInt(GPIOB_BASE + 0x18));
const GPIOB_AFRH = @as(*volatile u32, @ptrFromInt(GPIOB_BASE + 0x24));

// GPIOC registers
const GPIOC_MODER = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x00));
const GPIOC_AFRL = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x20));

// SPI2 pin definitions
// PC2 -> SPI2_MISO
// PC3 -> SPI2_MOSI
// PB13 -> SPI2_SCK
// PB12 -> CS (Chip Select)
const SPI2_MISO_PIN: u5 = 2;
const SPI2_MOSI_PIN: u5 = 3;
const SPI2_SCK_PIN: u5 = 13;
const FLASH_CS_PIN: u5 = 12;

// SPI Flash commands
const FLASH_CMD_READ_ID: u8 = 0x9F;

/// Main function
pub fn main() noreturn {
    ct.clk_init();

    uart.uart_init();

    uart.uart_print("=== STM32F407 SPI Flash ID Read Demo ===\r\n\r\n");

    spi_flash_init();

    uart.uart_print("SPI2 initialized\r\n");
    uart.uart_print("Config: Master mode, Mode 0, 8-bit data, 8 prescaler\r\n\r\n");

    uart.uart_print("Reading SPI Flash ID...\r\n\r\n");

    while (true) {
        spi_flash_read_id();
        delay_ms(1000);
    }
}

/// Initialize SPI2 and CS pin
fn spi_flash_init() void {
    // Enable GPIOB, GPIOC clocks
    RCC_AHB1ENR.* |= (1 << 1); // GPIOB
    RCC_AHB1ENR.* |= (1 << 2); // GPIOC

    // Enable SPI2 clock (APB1)
    RCC_APB1ENR.* |= (1 << 14); // SPI2EN

    // Configure PC2 (MISO) as alternate function
    GPIOC_MODER.* &= ~@as(u32, 0b11 << (SPI2_MISO_PIN * 2));
    GPIOC_MODER.* |= @as(u32, 0b10 << (SPI2_MISO_PIN * 2));
    GPIOC_AFRL.* &= ~@as(u32, 0xF << (SPI2_MISO_PIN * 4));
    GPIOC_AFRL.* |= @as(u32, 0x5 << (SPI2_MISO_PIN * 4)); // AF5

    // Configure PC3 (MOSI) as alternate function
    GPIOC_MODER.* &= ~@as(u32, 0b11 << (SPI2_MOSI_PIN * 2));
    GPIOC_MODER.* |= @as(u32, 0b10 << (SPI2_MOSI_PIN * 2));
    GPIOC_AFRL.* &= ~@as(u32, 0xF << (SPI2_MOSI_PIN * 4));
    GPIOC_AFRL.* |= @as(u32, 0x5 << (SPI2_MOSI_PIN * 4)); // AF5

    // Configure PB13 (SCK) as alternate function
    GPIOB_MODER.* &= ~@as(u32, 0b11 << (SPI2_SCK_PIN * 2));
    GPIOB_MODER.* |= @as(u32, 0b10 << (SPI2_SCK_PIN * 2));
    GPIOB_AFRH.* &= ~@as(u32, 0xF << ((SPI2_SCK_PIN - 8) * 4));
    GPIOB_AFRH.* |= @as(u32, 0x5 << ((SPI2_SCK_PIN - 8) * 4)); // AF5

    // Configure PB12 (CS) as output
    GPIOB_MODER.* &= ~@as(u32, 0b11 << (FLASH_CS_PIN * 2));
    GPIOB_MODER.* |= @as(u32, 0b01 << (FLASH_CS_PIN * 2));

    // Initialize CS to high (deselected)
    flash_cs_high();

    // Configure SPI2
    const config = spi.SpiConfig{
        .mode = spi.SPI_MODE_0,
        .datasize = spi.SPI_DATASIZE_8BIT,
        .baudrate_prescaler = spi.SPI_BAUDRATEPRESCALER_8,
        .firstbit = spi.SPI_FIRSTBIT_MSB,
    };
    spi.spi_init(spi.SPI2_BASE, &config);
}

/// Read SPI Flash ID
fn spi_flash_read_id() void {
    var id: [3]u8 = undefined;

    // Pull CS low (select Flash)
    flash_cs_low();

    // Send read ID command
    _ = spi.spi_transmit_byte(spi.SPI2_BASE, FLASH_CMD_READ_ID);

    // Read ID data
    id[0] = spi.spi_transmit_byte(spi.SPI2_BASE, 0xFF);
    id[1] = spi.spi_transmit_byte(spi.SPI2_BASE, 0xFF);
    id[2] = spi.spi_transmit_byte(spi.SPI2_BASE, 0xFF);

    // Pull CS high (deselect Flash)
    flash_cs_high();

    // Print ID
    uart.uart_print("SPI Flash ID: ");
    uart.print_hex(id[0]);
    uart.uart_print(" ");
    uart.print_hex(id[1]);
    uart.uart_print(" ");
    uart.print_hex(id[2]);
    uart.uart_print("\r\n");
}

/// Pull CS pin low (select)
fn flash_cs_low() void {
    GPIOB_BSRR.* = @as(u32, 1) << (FLASH_CS_PIN + 16);
}

/// Pull CS pin high (deselect)
fn flash_cs_high() void {
    GPIOB_BSRR.* = @as(u32, 1) << FLASH_CS_PIN;
}

/// Delay function
fn delay_ms(ms: u32) void {
    const sysclk_freq = ct.clk_get_sysfreq();
    const cycles_per_ms = sysclk_freq / 1000;
    var i: u32 = 0;
    while (i < ms * cycles_per_ms) : (i += 1) {
        asm volatile ("nop");
    }
}
