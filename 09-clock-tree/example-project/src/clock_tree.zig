const std = @import("std");

// RCC 寄存器基地址
const RCC_BASE: u32 = 0x40023800;
const FLASH_BASE: u32 = 0x40023C00;

// RCC 寄存器定义
const RCC_CR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x00)); // 时钟控制寄存器
const RCC_PLLCFGR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x04)); // PLL 配置寄存器
const RCC_CFGR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x08)); // 时钟配置寄存器
const RCC_APB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x40)); // APB1 时钟使能寄存器
const FLASH_ACR = @as(*volatile u32, @ptrFromInt(FLASH_BASE + 0x00)); // Flash 访问控制寄存器

// 固定时钟频率
const HSI_VALUE: u32 = 16000000; // HSI 内部时钟 16MHz
const HSE_VALUE: u32 = 8000000; // HSE 外部时钟 8MHz

/// 初始化时钟树
/// 配置：HSI → PLL → SYSCLK=80MHz, PCLK1=40MHz, PCLK2=40MHz
pub fn clk_init() void {
    // 复位 RCC 寄存器
    RCC_CR.* = 0x00000001; // 保留 HSION 位
    RCC_CFGR.* = 0x00000000; // 复位时钟配置
    RCC_PLLCFGR.* = 0x00000000; // 复位 PLL 配置

    // 使能 HSI 并等待就绪
    RCC_CR.* |= (1 << 0); // HSION = 1
    while ((RCC_CR.* & (1 << 1)) == 0) { // 等待 HSIRDY
        asm volatile ("nop");
    }

    // 使能电源接口时钟
    RCC_APB1ENR.* |= (1 << 28); // PWREN = 1

    // 配置 PLL：HSI(16MHz) → PLLM=8 → 2MHz → PLLN=80 → 160MHz → PLLP=2 → 80MHz
    RCC_PLLCFGR.* = (8 << 0) | (80 << 6) | (0 << 16) | (4 << 24); // PLLM=8, PLLN=80, PLLP=0(2分频), PLLQ=4
    RCC_PLLCFGR.* &= ~@as(u32, 1 << 22); // 选择 HSI 作为 PLL 时钟源

    // 配置 Flash 等待周期
    FLASH_ACR.* = (1 << 8) | (1 << 9) | (1 << 10) | (2 << 0); // PRFTEN=1, ICEN=1, DCEN=1, LATENCY=2WS

    // 使能 PLL 并等待就绪
    RCC_CR.* |= (1 << 24); // PLLON = 1
    while ((RCC_CR.* & (1 << 25)) == 0) { // 等待 PLLRDY
        asm volatile ("nop");
    }

    // 切换系统时钟到 PLL
    RCC_CFGR.* = (RCC_CFGR.* & ~@as(u32, 0x3 << 0)) | (0b10 << 0); // SW=PLL
    while (((RCC_CFGR.* >> 2) & 0x3) != 0b10) { // 等待 SWS=PLL
        asm volatile ("nop");
    }

    // 配置 AHB/APB 分频器
    RCC_CFGR.* = (RCC_CFGR.* & ~@as(u32, 0x7 << 10)) | (0b100 << 10); // PPRE1=2分频 (PCLK1=40MHz)
    RCC_CFGR.* = (RCC_CFGR.* & ~@as(u32, 0x7 << 13)) | (0b100 << 13); // PPRE2=2分频 (PCLK2=40MHz)
}

/// 复位时钟配置
pub fn clk_deinit() void {
    RCC_CFGR.* = 0x00000000; // 复位时钟配置
    RCC_CR.* &= ~@as(u32, 1 << 24); // 禁用 PLL
}

/// 获取系统时钟频率（SYSCLK）
/// 返回复位时钟源的实际频率
pub fn clk_get_sysfreq() u32 {
    const sws = (RCC_CFGR.* >> 2) & 0x3; // 读取系统时钟状态
    switch (sws) {
        0b00 => return HSI_VALUE, // HSI
        0b01 => return HSE_VALUE, // HSE
        0b10 => { // PLL
            const pllcfgr = RCC_PLLCFGR.*;
            const pllm = pllcfgr & 0x3F; // PLL 预分频系数
            const plln = (pllcfgr >> 6) & 0x1FF; // PLL 倍频系数
            const pllsrc = (pllcfgr >> 22) & 0x1; // PLL 时钟源
            const pllp_div = (((pllcfgr >> 16) & 0x3) + 1) * 2; // PLL 输出分频 (2/4/6/8)

            // 计算 PLL VCO 频率
            const pllvco: u32 = if (pllsrc == 1)
                (HSE_VALUE / pllm) * plln
            else
                (HSI_VALUE / pllm) * plln;

            return pllvco / pllp_div; // 返回 SYSCLK 频率
        },
        else => return 0, // 无效时钟源
    }
}

/// 获取 APB2 时钟频率（PCLK2）
/// UART1/3/4/5/6 等外设使用此时钟
pub fn clk_get_pclk2() u32 {
    const sysfreq = clk_get_sysfreq();
    const ppre2 = (RCC_CFGR.* >> 13) & 0x7; // PPRE2 位

    if (ppre2 >= 0b100) { // 只有 100 及以上才表示分频
        const div: u32 = switch (ppre2) {
            0b100 => 2,
            0b101 => 4,
            0b110 => 8,
            0b111 => 16,
            else => 1,
        };
        return sysfreq / div;
    }
    return sysfreq; // 不分频
}
