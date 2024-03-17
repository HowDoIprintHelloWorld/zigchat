const std = @import("std");
const net = std.net;
const mem = std.mem;
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const conf_value = union { int: i16, float: f16, string: [20]u8, bool: bool };

fn read_conf(file_name: []const u8) !std.StringHashMap(conf_value) {
    const allocator = std.heap.page_allocator;
    var conf = std.StringHashMap(conf_value).init(allocator);
    var file_reader = std.fs.cwd().openFile(file_name, .{});
    if (file_reader) |file| {
        defer file.close();
        var buf: [1024]u8 = undefined;
        while (try file.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
            var line_split = mem.split(u8, line, "=");
            if (line_split.len == 2) {
                conf.put(line_split[0], line_split[1]);
            }
        }
    } else |_| {}
    return conf;
}

fn get_input() ![10]u8 {
    var buf: [10]u8 = undefined;
    var passedNewline: bool = false;
    _ = try stdin.readUntilDelimiterOrEof(&buf, '\n');
    for (&buf) |*char| {
        if (char.* == 10) {
            passedNewline = true;
        }
        if (passedNewline) {
            char.* = 0;
        }
    }
    return buf;
}

pub fn main() !void {
    _ = try read_conf("client_settings.conf");
    const localhost: net.Address = net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 8080);
    _ = try net.tcpConnectToAddress(localhost);
    var input: [10]u8 = try get_input();
    try stdout.print("Input: {s}\n", .{input});
}
