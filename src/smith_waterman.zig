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

pub fn generateTable(word: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !u8 {
    const word_len = word.len;
    const pattern_len = pattern.len;

    const res = try allocator.alloc([]u8, word_len + 1);
    for (res) |*elem| {
        elem.* = try allocator.alloc(u8, pattern_len + 1);
        @memset(elem.*, 0);
    }
    defer free_table(res, allocator);

    debugTable(res, word, pattern);

    for (1..word_len + 1) |ri| {
        for (1..pattern_len + 1) |ci| {
            var diag_plus: i8 = 0;
            if (word[ri - 1] == pattern[ci - 1]) {
                // todo calc the field
                diag_plus = sw_scoring.match;
            }
            const diag_score = @as(i16, res[ri - 1][ci - 1]) + diag_plus;
            const up_score = @as(i16, res[ri - 1][ci]) + sw_scoring.gap;
            const down_score = @as(i16, res[ri][ci - 1]) + sw_scoring.gap;
            const mismatch_score = @as(i16, res[ri - 1][ci - 1]) + sw_scoring.mismatch;
            res[ri][ci] = @as(u8, @intCast(@max(@max(@max(diag_score, up_score), down_score), mismatch_score)));
        }
    }
    debugTable(res, word, pattern);

    var return_val: u8 = 0;
    for (res) |row| {
        return_val = @max(row[pattern_len], return_val);
    }

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
