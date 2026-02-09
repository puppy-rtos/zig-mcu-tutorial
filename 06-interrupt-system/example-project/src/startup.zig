const std = @import("std");
const app = @import("main.zig");

// 扩展的向量表，包含初始栈指针、复位向量和EXTI5中断向量
pub const VectorTable = extern struct {
    initial_stack_pointer: u32,
    Reset: *const fn () callconv(.c) void,
    NMI: *const fn () callconv(.c) void,
    HardFault: *const fn () callconv(.c) void,
    MemManage: *const fn () callconv(.c) void,
    BusFault: *const fn () callconv(.c) void,
    UsageFault: *const fn () callconv(.c) void,
    Reserved1: u32,
    Reserved2: u32,
    Reserved3: u32,
    Reserved4: u32,
    SVCall: *const fn () callconv(.c) void,
    DebugMonitor: *const fn () callconv(.c) void,
    Reserved5: u32,
    PendSV: *const fn () callconv(.c) void,
    SysTick: *const fn () callconv(.c) void,
    // 外部中断
    WWDG: *const fn () callconv(.c) void,
    PVD: *const fn () callconv(.c) void,
    TAMP_STAMP: *const fn () callconv(.c) void,
    RTC_WKUP: *const fn () callconv(.c) void,
    FLASH: *const fn () callconv(.c) void,
    RCC: *const fn () callconv(.c) void,
    EXTI0: *const fn () callconv(.c) void,
    EXTI1: *const fn () callconv(.c) void,
    EXTI2: *const fn () callconv(.c) void,
    EXTI3: *const fn () callconv(.c) void,
    EXTI4: *const fn () callconv(.c) void,
    DMA1_Stream0: *const fn () callconv(.c) void,
    DMA1_Stream1: *const fn () callconv(.c) void,
    DMA1_Stream2: *const fn () callconv(.c) void,
    DMA1_Stream3: *const fn () callconv(.c) void,
    DMA1_Stream4: *const fn () callconv(.c) void,
    DMA1_Stream5: *const fn () callconv(.c) void,
    DMA1_Stream6: *const fn () callconv(.c) void,
    ADC: *const fn () callconv(.c) void,
    CAN1_TX: *const fn () callconv(.c) void,
    CAN1_RX0: *const fn () callconv(.c) void,
    CAN1_RX1: *const fn () callconv(.c) void,
    CAN1_SCE: *const fn () callconv(.c) void,
    EXTI9_5: *const fn () callconv(.c) void,
    TIM1_BRK_TIM9: *const fn () callconv(.c) void,
    TIM1_UP_TIM10: *const fn () callconv(.c) void,
    TIM1_TRG_COM_TIM11: *const fn () callconv(.c) void,
    TIM1_CC: *const fn () callconv(.c) void,
    TIM2: *const fn () callconv(.c) void,
    TIM3: *const fn () callconv(.c) void,
    TIM4: *const fn () callconv(.c) void,
    I2C1_EV: *const fn () callconv(.c) void,
    I2C1_ER: *const fn () callconv(.c) void,
    I2C2_EV: *const fn () callconv(.c) void,
    I2C2_ER: *const fn () callconv(.c) void,
    SPI1: *const fn () callconv(.c) void,
    SPI2: *const fn () callconv(.c) void,
    USART1: *const fn () callconv(.c) void,
    USART2: *const fn () callconv(.c) void,
    USART3: *const fn () callconv(.c) void,
    EXTI15_10: *const fn () callconv(.c) void,
    RTC_Alarm: *const fn () callconv(.c) void,
    OTG_FS_WKUP: *const fn () callconv(.c) void,
    TIM8_BRK_TIM12: *const fn () callconv(.c) void,
    TIM8_UP_TIM13: *const fn () callconv(.c) void,
    TIM8_TRG_COM_TIM14: *const fn () callconv(.c) void,
    TIM8_CC: *const fn () callconv(.c) void,
    DMA1_Stream7: *const fn () callconv(.c) void,
    FSMC: *const fn () callconv(.c) void,
    SDIO: *const fn () callconv(.c) void,
    TIM5: *const fn () callconv(.c) void,
    SPI3: *const fn () callconv(.c) void,
    UART4: *const fn () callconv(.c) void,
    UART5: *const fn () callconv(.c) void,
    TIM6_DAC: *const fn () callconv(.c) void,
    TIM7: *const fn () callconv(.c) void,
    DMA2_Stream0: *const fn () callconv(.c) void,
    DMA2_Stream1: *const fn () callconv(.c) void,
    DMA2_Stream2: *const fn () callconv(.c) void,
    DMA2_Stream3: *const fn () callconv(.c) void,
    DMA2_Stream4: *const fn () callconv(.c) void,
    ETH: *const fn () callconv(.c) void,
    ETH_WKUP: *const fn () callconv(.c) void,
    CAN2_TX: *const fn () callconv(.c) void,
    CAN2_RX0: *const fn () callconv(.c) void,
    CAN2_RX1: *const fn () callconv(.c) void,
    CAN2_SCE: *const fn () callconv(.c) void,
    OTG_FS: *const fn () callconv(.c) void,
    DMA2_Stream5: *const fn () callconv(.c) void,
    DMA2_Stream6: *const fn () callconv(.c) void,
    DMA2_Stream7: *const fn () callconv(.c) void,
    USART6: *const fn () callconv(.c) void,
    I2C3_EV: *const fn () callconv(.c) void,
    I2C3_ER: *const fn () callconv(.c) void,
    OTG_HS_EP1_OUT: *const fn () callconv(.c) void,
    OTG_HS_EP1_IN: *const fn () callconv(.c) void,
    OTG_HS_WKUP: *const fn () callconv(.c) void,
    OTG_HS: *const fn () callconv(.c) void,
    DCMI: *const fn () callconv(.c) void,
    Reserved6: u32,
    HASH_RNG: *const fn () callconv(.c) void,
    FPU: *const fn () callconv(.c) void,
};

