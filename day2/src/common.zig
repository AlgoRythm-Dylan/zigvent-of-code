const std = @import("std");

pub fn openInputFile() !std.fs.File {
    return try std.fs.cwd().openFile("input.txt", .{});
}
