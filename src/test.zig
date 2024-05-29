const std = @import("std");

fn arraymaker(a: u8, allocator: std.mem.Allocator) !void {
    const array = try allocator.alloc(u8, a);
    defer allocator.free(array);
    @memset(array, 0);
    for (array) |item| {
        std.debug.print("{d}", .{item});
    }
}
test "arrays" {
    const a = std.testing.allocator;
    try arraymaker(8, a);
}
