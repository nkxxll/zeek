const std = @import("std");
const sw = @import("./smith_waterman.zig");

pub fn main() !void {
    const word = "hello";
    const pattern = "hll";
    var buffer: [1024]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(&buffer);
    // free all mem after use
    defer allocator.reset();

    const out_table = try sw.generateTable(word, pattern, allocator.allocator());
    std.debug.print("{d}", .{out_table});
}
