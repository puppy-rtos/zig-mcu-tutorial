const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cDefine("__STDC_NO_ATOMICS__", "1");
    @cInclude("stdio.h");
});

pub fn main() void {
    _ = c.printf("Zig calling C standard library function\n");
    _ = c.printf("STM32 LED initialization complete\n");
    _ = c.printf("LED 0 turned on\n");
    _ = c.printf("LED 0 turned off\n");
}
