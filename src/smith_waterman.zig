const std = @import("std");

const sw_scoring = struct {
    match: i8,
    mismatch: i8,
    gap: i8,
};

fn generateTable(word: []const u8, pattern: []const u8) [][]u8 {
    const word_len = word.len;
    const pattern_len = pattern.len;
    var res: [word_len + 1][pattern_len + 1]u8 = undefined;

    // todo set the first row and column to zero
    for (res) |row| {
        @memset(&row, 0);
    }

    for (res, 1..) |row, ri| {
        for (row, 1..) |_, ci| {
            var diag_plus = 0;
            if (word[ri - 1] == pattern[ci - 1]) {
                // todo calc the field
                diag_plus = sw_scoring.match;
            }
            const diag_score = res[ri - 1][ci - 1] + diag_plus;
            const up_score = res[ri - 1][ci] + sw_scoring.gap;
            const down_score = res[ri][ci - 1] + sw_scoring.gap;
            const mismatch_score = res[ri - 1][ci - 1] + sw_scoring.mismatch;
            res[ri][ci] = std.math.maxInt(.{ 0, diag_score, up_score, down_score, mismatch_score });
        }
    }
    return res[0 .. word_len + 1][0 .. pattern_len + 1];
}
