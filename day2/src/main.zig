const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    part1(allocator);
    part2(allocator);
}

fn part1(allocator: std.mem.Allocator) !void {
    _ = allocator;
}

fn part2(allocator: std.mem.Allocator) !void {
    _ = allocator;
}