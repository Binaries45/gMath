
const std = @import("std");
const Vec = @import("vector.zig").Vec;

/// reutrns a column major matrix with R rows and C columns, and elements of type T
pub fn Matrix(R: comptime_int, C: comptime_int, T: type) type {
    if (C > 4) 
        @compileError("Matrices can have at most 4 columns");

    return extern struct {
        m: [C]Vec(R, T),

        /// the type of each column vector
        const V = Vec(R, T);
        const M = @This();

        /// returns the zero matrix
        pub fn zero() M {
            return @splat(V.splat(@as(T, 0)));
        }

        /// returns the identity matrix
        pub fn indentity() M {
            var res: M = .zero();
            inline for (0..C) |i| res.m[i].v[i] = @as(T, 1);
            return res;
        }

        /// transpose the given matrix
        pub fn transpose(m: M) Matrix(C, R, T) {
            const RM = Matrix(C, R, T);
            var res: RM = undefined;  

            // TODO : special transpose functions for square matrices?

            inline for (0..C) |c| inline for (0..R) |r| {
                // FIXME : this way of accessing values is really gross
                res.m[r].v[c] = m.m[c].v[r]; 
            }; 

            return res;
        }

        // TODO : 
        // - scalar ops
        // - mul (mat x vec, vec x mat, mat x mat)
        //   - generic mul handling all of the above
        // - look at
        // - perspective
        // - rotate
        // - other transformations too
    };
}

test "transpose" {
    const m: Matrix(3, 3, i32) = .{ .m = .{
        .{ .v = .{1, 2, 3} },
        .{ .v = .{1, 2, 3} },
        .{ .v = .{1, 2, 3} },
    }};

    const tm = m.transpose();
    const expected: Matrix(3, 3, i32) = .{ .m = .{ 
        .{ .v = .{1, 1, 1} },
        .{ .v = .{2, 2, 2} },
        .{ .v = .{3, 3, 3} },
    }};

    try std.testing.expect(std.meta.eql(tm, expected));
}
