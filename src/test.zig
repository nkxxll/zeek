const std = @import("std");

pub fn main() !void {
    // get something from the command line
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const isTTY = std.io.getStdIn().isTty();
    var buffer: [1024]u8 = undefined;
    var buffer2: [1024]u8 = undefined;
    const echo = "echo: ";
    // catch the error too much input
    if (!isTTY) {
        _ = try stdin.readAll(&buffer);
    } else {
        _ = try stdout.write("please enter a string: ");
        _ = try stdin.readAll(&buffer);
        _ = try stdout.write("please enter a string: ");
        _ = try stdin.readUntilDelimiterOrEof(&buffer2, '\n');
    }
    _ = try stdout.write(echo ++ buffer ++ buffer2);
}

fn free_array(array: [][]u8, allocator: std.mem.Allocator) void {
    for (array) |*elem| {
        allocator.free(elem.*);
    }
    allocator.free(array);
}

fn arraymaker(a: u8, allocator: std.mem.Allocator) !void {
    const array: [][]u8 = try allocator.alloc([]u8, a);
    for (array) |*elem| {
        // add slices to the slice slice
        elem.* = try allocator.alloc(u8, a);
        @memset(elem.*, 0);
    }
    defer free_array(array, allocator);
    for (array) |elem| {
        std.log.warn("{any}", .{elem});
    }
}

test "arrays" {
    const a = std.testing.allocator;
    try arraymaker(8, a);
}

test "array2" {
    var arrayarray: [4]u8 = [_]u8{ 1, 2, 3, 4 };
    const array: []u8 = arrayarray[0..4];
    for (array) |*elem| {
        elem.* += 1;
    }
    std.log.warn("{any}", .{array});
}
