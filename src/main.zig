const std = @import("std");
const Io = std.Io;

const gMath = @import("gMath");

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("Hello, World!", .{});
}

test "main" {
    _ = gMath;
}
