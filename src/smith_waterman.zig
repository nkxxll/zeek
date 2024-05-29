const std = @import("std");

/// configuration of the algorithm
const sw_scoring = struct {
    pub const match: i8 = 4;
    pub const mismatch: i8 = -1;
    pub const gap: i8 = -2;
};

pub fn generateTable(word: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !u8 {
    const word_len = word.len;
    const pattern_len = pattern.len;

    var res = std.ArrayList([]u8).init(allocator);
    for (0..word_len + 1) |_| {
        try res.append(try allocator.alloc(u8, pattern_len + 1));
    }

    var owned_res = try res.toOwnedSlice();

    for (owned_res, 1..) |row, ri| {
        for (row, 1..) |_, ci| {
            var diag_plus: i8 = 0;
            if (word[ri - 1] == pattern[ci - 1]) {
                // todo calc the field
                diag_plus = sw_scoring.match;
            }
            const diag_score = @as(i16, owned_res[ri - 1][ci - 1]) + diag_plus;
            const up_score = @as(i16, owned_res[ri - 1][ci]) + sw_scoring.gap;
            const down_score = @as(i16, owned_res[ri][ci - 1]) + sw_scoring.gap;
            const mismatch_score = @as(i16, owned_res[ri - 1][ci - 1]) + sw_scoring.mismatch;
            owned_res[ri][ci] = @as(u8, @intCast(@max(@max(@max(diag_score, up_score), down_score), mismatch_score)));
        }
    }
    var return_val: u8 = 0;
    for (owned_res) |row| {
        return_val = @max(row[pattern_len], return_val);
    }

    return return_val;
}

pub fn debugTable(table: [][]u8, word: []const u8, pattern: []const u8) void {
    for (table, 0..) |row, idx| {
        if (idx == 0) {
            std.debug.print("{s}\n", .{pattern});
        }

        std.debug.print("{c}", .{word[idx]});

        for (row) |col| {
            std.debug.print("{d<3} ", .{col});
        }
        std.debug.print("\n", .{});
    }
}
