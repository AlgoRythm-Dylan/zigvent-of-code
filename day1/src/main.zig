const std = @import("std");
const common = @import("./common.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    try part1(allocator);
    try part2(allocator);
}

const NumberPair = struct {
    first: i64 = undefined,
    second: i64 = undefined
};

fn part1(allocator: std.mem.Allocator) !void {
    var numbers = try readListsIntoMemoryAndSort(allocator);
    defer numbers.deinit();

    var total_distance: i64 = 0;
    for(0..numbers.first.items.len) |i| {
        total_distance += @intCast(@abs(numbers.first.items[i] - numbers.second.items[i]));
    }

    std.debug.print("Total distance: {}\n", .{ total_distance });

}

fn part2(allocator: std.mem.Allocator) !void {
    var numbers = try readListsIntoMemoryAndSort(allocator);
    defer numbers.deinit();

    var total_similarity: i64 = 0;
    for(0..numbers.first.items.len) |i| {
        total_similarity += numbers.first.items[i] * countOccurances(numbers.second.items, numbers.first.items[i]);
    }

    std.debug.print("Total similarity: {}\n", .{ total_similarity });
}

fn countOccurances(sortedList: []i64, target: i64) i64 {
    var count: i64 = 0;
    for(0..sortedList.len) |i| {
        if(sortedList[i] != target){
            if(sortedList[i] > target){
                return count;
            }
        }
        else {
            count += 1;
        }
    }
    return count;
}

fn parseNumbersFromLine(line: []const u8) !NumberPair {
    var np = NumberPair{};
    
    const index_maybe = std.mem.indexOf(u8, line, " ");
    if(index_maybe) |index| {
        np.first = try std.fmt.parseInt(i64, line[0..index], 10);
        np.second = try std.fmt.parseInt(i64, line[index + 3..], 10);
    }

    return np;
}

const NumberListPair = struct {
    first: std.ArrayList(i64) = undefined,
    second: std.ArrayList(i64) = undefined,

    pub fn deinit(self: *NumberListPair) void {
        self.first.deinit();
        self.second.deinit();
    }
};

fn readListsIntoMemoryAndSort(allocator: std.mem.Allocator) !NumberListPair {
    var ifile = try common.openInputFile();
    var buffer: [256]u8 = undefined;
    const file_reader = ifile.reader();
    var br = std.io.bufferedReader(file_reader);
    var buffered_reader = br.reader();

    var list1 = std.ArrayList(i64).init(allocator);
    var list2 = std.ArrayList(i64).init(allocator);

    while(try buffered_reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const stripped_line: []u8 = if(line[line.len - 1] == '\r') line[0..line.len-1] else line;
        const values = try parseNumbersFromLine(stripped_line);
        try list1.append(values.first);
        try list2.append(values.second);
    }

    std.mem.sort(i64, list1.items, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, list2.items, {}, comptime std.sort.asc(i64));
    
    return .{
        .first = list1,
        .second = list2
    };
}