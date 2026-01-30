// Zig 语言基础示例

const std = @import("std");
const println = std.debug.print;

// 常量定义
const PI: f32 = 3.14159;
const MAX_COUNT: u32 = 10;

// 函数定义
fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn blink_led() void {
    println("LED blinking...\n", .{});
}

// 错误类型定义
const Error = error{
    InvalidValue,
};

// 返回错误的函数
fn validate_value(value: u32) Error!void {
    if (value > 100) {
        return Error.InvalidValue;
    }
}

// 主函数
pub fn main() void {
    // 变量声明与初始化
    var count: u32 = 0;
    const voltage: f32 = 3.3;
    const led_state: bool = false;

    // 类型推断
    const x: i32 = 42; // 显式指定类型
    const y: f64 = 3.14; // 显式指定类型
    const z: bool = true; // 显式指定类型

    // 使用 @as 进行类型转换
    const a = @as(i32, 100);
    const b = @as(f64, 2.718);
    println("a: {}, b: {}\n", .{ a, b });

    // 打印变量值
    println("count: {}\n", .{count});
    println("voltage: {}\n", .{voltage});
    println("led_state: {}\n", .{led_state});
    println("x: {}\n", .{x});
    println("y: {}\n", .{y});
    println("z: {}\n", .{z});

    // 函数调用
    const result = add(10, 20);
    println("add(10, 20) = {}\n", .{result});

    blink_led();

    // 条件语句
    if (voltage > 3.0) {
        println("Voltage is high\n", .{});
    } else {
        println("Voltage is normal\n", .{});
    }

    // while 循环
    count = 0;
    while (count < MAX_COUNT) : (count += 1) {
        println("Count: {}\n", .{count});
    }

    // for 循环
    const values = [_]u32{ 1, 2, 3, 4, 5 };
    for (values) |value| {
        println("Value: {}\n", .{value});
    }

    // 带索引的 for 循环
    for (values, 0..) |value, index| {
        println("Index {}: Value {}\n", .{ index, value });
    }

    // 指针操作
    var number: u32 = 100;
    const number_ptr: *u32 = &number;
    number_ptr.* = 200;
    println("number: {}\n", .{number});

    // 错误处理
    validate_value(50) catch |err| {
        println("Error: {}\n", .{err});
        return;
    };
    println("Validation passed\n", .{});

    // 编译期计算
    const array_size = comptime values.len;
    println("Array size (comptime): {}\n", .{array_size});

    // 小整数类型示例
    const small_int: u2 = 3; // u2 类型，取值范围 0-3
    println("Small int (u2): {}\n", .{small_int});

    const small_signed: i3 = -2; // i3 类型，取值范围 -4 到 3
    println("Small signed int (i3): {}\n", .{small_signed});

    // 结构体示例
    const Point = struct {
        x: i32,
        y: i32,
    };

    // 通过字段名初始化
    const p = Point{ .x = 10, .y = 20 };
    println("Point: x={}, y={}\n", .{ p.x, p.y });

    // 带方法的结构体示例
    const Rectangle = struct {
        width: u32,
        height: u32,

        pub fn area(self: *const @This()) u32 {
            return self.width * self.height;
        }
    };

    var rect = Rectangle{ .width = 100, .height = 50 };
    const rect_area = rect.area();
    println("Rectangle area: {}\n", .{rect_area});
}
