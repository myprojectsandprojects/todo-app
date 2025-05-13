const std = @import("std");

var string_buffer: [1024]u8 = undefined;
const STR_BUF_LEN = string_buffer.len;
const TODOS_MAX = STR_BUF_LEN;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var used_len: usize = 0;
    //const free = string_buffer[0..];
    //const free = &string_buffer;
    //std.debug.print("free: {}\n", .{@TypeOf(free)});

    var todos: [STR_BUF_LEN][]u8 = undefined;
    var num_todos: usize = 0;

    var in_use = [_]bool{false} ** TODOS_MAX;

    while (true) {
        _ = try stdout.write("> ");

        const input = try stdin.readUntilDelimiter(string_buffer[used_len..], '\n');

        if (input.len == 0) {
            continue;
        } else if (input.len == 1 and input[0] == 'p') {
            var count: usize = 0;

            _ = try stdout.print("Your todos:\n", .{});

            var index: usize = 0;
            while (index < num_todos) : (index += 1) {
                if (in_use[index]) {
                    count += 1;
                    _ = try stdout.print("#{}: {s}\n", .{count, todos[index]});
                }
            }

            if (count == 0) {
                _ = try stdout.print("[You've got nothin to do...]\n", .{});
            }

            continue;
        } else if (input.len > 2 and std.mem.eql(u8, input[0..2], "d ")) {
            //} else if (input.len > 2 and input[0] == 'd' and input[1] == ' ') {
            //const todo_num_delete = try std.fmt.parseInt(u8, input[2..], 10);
            const todo_num_delete = std.fmt.parseInt(u8, input[2..], 10) catch |err| {
                try stdout.print("Invalid number: {s}\n", .{@errorName(err)});
                continue;
            };

            var successful = false;

            var todo_num: usize = 1;
            var index: usize = 0;
            while (index < num_todos) : (index += 1) {
                if (in_use[index]) {
                    if (todo_num == todo_num_delete) {
                        in_use[index] = false;
                        successful = true;
                        break;
                    }
                    todo_num += 1;
                }
            }

            if (!successful) {
                std.debug.print("Can't find the todo you specified: {}\n", .{todo_num_delete});
            }

            continue;
        } else if (input.len == 1 and input[0] == 'q') {
            break;
        } else if (input[0] == 'h') {
            try stdout.print(
                \\Commands:
                \\  [text] - Add todo
                \\  p      - Print todos
                \\  d [n]  - Delete todo
                \\  q      - Quit
                \\  h      - Help
                \\
                , .{});
            continue;
        } else {
            used_len += input.len;
            todos[num_todos] = input;
            in_use[num_todos] = true;
            num_todos += 1;
        }

        if (num_todos == TODOS_MAX) {
            break;
        }
    }
}
