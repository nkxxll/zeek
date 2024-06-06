const std = @import("std");
const sw = @import("./smith_waterman.zig");

pub const std_options: std.Options = .{
    // Set the log level to info
    .log_level = .warn,

    .logFn = myLogFn,
};

/// no fancy format I formatted the output myself
pub fn myLogFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = scope;
    _ = level;
    std.debug.getStderrMutex().lock();
    defer std.debug.getStderrMutex().unlock();
    const stderr = std.io.getStdErr().writer();
    nosuspend stderr.print(format, args) catch return;
}

const WrongIndexError = error{
    IndexToHigh,
    IndexToLow,
    NotAnIndex,
};

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
        return try std.fmt.allocPrint(allocator, "<{d}> {s} ({d})", .{ rank, self.string, self.score });
    }
};

/// returns a line slice that is sorted in the right order of the scores
fn output(input: []const u8, pattern: []const u8, allocator: std.mem.Allocator) ![]Line {
    var list = std.mem.splitScalar(u8, input, '\n');
    var array_list = std.ArrayList(Line).init(allocator);
    defer array_list.deinit();
    const seeker = sw.Seeker.init(2, -1, -2);

    while (list.next()) |next| {
        const score = try seeker.getScore(next, pattern, allocator);
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

fn readUserNumber(lines_nr: usize) !u8 {
    var res: u8 = 0;
    const file = "/dev/tty";
    const fd = try std.fs.openFileAbsolute(file, .{});
    var input: [10]u8 = undefined;

    const tty_reader = fd.reader();
    if (try tty_reader.readUntilDelimiterOrEof(&input, '\n')) |in| {
        res = try std.fmt.parseInt(u8, in, 10);
    } else {
        return WrongIndexError.NotAnIndex;
    }

    if (res >= lines_nr) {
        return WrongIndexError.IndexToHigh;
    } else if (res < 0) {
        return WrongIndexError.IndexToLow;
    } else {
        return res;
    }
}

pub fn main() !void {
    const stdin = std.io.getStdIn();
    std.debug.print("{}", .{stdin});
    const stdin_reader = stdin.reader();
    const stdout = std.io.getStdOut();
    const isTTY = std.io.getStdIn().isTty();
    // todo: learn about when to use which allocator;
    const allocator = std.heap.page_allocator;

    // catch the error too much input
    if (!isTTY) {
        var args = try std.process.argsWithAllocator(allocator);
        _ = args.skip();
        if (args.next()) |arg| {
            const read_chars = try stdin_reader.readAllAlloc(allocator, 1024 * 1024);
            defer allocator.free(read_chars);
            const lines = try output(read_chars, arg, allocator);
            defer allocator.free(lines);
            // enter and leave alt screen
            //_ = try stdout.write("\x1b[?1049h");
            //_ = try stdout.write("\x1b[?1049l");
            try printLines(lines, stdout);
            // todo handle errors
            if (readUserNumber(lines.len)) |number| {
                _ = try stdout.write(lines[number].string);
            } else |err| {
                switch (err) {
                    WrongIndexError.IndexToHigh => {},
                    WrongIndexError.IndexToLow => {},
                    WrongIndexError.NotAnIndex => {},
                    else => unreachable,
                }
            }
            // the number should allways be less than the list len
        }
    } else {
        std.debug.print("This is a TTY we will fix this later", .{});
    }
}