// 默认中断处理函数
fn default_handler() callconv(.c) void {
    while (true) {
        asm volatile ("nop");
    }
}

// 默认的EXTI5-9中断处理函数
fn default_exti5_9_handler() callconv(.c) void {
    default_handler();
    // 确保函数不会返回，因为default_handler是noreturn
    while (true) {
        asm volatile ("nop");
    }
}

// 外部引用main.zig中导出的中断处理函数
extern fn exti5_9_handler() callconv(.c) void;

// 向量表实例，指向初始栈指针和各种中断处理函数
export const vector_table: VectorTable linksection("vector") = .{
    .initial_stack_pointer = 0x20001000, // 栈顶地址
    .Reset = _start, // 复位向量
    .NMI = default_handler,
    .HardFault = default_handler,
    .MemManage = default_handler,
    .BusFault = default_handler,
    .UsageFault = default_handler,
    .Reserved1 = 0,
    .Reserved2 = 0,
    .Reserved3 = 0,
    .Reserved4 = 0,
    .SVCall = default_handler,
    .DebugMonitor = default_handler,
    .Reserved5 = 0,
    .PendSV = default_handler,
    .SysTick = default_handler,
    // 外部中断
    .WWDG = default_handler,
    .PVD = default_handler,
    .TAMP_STAMP = default_handler,
    .RTC_WKUP = default_handler,
    .FLASH = default_handler,
    .RCC = default_handler,
    .EXTI0 = default_handler,
    .EXTI1 = default_handler,
    .EXTI2 = default_handler,
    .EXTI3 = default_handler,
    .EXTI4 = default_handler,
    .DMA1_Stream0 = default_handler,
    .DMA1_Stream1 = default_handler,
    .DMA1_Stream2 = default_handler,
    .DMA1_Stream3 = default_handler,
    .DMA1_Stream4 = default_handler,
    .DMA1_Stream5 = default_handler,
    .DMA1_Stream6 = default_handler,
    .ADC = default_handler,
    .CAN1_TX = default_handler,
    .CAN1_RX0 = default_handler,
    .CAN1_RX1 = default_handler,
    .CAN1_SCE = default_handler,
    .EXTI9_5 = exti5_9_handler,
    .TIM1_BRK_TIM9 = default_handler,
    .TIM1_UP_TIM10 = default_handler,
    .TIM1_TRG_COM_TIM11 = default_handler,
    .TIM1_CC = default_handler,
    .TIM2 = default_handler,
    .TIM3 = default_handler,
    .TIM4 = default_handler,
    .I2C1_EV = default_handler,
    .I2C1_ER = default_handler,
    .I2C2_EV = default_handler,
    .I2C2_ER = default_handler,
    .SPI1 = default_handler,
    .SPI2 = default_handler,
    .USART1 = default_handler,
    .USART2 = default_handler,
    .USART3 = default_handler,
    .EXTI15_10 = default_handler,
    .RTC_Alarm = default_handler,
    .OTG_FS_WKUP = default_handler,
    .TIM8_BRK_TIM12 = default_handler,
    .TIM8_UP_TIM13 = default_handler,
    .TIM8_TRG_COM_TIM14 = default_handler,
    .TIM8_CC = default_handler,
    .DMA1_Stream7 = default_handler,
    .FSMC = default_handler,
    .SDIO = default_handler,
    .TIM5 = default_handler,
    .SPI3 = default_handler,
    .UART4 = default_handler,
    .UART5 = default_handler,
    .TIM6_DAC = default_handler,
    .TIM7 = default_handler,
    .DMA2_Stream0 = default_handler,
    .DMA2_Stream1 = default_handler,
    .DMA2_Stream2 = default_handler,
    .DMA2_Stream3 = default_handler,
    .DMA2_Stream4 = default_handler,
    .ETH = default_handler,
    .ETH_WKUP = default_handler,
    .CAN2_TX = default_handler,
    .CAN2_RX0 = default_handler,
    .CAN2_RX1 = default_handler,
    .CAN2_SCE = default_handler,
    .OTG_FS = default_handler,
    .DMA2_Stream5 = default_handler,
    .DMA2_Stream6 = default_handler,
    .DMA2_Stream7 = default_handler,
    .USART6 = default_handler,
    .I2C3_EV = default_handler,
    .I2C3_ER = default_handler,
    .OTG_HS_EP1_OUT = default_handler,
    .OTG_HS_EP1_IN = default_handler,
    .OTG_HS_WKUP = default_handler,
    .OTG_HS = default_handler,
    .DCMI = default_handler,
    .Reserved6 = 0,
    .HASH_RNG = default_handler,
    .FPU = default_handler,
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
