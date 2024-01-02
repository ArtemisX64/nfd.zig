const std = @import("std");
const log = std.log.scoped(.nfd);

const c = @cImport({
    @cInclude("nfd.h");
});

pub const Error = error{
    NFDError,
};

pub fn makeError() Error {
    if (c.NFD_GetError()) |ptr| {
        log.debug("{s}\n", .{std.mem.sliceTo(ptr, 0)});
    }
    return error.NFDError;
}

pub fn openFileDialog(allocator: std.mem.Allocator, path: ?[]const u8, filter: ?[]const u8) Error!?[]const u8 {
    const new_path = if (path) |p| allocator.dupeZ(u8, p) catch @panic("Error Converting String") else null;
    const new_filter = if (filter) |f| allocator.dupeZ(u8, f) catch @panic("Error Converting String") else null;
    const npath = try openFileDialogZ(new_path, new_filter);
    return if (npath) |np| std.mem.sliceTo(np, 0) else null;
}

pub fn openFileDialogZ(path: ?[:0]const u8, filter: ?[:0]const u8) Error!?[:0]const u8 {
    var out_path: [*c]u8 = null;

    const result = c.NFD_OpenDialog(if (filter) |f| f else null, if (path) |p| p else null, &out_path);
    return switch (result) {
        c.NFD_OKAY => if (out_path) |op| std.mem.sliceTo(op, 0) else null,
        c.NFD_ERROR => makeError(),
        else => null,
    };
}
