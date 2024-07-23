const std = @import("std");

/// configuration of the algorithm
pub const Seeker = struct {
    match: i8,
    mismatch: i8,
    gap: i8,

    pub fn init(match: i8, mismatch: i8, gap: i8) Seeker {
        return Seeker{
            .match = match,
            .mismatch = mismatch,
            .gap = gap,
        };
    }

    pub fn getScore(self: Seeker, word: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !u8 {
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
                    diag_plus = self.match;
                } else {
                    diag_plus = self.mismatch;
                }
                const diag_score = @as(i16, table[ri - 1][ci - 1]) + diag_plus;
                const up_score = @as(i16, table[ri - 1][ci]) + self.gap;
                const down_score = @as(i16, table[ri][ci - 1]) + self.gap;
                table[ri][ci] = @as(u8, @intCast(@max(0, @max(@max(diag_score, up_score), down_score))));
            }
        }
        debugTable(table, word, pattern);

        const return_val = getTableMax(table);

        return return_val;
    }
    fn free_table(table: [][]u8, allocator: std.mem.Allocator) void {
        for (table) |*elem| {
            allocator.free(elem.*);
        }
        allocator.free(table);
    }

    fn getTableMax(table: [][]u8) u8 {
        var res: u8 = 0;
        const table_len = table.len;
        for (table[table_len - 1]) |elem| {
            if (elem > res) {
                res = elem;
            }
        }
        return res;
    }

    fn debugTable(table: [][]u8, word: []const u8, pattern: []const u8) void {
        std.log.debug("      ", .{});
        for (pattern) |char| {
            std.log.debug("  {c}", .{char});
        }
        std.log.debug("\n", .{});

        for (table, 0..) |row, idx| {
            if (idx != 0) {
                std.log.debug(" {c} ", .{word[idx - 1]});
            } else {
                std.log.debug("   ", .{});
            }

            for (row) |col| {
                std.log.debug("{d:>3} ", .{col});
            }
            std.log.debug("\n", .{});
        }
    }
};

test "hello" {
    const word = "hello";
    const pattern = "hll";
    const allocator = std.testing.allocator;

    const expect = 10;
    const seeker = Seeker.init(4, -1, -2);
    const res = try seeker.getScore(word, pattern, allocator);

    try std.testing.expectEqual(expect, res);
}

test "DNA" {
    const word = "AAATTGGAATTGAGGAA";
    const pattern = "AATTGGAATTA";
    const allocator = std.testing.allocator;

    const expect = 42;
    const seeker = Seeker.init(4, -1, -2);
    const res = try seeker.getScore(word, pattern, allocator);

    try std.testing.expectEqual(expect, res);
}

test "Hella" {
    const word = "hello";
    const pattern = "hella";
    const allocator = std.testing.allocator;

    const expect = 16;
    const seeker = Seeker.init(4, -1, -2);
    const res = try seeker.getScore(word, pattern, allocator);

    try std.testing.expectEqual(expect, res);
}
