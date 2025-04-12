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

    fn char_index(self: Base64, char: u8) u8 {
        if (char == '=')
            return 64;

        var index: u8 = 0;
        for (0..63) |_| {
            if (self.char_at(index) == char)
                break;
            index += 1;
        }

        return index;
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
        var idx: u8 = 0;

        for (input, 0..) |_, i| {
            tmp[count] = input[i];
            count += 1;

            if (count == 3) {
                output[idx] = self.char_at(tmp[0] >> 2);
                output[idx + 1] = self.char_at(((tmp[0] & 0x03) << 4) + (tmp[1] >> 4));
                output[idx + 2] = self.char_at(((tmp[1] & 0x0f) << 2) + (tmp[2] >> 6));
                output[idx + 3] = self.char_at(tmp[2] & 0x3f);
                count = 0;
                idx += 4;
            }

            if (count == 2) {
                output[idx] = self.char_at(tmp[0] >> 2);
                output[idx + 1] = self.char_at(((tmp[0] & 0x03) << 4) + (tmp[1] >> 4));
                output[idx + 2] = self.char_at(((tmp[1] & 0x0f) << 2) + (tmp[2] >> 6));
                output[idx + 3] = '=';
            }

            if (count == 1) {
                output[idx] = self.char_at(tmp[0] >> 2);
                output[idx + 1] = self.char_at(((tmp[0] & 0x03) << 4) + (tmp[1] >> 4));
                output[idx + 2] = '=';
                output[idx + 3] = '=';
            }
        }

        return output;
    }

    fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        var decoded = try allocator.alloc(u8, try calculate_decode_length(input));
        var count: u8 = 0;
        var tmp = [4]u8{ 0, 0, 0, 0 };
        var idx: u8 = 0;

        for (0..input.len) |i| {
            tmp[count] = self.char_index(input[i]);
            count += 1;

            if (count == 4) {
                decoded[idx] = (tmp[0] << 2) + (tmp[1] >> 4);

                if (tmp[2] != 64) {
                    decoded[idx + 1] = (tmp[1] << 4) + (tmp[2] >> 2);
                }

                if (tmp[3] != 64) {
                    decoded[idx + 2] = (tmp[2] << 6) + tmp[3];
                }

                count = 0;
                idx += 3;
            }
        }

        return decoded;
    }
};

pub fn main() !void {
    const base64 = Base64.init();
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();
    const input = "Hello world";

    const encoded = try base64.encode(alloc, input);
    defer alloc.free(encoded);

    const decoded = try base64.decode(alloc, encoded);
    defer alloc.free(decoded);

    std.debug.print("input: {s}\n", .{input});
    std.debug.print("encoded: {s}\n", .{encoded});
    std.debug.print("decoded: {s}\n", .{decoded});
}
