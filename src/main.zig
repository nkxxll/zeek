const std = @import("std");
const sw = @import("./smith_waterman.zig");

pub const log_level: std.log.Level = .warn;

const Line = struct {
    score: u8,
    string: []const u8,

    fn init(score: u8, string: []const u8) Line {
        return Line{ .score = score, .string = string };
    }

    fn compareLine(context: void, a: Line, b: Line) bool {
        _ = context;
        if (a.score > b.score) {
            return true;
        } else {
            return false;
        }
    }

    fn toString(self: Line, rank: u8, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d} {s} {d}", .{ rank, self.string, self.score });
    }
};

/// returns a line slice that is sorted in the right order of the scores
fn output(input: []const u8, pattern: []const u8, allocator: std.mem.Allocator) ![]Line {
    var list = std.mem.splitScalar(u8, input, '\n');
    var array_list = std.ArrayList(Line).init(allocator);
    defer array_list.deinit();

    while (list.next()) |next| {
        const score = try sw.generateTable(next, pattern, allocator);
        if (score > 0) {
            try array_list.append(Line.init(score, next[0..next.len]));
        }
    }

    const list_slice = try array_list.toOwnedSlice();
    std.sort.heap(Line, list_slice, {}, Line.compareLine);

    return allocator.dupe(Line, list_slice);
}

fn printLines(lines: []Line, file: std.fs.File) !void {
    const writer = file.writer();
    var buffer: [1024]u8 = undefined;
    var buffer_allocator = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = buffer_allocator.allocator();
    var rank: u8 = 1;

    for (lines) |line| {
        // todo: catch string too long
        const string = try line.toString(rank, allocator);
        try writer.print("{s}\n", .{string});
        allocator.free(string);
        rank += 1;
    }
}

pub fn main() !void {
    const stdin_reader = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut();
    const isTTY = std.io.getStdIn().isTty();
    // todo: learn about when to use which allocator;
    const allocator = std.heap.page_allocator;
    var buffer: [1024]u8 = undefined;
    var read_chars: usize = 0;

    // catch the error too much input
    if (!isTTY) {
        var args = try std.process.argsWithAllocator(allocator);
        _ = args.skip();
        if (args.next()) |arg| {
            read_chars = try stdin_reader.readAll(&buffer);
            const lines = try output(buffer[0..read_chars], arg, allocator);
            try printLines(lines, stdout);
        }
    } else {
        std.debug.print("This is a TTY we will fix this later", .{});
    }
}
