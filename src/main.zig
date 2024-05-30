const std = @import("std");
const sw = @import("./smith_waterman.zig");

pub fn main() !void {
    const word = "hello";
    const pattern = "hll";
    const word1 = "AAATTGGAATTGAGGAA";
    const pattern1 = "AATTGGAATTA";
    var buffer: [1024]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(&buffer);
    // free all mem after use
    defer allocator.reset();

    const out_table = try sw.generateTable(word, pattern, allocator.allocator());
    const out_table1 = try sw.generateTable(word1, pattern1, allocator.allocator());
    std.debug.print("{d}\n", .{out_table}); // should be 10
    std.debug.print("{d}\n", .{out_table1}); // should be 42
}
