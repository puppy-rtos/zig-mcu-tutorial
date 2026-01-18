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

    // Runtime boundary check demonstration
    // This will trigger a panic in Debug mode
    // Using a function to ensure runtime evaluation
    const invalid_index = getInvalidIndex();
    print("Array out of bounds: {d}\n", .{arr[invalid_index]});

    // In Debug mode, this will cause a panic with:
    // index out of bounds: index 10, len 5
    // In Release mode, boundary checks are disabled for better performance,
    // which may lead to undefined behavior or crashes
}

fn getInvalidIndex() usize {
    return 10;
}
