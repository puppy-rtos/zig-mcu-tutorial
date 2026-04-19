const std = @import("std");

// SPI base address definitions
pub const SPI1_BASE: u32 = 0x40013000;
pub const SPI2_BASE: u32 = 0x40003800;
pub const SPI3_BASE: u32 = 0x40003C00;

// SPI register offsets
const SPI_CR1_OFFSET: u32 = 0x00;
const SPI_CR2_OFFSET: u32 = 0x04;
const SPI_SR_OFFSET: u32 = 0x08;
const SPI_DR_OFFSET: u32 = 0x0C;
const SPI_CRCPR_OFFSET: u32 = 0x10;
const SPI_RXCRCR_OFFSET: u32 = 0x14;
const SPI_TXCRCR_OFFSET: u32 = 0x18;
const SPI_I2SCFGR_OFFSET: u32 = 0x1C;
const SPI_I2SPR_OFFSET: u32 = 0x20;

// CR1 register bit definitions
const SPI_CR1_CPHA: u32 = (1 << 0);
const SPI_CR1_CPOL: u32 = (1 << 1);
const SPI_CR1_MSTR: u32 = (1 << 2);
const SPI_CR1_BR_SHIFT: u5 = 3;
const SPI_CR1_SPE: u32 = (1 << 6);
const SPI_CR1_LSBFIRST: u32 = (1 << 7);
const SPI_CR1_SSI: u32 = (1 << 8);
const SPI_CR1_SSM: u32 = (1 << 9);
const SPI_CR1_RXONLY: u32 = (1 << 10);
const SPI_CR1_DFF: u32 = (1 << 11);
const SPI_CR1_CRCNEXT: u32 = (1 << 12);
const SPI_CR1_CRCEN: u32 = (1 << 13);
const SPI_CR1_BIDIOE: u32 = (1 << 14);
const SPI_CR1_BIDIMODE: u32 = (1 << 15);

// CR2 register bit definitions
const SPI_CR2_RXDMAEN: u32 = (1 << 0);
const SPI_CR2_TXDMAEN: u32 = (1 << 1);
const SPI_CR2_SSOE: u32 = (1 << 2);
const SPI_CR2_FRF: u32 = (1 << 4);
const SPI_CR2_ERRIE: u32 = (1 << 5);
const SPI_CR2_RXNEIE: u32 = (1 << 6);
const SPI_CR2_TXEIE: u32 = (1 << 7);

// SR register bit definitions
const SPI_SR_RXNE: u32 = (1 << 0);
const SPI_SR_TXE: u32 = (1 << 1);
const SPI_SR_CHSIDE: u32 = (1 << 2);
const SPI_SR_UDR: u32 = (1 << 3);
const SPI_SR_CRCERR: u32 = (1 << 4);
const SPI_SR_MODF: u32 = (1 << 5);
const SPI_SR_OVR: u32 = (1 << 6);
const SPI_SR_BSY: u32 = (1 << 7);
const SPI_SR_TIFRFE: u32 = (1 << 8);

// SPI mode definitions
pub const SPI_MODE_0: u8 = 0;
pub const SPI_MODE_1: u8 = 1;
pub const SPI_MODE_2: u8 = 2;
pub const SPI_MODE_3: u8 = 3;

// Data frame format
pub const SPI_DATASIZE_8BIT: u8 = 0;
pub const SPI_DATASIZE_16BIT: u8 = 1;

// Baud rate prescaler
pub const SPI_BAUDRATEPRESCALER_2: u8 = 0;
pub const SPI_BAUDRATEPRESCALER_4: u8 = 1;
pub const SPI_BAUDRATEPRESCALER_8: u8 = 2;
pub const SPI_BAUDRATEPRESCALER_16: u8 = 3;
pub const SPI_BAUDRATEPRESCALER_32: u8 = 4;
pub const SPI_BAUDRATEPRESCALER_64: u8 = 5;
pub const SPI_BAUDRATEPRESCALER_128: u8 = 6;
pub const SPI_BAUDRATEPRESCALER_256: u8 = 7;

// Frame format
pub const SPI_FIRSTBIT_MSB: u8 = 0;
pub const SPI_FIRSTBIT_LSB: u8 = 1;

// SPI configuration structure
pub const SpiConfig = struct {
    mode: u8 = SPI_MODE_0,
    datasize: u8 = SPI_DATASIZE_8BIT,
    baudrate_prescaler: u8 = SPI_BAUDRATEPRESCALER_2,
    firstbit: u8 = SPI_FIRSTBIT_MSB,
};

