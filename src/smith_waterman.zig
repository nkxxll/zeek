const std = @import("std");

/// configuration of the algorithm
const sw_scoring = struct {
    pub const match: i8 = 4;
    pub const mismatch: i8 = -1;
    pub const gap: i8 = -2;
};

fn free_table(table: [][]u8, allocator: std.mem.Allocator) void {
    for (table) |*elem| {
        allocator.free(elem.*);
    }
    allocator.free(table);
}

fn getTableMax(table: [][]u8) u8 {
    var res: u8 = 0;
    for (table) |row| {
        for (row) |col| {
            if (col > res) {
                res = col;
            }
        }
    }
    return res;
}

pub fn generateTable(word: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !u8 {
    const word_len = word.len;
    const pattern_len = pattern.len;

    const table = try allocator.alloc([]u8, word_len + 1);
    for (table) |*elem| {
        elem.* = try allocator.alloc(u8, pattern_len + 1);
        @memset(elem.*, 0);
    }
    defer free_table(table, allocator);

    for (1..word_len + 1) |ri| {
        for (1..pattern_len + 1) |ci| {
            var diag_plus: i8 = 0;
            if (word[ri - 1] == pattern[ci - 1]) {
                // todo calc the field
                diag_plus = sw_scoring.match;
            } else {
                diag_plus = sw_scoring.mismatch;
            }
            const diag_score = @as(i16, table[ri - 1][ci - 1]) + diag_plus;
            const up_score = @as(i16, table[ri - 1][ci]) + sw_scoring.gap;
            const down_score = @as(i16, table[ri][ci - 1]) + sw_scoring.gap;
            table[ri][ci] = @as(u8, @intCast(@max(0, @max(@max(diag_score, up_score), down_score))));
        }
    }
    debugTable(table, word, pattern);

    const return_val = getTableMax(table);

    return return_val;
}

pub fn debugTable(table: [][]u8, word: []const u8, pattern: []const u8) void {
    std.debug.print("      ", .{});
    for (pattern) |char| {
        std.debug.print("  {c}", .{char});
    }
    std.debug.print("\n", .{});

    for (table, 0..) |row, idx| {
        if (idx != 0) {
            std.debug.print(" {c} ", .{word[idx - 1]});
        } else {
            std.debug.print("   ", .{});
        }

        for (row) |col| {
            std.debug.print("{d:>3} ", .{col});
        }
        std.debug.print("\n", .{});
    }
}

test "hello" {
    const word = "hello";
    const pattern = "hll";
    const allocator = std.testing.allocator;

    const expect = 10;
    const res = try generateTable(word, pattern, allocator);

    try std.testing.expectEqual(expect, res);
}

test "DNA" {
    const word = "AAATTGGAATTGAGGAA";
    const pattern = "AATTGGAATTA";
    const allocator = std.testing.allocator;

    const expect = 42;
    const res = try generateTable(word, pattern, allocator);

    try std.testing.expectEqual(expect, res);
}

test "Hella" {
    const word = "hello";
    const pattern = "hella";
    const allocator = std.testing.allocator;

    const expect = 16;
    const res = try generateTable(word, pattern, allocator);

    try std.testing.expectEqual(expect, res);
}
