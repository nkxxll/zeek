const std = @import("std");
const sw = @import("./smith_waterman.zig");

pub fn main() !void {
    // get something from the command line
    // to be continued...
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const isTTY = std.io.getStdIn().isTty();
    var buffer: [1024]u8 = undefined;
    const echo = "echo: ";
    // catch the error too much input
    if (!isTTY) {
        _ = try stdin.readAll(&buffer);
    } else {
        _ = try stdout.write("please enter a string: ");
        _ = try stdin.readAll(&buffer);
    }
    _ = try stdout.write(echo ++ buffer);
}