fn get_reg(spi_base: u32, offset: u32) *volatile u32 {
    return @as(*volatile u32, @ptrFromInt(spi_base + offset));
}

/// Initialize SPI
pub fn spi_init(spi_base: u32, config: *const SpiConfig) void {
    const cr1 = get_reg(spi_base, SPI_CR1_OFFSET);
    const cr2 = get_reg(spi_base, SPI_CR2_OFFSET);

    spi_disable(spi_base);

    cr1.* = 0;
    cr2.* = 0;

    if (config.mode & 0x01 != 0) {
        cr1.* |= SPI_CR1_CPHA;
    }
    if (config.mode & 0x02 != 0) {
        cr1.* |= SPI_CR1_CPOL;
    }

    if (config.datasize == SPI_DATASIZE_16BIT) {
        cr1.* |= SPI_CR1_DFF;
    }

    cr1.* |= @as(u32, config.baudrate_prescaler & 0x07) << SPI_CR1_BR_SHIFT;

    if (config.firstbit == SPI_FIRSTBIT_LSB) {
        cr1.* |= SPI_CR1_LSBFIRST;
    }

    cr1.* |= SPI_CR1_MSTR;

    cr1.* |= SPI_CR1_SSM | SPI_CR1_SSI;

    spi_enable(spi_base);
}

/// Enable SPI
pub fn spi_enable(spi_base: u32) void {
    const cr1 = get_reg(spi_base, SPI_CR1_OFFSET);
    cr1.* |= SPI_CR1_SPE;
}

/// Disable SPI
pub fn spi_disable(spi_base: u32) void {
    const cr1 = get_reg(spi_base, SPI_CR1_OFFSET);
    cr1.* &= ~SPI_CR1_SPE;
}

/// Wait for SPI not busy
pub fn spi_wait_not_busy(spi_base: u32) void {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    while ((sr.* & SPI_SR_BSY) != 0) {
        asm volatile ("nop");
    }
}

/// Transmit and receive a byte
pub fn spi_transmit_byte(spi_base: u32, data: u8) u8 {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    const dr = get_reg(spi_base, SPI_DR_OFFSET);

    while ((sr.* & SPI_SR_TXE) == 0) {
        asm volatile ("nop");
    }

    @as(*volatile u8, @ptrCast(dr)).* = data;

    while ((sr.* & SPI_SR_RXNE) == 0) {
        asm volatile ("nop");
    }

    spi_wait_not_busy(spi_base);

    return @as(*volatile u8, @ptrCast(dr)).*;
}

/// Transmit and receive a halfword (16-bit)
pub fn spi_transmit_halfword(spi_base: u32, data: u16) u16 {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    const dr = get_reg(spi_base, SPI_DR_OFFSET);

    while ((sr.* & SPI_SR_TXE) == 0) {
        asm volatile ("nop");
    }

    @as(*volatile u16, @ptrCast(dr)).* = data;

    while ((sr.* & SPI_SR_RXNE) == 0) {
        asm volatile ("nop");
    }

    spi_wait_not_busy(spi_base);

    return @as(*volatile u16, @ptrCast(dr)).*;
}

/// Transmit data
pub fn spi_transmit(spi_base: u32, data: []const u8) void {
    for (data) |byte| {
        _ = spi_transmit_byte(spi_base, byte);
    }
}

/// Receive data
pub fn spi_receive(spi_base: u32, data: []u8) void {
    for (data) |*byte| {
        byte.* = spi_transmit_byte(spi_base, 0xFF);
    }
}

/// Transmit and receive data simultaneously
pub fn spi_transmit_receive(spi_base: u32, tx_data: []const u8, rx_data: []u8) void {
    const len = @min(tx_data.len, rx_data.len);
    for (0..len) |i| {
        rx_data[i] = spi_transmit_byte(spi_base, tx_data[i]);
    }
}

/// Get SPI status register value
pub fn spi_get_status(spi_base: u32) u32 {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    return sr.*;
}

/// Check if SPI is busy
pub fn spi_is_busy(spi_base: u32) bool {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    return (sr.* & SPI_SR_BSY) != 0;
}

/// Check if RX buffer is not empty
pub fn spi_rx_not_empty(spi_base: u32) bool {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    return (sr.* & SPI_SR_RXNE) != 0;
}

/// Check if TX buffer is empty
pub fn spi_tx_empty(spi_base: u32) bool {
    const sr = get_reg(spi_base, SPI_SR_OFFSET);
    return (sr.* & SPI_SR_TXE) != 0;
}
