const std = @import("std");

// 简化的向量表，只包含初始栈指针和复位向量
pub const VectorTable = extern struct {
    initial_stack_pointer: u32,
    Reset: *const fn () callconv(.c) noreturn,
};

// 向量表实例，指向初始栈指针和_start函数
export const vector_table: VectorTable linksection("vector") = .{
    .initial_stack_pointer = 0x20001000, // 栈顶地址
    .Reset = _start, // 复位向量
};

// 链接脚本中定义的符号
extern var microzig_data_start: u8;
extern var microzig_data_end: u8;
extern var microzig_bss_start: u8;
extern var microzig_bss_end: u8;
extern var microzig_stack_end: u8;
extern const microzig_data_load_start: u8;

// 启动函数 - 程序入口点
export fn _start() callconv(.c) noreturn {
    // 设置栈指针
    asm volatile ("ldr sp, =microzig_stack_end");

    // 初始化.bss段（清零）
    {
        const bss_start: [*]u8 = @ptrCast(&microzig_bss_start);
        const bss_end: [*]u8 = @ptrCast(&microzig_bss_end);
        const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);

        @memset(bss_start[0..bss_len], 0);
    }

    // 从flash复制.data段到RAM
    {
        const data_start: [*]u8 = @ptrCast(&microzig_data_start);
        const data_end: [*]u8 = @ptrCast(&microzig_data_end);
        const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
        const data_src: [*]const u8 = @ptrCast(&microzig_data_load_start);

        @memcpy(data_start[0..data_len], data_src[0..data_len]);
    }

    // 调用主函数
    main();
}

// 桥接函数，调用main.zig中的main函数
export fn main() noreturn {
    const main_fn = @import("main.zig").main;
    main_fn();
}
