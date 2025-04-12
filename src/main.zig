const std = @import("std");

pub const Base64 = struct {
    table: *const [64]u8,

    pub fn init() Base64 {
        const upper_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower_letters = "abcdefghijklmnopqrstuvwxyz";
        const numbers = "0123456789";
        const signs = "+/";

        return .{ .table = upper_letters ++ lower_letters ++ numbers ++ signs };
    }

    fn char_at(self: Base64, index: u8) u8 {
        return self.table[index];
    }

    fn calculate_output_length(input: []const u8) !usize {
        if (input.len < 3) {
            return 4;
        }

        return try std.math.divCeil(usize, input.len, 3) * 4;
    }

    fn calculate_decode_length(input: []const u8) !usize {
        if (input.len < 3) {
            return 4;
        }

        const groups: usize = try std.math.divFloor(usize, input.len, 4);
        var multiple_groups = groups * 3;
        var i: usize = input.len - 1;

        while (i > 0) : (i -= 1) {
            if (input[i] == '=') {
                multiple_groups -= 1;
            } else {
                break;
            }
        }
        return multiple_groups;
    }

    fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        const output = try allocator.alloc(u8, try calculate_output_length(input));
        var count: u8 = 0;
        var tmp = [3]u8{ 0, 0, 0 };

        for (input, 0..) |_, i| {
            tmp[count] = input[i];
            count += 1;

            if (count == 3) {
                output[0] = self.char_at(tmp[0] >> 2);
                output[1] = self.char_at(((tmp[0] & 0x03) << 4) + (tmp[1] >> 4));
                output[2] = self.char_at(((tmp[1] & 0x0f) << 2) + (tmp[2] >> 6));
                output[3] = self.char_at(tmp[2] & 0x3f);
                count = 0;
            }

            if (count == 2) {
                // TODO:
            }
            if (count == 1) {
                // TODO:
            }
        }

        std.debug.print("base64: {s}\n", .{output});
        return output;
    }

    fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) []const u8 {
        const decoded = try allocator.alloc(u8, calculate_decode_length(input));
        _ = self;
        return decoded;
    }
};

pub fn main() !void {
    const base64 = Base64.init();
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();
    const material = "elo"; // base64: aGkgaXRzIG1l

    const encoded = try base64.encode(alloc, material);
    defer alloc.free(encoded);

    std.debug.print("encodedc: {s}\n", .{encoded});
}
