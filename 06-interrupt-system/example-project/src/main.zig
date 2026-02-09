// 中断系统实战：按键控制LED示例
// 按键：PC5（有上拉电阻）
// LED：PF11

// STM32F407寄存器地址
const RCC_BASE = 0x40023800;
const GPIOF_BASE = 0x40021400;
const GPIOC_BASE = 0x40020800;
const SYSCFG_BASE = 0x40013800;
const EXTI_BASE = 0x40013C00;
const NVIC_BASE = 0xE000E100;

// RCC寄存器
const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x30));
const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x44));

// GPIOF寄存器
const GPIOF_MODER = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x00));
const GPIOF_ODR = @as(*volatile u32, @ptrFromInt(GPIOF_BASE + 0x14));

// GPIOC寄存器
const GPIOC_MODER = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x00));
const GPIOC_PUPDR = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x0C));
const GPIOC_IDR = @as(*volatile u32, @ptrFromInt(GPIOC_BASE + 0x10));

// SYSCFG寄存器
const SYSCFG_EXTICR2 = @as(*volatile u32, @ptrFromInt(SYSCFG_BASE + 0x0C));

// EXTI寄存器
const EXTI_IMR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x00));
const EXTI_FTSR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x0C));
const EXTI_RTSR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x08));
const EXTI_PR = @as(*volatile u32, @ptrFromInt(EXTI_BASE + 0x14));

// NVIC寄存器
const NVIC_ISER0 = @as(*volatile u32, @ptrFromInt(NVIC_BASE + 0x00));

// LED引脚
const LED_PIN = 11;
// 按键引脚
const BUTTON_PIN = 5; // PC5

// 全局变量，用于在中断和主函数之间共享状态
const ButtonState = enum {
    Released,
    Pressed,
};

var button_state: ButtonState = .Released;

// 延迟函数
fn delay_ms(ms: u32) void {
    // 假设系统时钟为16MHz
    const cycles_per_ms = 16000;
    var i: u32 = 0;
    while (i < ms * cycles_per_ms) : (i += 1) {
        asm volatile ("nop");
    }
}

// EXTI5-9中断处理函数
pub export fn exti5_9_handler() callconv(.c) void {
    // 检查是否是EXTI5中断（对应PC5引脚）
    if (EXTI_PR.* & (1 << BUTTON_PIN) != 0) {
        // 清除中断标志
        EXTI_PR.* |= (1 << BUTTON_PIN);

        // 读取按键状态
        if (GPIOC_IDR.* & (1 << BUTTON_PIN) == 0) {
            // 按键被按下（低电平）
            button_state = .Pressed;
        } else {
            // 按键被释放（高电平，因为有上拉电阻）
            button_state = .Released;
        }
    }
}

pub fn main() noreturn {
    // 启用GPIOF时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 5); // GPIOF的时钟使能位是第5位

    // 启用GPIOC时钟
    RCC_AHB1ENR.* |= @as(u32, 1 << 2); // GPIOC的时钟使能位是第2位

    // 启用SYSCFG时钟
    RCC_APB2ENR.* |= @as(u32, 1 << 14); // SYSCFG的时钟使能位是第14位

    // 设置PF11为输出模式
    GPIOF_MODER.* &= ~@as(u32, 0b11 << (LED_PIN * 2)); // 清除现有设置
    GPIOF_MODER.* |= @as(u32, 0b01 << (LED_PIN * 2)); // 设置为输出模式

    // 设置PC5为输入模式
    GPIOC_MODER.* &= ~@as(u32, 0b11 << (BUTTON_PIN * 2)); // 清除现有设置，默认为输入模式

    // 配置PC5为上拉输入
    GPIOC_PUPDR.* &= ~@as(u32, 0b11 << (BUTTON_PIN * 2)); // 清除现有设置
    GPIOC_PUPDR.* |= @as(u32, 0b01 << (BUTTON_PIN * 2)); // 设置为上拉

    // 配置SYSCFG，将PC5连接到EXTI5
    const exticr_shift = (BUTTON_PIN % 4) * 4;
    SYSCFG_EXTICR2.* &= ~(@as(u32, 0xF) << exticr_shift); // 清除现有设置
    SYSCFG_EXTICR2.* |= (@as(u32, 2) << exticr_shift); // 设置为GPIOC (2表示GPIOC)

    // 配置EXTI5为双边沿触发（下降沿和上升沿）
    EXTI_FTSR.* |= (1 << BUTTON_PIN); // 启用下降沿触发
    EXTI_RTSR.* |= (1 << BUTTON_PIN); // 启用上升沿触发

    // 启用EXTI5中断
    EXTI_IMR.* |= (1 << BUTTON_PIN);

    // 启用NVIC中的EXTI5-9中断
    const EXTI5_9_IRQn = 23; // EXTI5-9中断的NVIC中断号
    NVIC_ISER0.* |= (1 << EXTI5_9_IRQn);

    // 启用全局中断
    asm volatile ("cpsie i");

    // 初始化LED状态（熄灭）
    GPIOF_ODR.* |= @as(u32, 1 << LED_PIN);

    // 主循环
    while (true) {
        // 检查按键状态并控制LED
        switch (button_state) {
            .Pressed => {
                // 按键被按下，点亮LED (低电平)
                GPIOF_ODR.* &= ~@as(u32, 1 << LED_PIN);
            },
            .Released => {
                // 按键被释放，熄灭LED（高电平）
                GPIOF_ODR.* |= @as(u32, 1 << LED_PIN);
            },
        }

        // 主循环中可以添加其他任务
        delay_ms(10);
    }
}
