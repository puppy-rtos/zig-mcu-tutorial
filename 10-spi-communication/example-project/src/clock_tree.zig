const std = @import("std");

// RCC register base address
const RCC_BASE: u32 = 0x40023800;
const FLASH_BASE: u32 = 0x40023C00;

// RCC register definitions
const RCC_CR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x00));
const RCC_PLLCFGR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x04));
const RCC_CFGR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x08));
const RCC_APB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x40));
const FLASH_ACR = @as(*volatile u32, @ptrFromInt(FLASH_BASE + 0x00));

// Fixed clock frequencies
const HSI_VALUE: u32 = 16000000;
const HSE_VALUE: u32 = 8000000;

/// Initialize clock tree
pub fn clk_init() void {
    RCC_CR.* = 0x00000001;
    RCC_CFGR.* = 0x00000000;
    RCC_PLLCFGR.* = 0x00000000;

    RCC_CR.* |= (1 << 0);
    while ((RCC_CR.* & (1 << 1)) == 0) {
        asm volatile ("nop");
    }

    RCC_APB1ENR.* |= (1 << 28);

    RCC_PLLCFGR.* = (8 << 0) | (80 << 6) | (0 << 16) | (4 << 24);
    RCC_PLLCFGR.* &= ~@as(u32, 1 << 22);

    FLASH_ACR.* = (1 << 8) | (1 << 9) | (1 << 10) | (2 << 0);

    RCC_CR.* |= (1 << 24);
    while ((RCC_CR.* & (1 << 25)) == 0) {
        asm volatile ("nop");
    }

    RCC_CFGR.* = (RCC_CFGR.* & ~@as(u32, 0x3 << 0)) | (0b10 << 0);
    while (((RCC_CFGR.* >> 2) & 0x3) != 0b10) {
        asm volatile ("nop");
    }

    RCC_CFGR.* = (RCC_CFGR.* & ~@as(u32, 0x7 << 10)) | (0b100 << 10);
    RCC_CFGR.* = (RCC_CFGR.* & ~@as(u32, 0x7 << 13)) | (0b100 << 13);
}

/// Deinitialize clock configuration
pub fn clk_deinit() void {
    RCC_CFGR.* = 0x00000000;
    RCC_CR.* &= ~@as(u32, 1 << 24);
}

/// Get system clock frequency (SYSCLK)
pub fn clk_get_sysfreq() u32 {
    const sws = (RCC_CFGR.* >> 2) & 0x3;
    switch (sws) {
        0b00 => return HSI_VALUE,
        0b01 => return HSE_VALUE,
        0b10 => {
            const pllcfgr = RCC_PLLCFGR.*;
            const pllm = pllcfgr & 0x3F;
            const plln = (pllcfgr >> 6) & 0x1FF;
            const pllsrc = (pllcfgr >> 22) & 0x1;
            const pllp_div = (((pllcfgr >> 16) & 0x3) + 1) * 2;

            const pllvco: u32 = if (pllsrc == 1)
                (HSE_VALUE / pllm) * plln
            else
                (HSI_VALUE / pllm) * plln;

            return pllvco / pllp_div;
        },
        else => return 0,
    }
}

/// Get APB2 clock frequency (PCLK2)
pub fn clk_get_pclk2() u32 {
    const sysfreq = clk_get_sysfreq();
    const ppre2 = (RCC_CFGR.* >> 13) & 0x7;

    if (ppre2 >= 0b100) {
        const div: u32 = switch (ppre2) {
            0b100 => 2,
            0b101 => 4,
            0b110 => 8,
            0b111 => 16,
            else => 1,
        };
        return sysfreq / div;
    }
    return sysfreq;
}

/// Get APB1 clock frequency (PCLK1)
pub fn clk_get_pclk1() u32 {
    const sysfreq = clk_get_sysfreq();
    const ppre1 = (RCC_CFGR.* >> 10) & 0x7;

    if (ppre1 >= 0b100) {
        const div: u32 = switch (ppre1) {
            0b100 => 2,
            0b101 => 4,
            0b110 => 8,
            0b111 => 16,
            else => 1,
        };
        return sysfreq / div;
    }
    return sysfreq;
}
