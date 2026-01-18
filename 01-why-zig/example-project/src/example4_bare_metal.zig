const std = @import("std");

const GPIOA_BASE = 0x40010800;

const GPIO_TypeDef = struct {
    CRL: u32,
    ODR: u32,
    BSRR: u32,
    BRR: u32,
};

const GPIOA: *volatile GPIO_TypeDef = @ptrFromInt(GPIOA_BASE);

pub fn main() void {
    std.debug.print("Bare metal development example: register operations\n", .{});
    std.debug.print("GPIOA base address: 0x{x}\n", .{GPIOA_BASE});
    std.debug.print("Note: This example only shows register operation code structure\n", .{});
    std.debug.print("When running on actual hardware, correct hardware address is needed\n", .{});
}

pub fn led_init() void {
    GPIOA.CRL = 0x00100000;
    GPIOA.ODR &= ~@as(u32, 1 << 5);
}

pub fn led_on() void {
    GPIOA.BSRR = 1 << 5;
}

pub fn led_off() void {
    GPIOA.BRR = 1 << 5;
}
