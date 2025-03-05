const std = @import("std");
const common = @import("./common.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    try part1(allocator);
    try part2(allocator);
}

fn part1(allocator: std.mem.Allocator) !void {
    const levels = try readLevelsIntoMemory(allocator);
    var safe_count: u64 = 0;
    for(0..levels.items.len) |i| {
        if(levels.items[i].isSafe()){
            safe_count += 1;
        }
        // Done with this item!
        levels.items[i].deinit();
    }
    levels.deinit();
    std.debug.print("Safe levels: {}\n", .{ safe_count });
}

fn part2(allocator: std.mem.Allocator) !void {
    _ = allocator;
}

const Level = struct {
    reports: std.ArrayList(i64) = undefined,

    pub fn deinit(self: *Level) void {
        self.reports.deinit();
    }

    pub fn isSafe(self: *Level) bool {
        return self.isSequential() and self.reportsAreClose();
    }

    pub fn isSequential(self: *Level) bool {
        if(self.reports.items.len <= 2) {
            return true;
        }
        const is_asc = self.reports.items[0] < self.reports.items[1];
        for(2..self.reports.items.len) |i| {
            const diff: i64 = self.reports.items[i] - self.reports.items[i - 1];
            if(is_asc){
                if(diff < 1){
                    return false;
                }
            }
            else {
                if(diff > 1){
                    return false;
                }
            }
        }
        return true;
    }

    pub fn reportsAreClose(self: *Level) bool {
        for(1..self.reports.items.len) |i| {
            const diff = @abs(self.reports.items[i - 1] - self.reports.items[i]);
            if(diff >= 3 or diff < 1){
                return false;
            }
        }
        return true;
    }

};

fn readLevelsIntoMemory(allocator: std.mem.Allocator) !std.ArrayList(Level) {
    var ifile = try common.openInputFile();
    var buffer: [256]u8 = undefined;
    const file_reader = ifile.reader();
    var br = std.io.bufferedReader(file_reader);
    var buffered_reader = br.reader();

    var list = std.ArrayList(Level).init(allocator);

    while(try buffered_reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const stripped_line: []u8 = if(line[line.len - 1] == '\r') line[0..line.len-1] else line;
        var iter = std.mem.splitScalar(u8, stripped_line, ' ');
        var this_list = Level {
            .reports = std.ArrayList(i64).init(allocator)
        };
        while(iter.next()) |number_str| {
            const number = try std.fmt.parseInt(i64, number_str, 10);
            try this_list.reports.append(number);
        }
        try list.append(this_list);
    }

    return list;
}