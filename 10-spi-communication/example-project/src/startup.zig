const std = @import("std");

pub const VectorTable = extern struct {
    initial_stack_pointer: u32,
    Reset: *const fn () callconv(.c) noreturn,
};

export const vector_table: VectorTable linksection("vector") = .{
    .initial_stack_pointer = 0x20001000,
    .Reset = _start,
};

extern var microzig_data_start: u8;
extern var microzig_data_end: u8;
extern var microzig_bss_start: u8;
extern var microzig_bss_end: u8;
extern var microzig_stack_end: u8;
extern const microzig_data_load_start: u8;

export fn _start() callconv(.c) noreturn {
    asm volatile ("movw r0, #:lower16:microzig_stack_end");
    asm volatile ("movt r0, #:upper16:microzig_stack_end");
    asm volatile ("mov sp, r0");

    {
        const bss_start: [*]u8 = @ptrCast(&microzig_bss_start);
        const bss_end: [*]u8 = @ptrCast(&microzig_bss_end);
        const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);

        @memset(bss_start[0..bss_len], 0);
    }

    {
        const data_start: [*]u8 = @ptrCast(&microzig_data_start);
        const data_end: [*]u8 = @ptrCast(&microzig_data_end);
        const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
        const data_src: [*]const u8 = @ptrCast(&microzig_data_load_start);

        @memcpy(data_start[0..data_len], data_src[0..data_len]);
    }

    main();
}

export fn main() noreturn {
    const main_fn = @import("main.zig").main;
    main_fn();
}
