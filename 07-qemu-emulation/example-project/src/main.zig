// 最简点灯示例 - 直接操作寄存器

// STM32F407寄存器地址
const RCC_BASE = 0x40023800;
const GPIOF_BASE = 0x40021400;

// RCC寄存器
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));

// GPIOF寄存器
const GPIOF_MODER = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x00));
const GPIOF_ODR = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x14));

// LED引脚
const LED_PIN = 11;

pub fn main() noreturn {
    // 启用GPIOF时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 5); // GPIOF的时钟使能位是第5位
    
    // 设置PF11为输出模式
    GPIOF_MODER.* &= ~@as(u32, 0b11 << (LED_PIN * 2)); // 清除现有设置
    GPIOF_MODER.* |= @as(u32, 0b01 << (LED_PIN * 2));  // 设置为输出模式
    
    // 主循环
    while (true) {
        // 点亮LED (低电平)
        GPIOF_ODR.* &= ~@as(u32, 1 << LED_PIN);
        
        // 延迟
        delay_ms(1000);
        
        // 熄灭LED（高电平）
        GPIOF_ODR.* |= @as(u32, 1 << LED_PIN);
        
        // 延迟
        delay_ms(1000);
    }
}

// 简单的延迟函数
fn delay_ms(ms: u32) void {
    // 假设系统时钟为4MHz
    const cycles_per_ms = 4000;
    var i: u32 = 0;
    while (i < ms * cycles_per_ms) : (i += 1) {
        asm volatile ("nop");
    }
}
