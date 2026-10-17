
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

        /// special 4x4 matrix transpose.
        // fn transpose4(m: Matrix(4, 4, T)) Matrix(4, 4, T) {
            // TODO : this
        // }

        /// transpose the given matrix
        pub fn transpose(m: M) Matrix(C, R, T) {
            // if (C == 4 and R == 4) return transpose4(m);
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
        // - rotate
        // - other transformations too
    };
}

/// construct a perpective projection matrix from the given params
pub fn persp(fov: f32, aspect: f32, near: f32, far: f32) Matrix(4, 4, f32) {
    const Mat = Matrix(4, 4, f32);
    var res: Mat = .indentity();

    const t = std.math.tan(fov * (std.math.pi / 360));

    res.m[0].v[0] = 1 / t;
    res.m[1].v[1] = aspect / t;
    res.m[2].v[3] = -1;
    res.m[2].v[2] = (near + far) / (near - far);
    res.m[3].v[2] = (2 * near * far) / (near - far);
    res.m[3].v[3] = 0;

    return res;
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
