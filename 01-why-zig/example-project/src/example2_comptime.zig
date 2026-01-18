const std = @import("std");
const print = std.debug.print;

fn add(a: comptime_int, b: comptime_int) comptime_int {
    return a + b;
}

pub fn main() void {
    const max_led_count = comptime add(16, 8);
    const baud_rate = comptime 9600 * 2;

    print("MCU LED max count: {d}\n", .{max_led_count});
    print("UART baud rate: {d}\n", .{baud_rate});
}
