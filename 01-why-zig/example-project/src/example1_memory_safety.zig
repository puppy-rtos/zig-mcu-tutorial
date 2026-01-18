const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    var optional_int: ?i32 = null;
    optional_int = 42;

    if (optional_int) |value| {
        print("Optional type value: {d}\n", .{value});
    }

    const arr = [_]u8{ 1, 2, 3, 4, 5 };
    print("Array valid index value: {d}\n", .{arr[2]});

    // Debug mode boundary check demonstration
    // Uncomment the following line to see boundary check error in Debug mode:
    // print("Array out of bounds: {d}\n", .{arr[10]});

    // In Debug mode, the above line will cause a panic with:
    // index out of bounds: index 10, len 5
    // In Release mode, this check is disabled for performance

    print("Boundary check is enabled in Debug mode\n", .{});
    print("In Release mode, boundary checks are disabled for better performance\n", .{});
}
