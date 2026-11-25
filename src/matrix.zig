
const std = @import("std");
const math = std.math;
const helpers = @import("helpers.zig");
const radians = helpers.radians;

const Vec = @import("vector.zig").Vec;
const Vec3 = Vec(3, f32);
const Mat4 = Mat(4, 4, f32);

/// reutrns a column major matrix with R rows and C columns, and elements of type T
pub fn Mat(R: comptime_int, C: comptime_int, T: type) type {
    if (C > 4) 
        @compileError("Matrices can have at most 4 columns");

    return struct {
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
        pub fn transpose(m: M) Mat(C, R, T) {
            // if (C == 4 and R == 4) return transpose4(m);
            const RM = Mat(C, R, T);
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
    };
}

// TODO : other transformation matrices

/// create a translation matrix from the given vector
pub fn translate(t: Vec3) Mat4 {
    var res: Mat4 = .indentity();
    res.m[3].v[0] = t.v[0];
    res.m[3].v[1] = t.v[1];
    res.m[3].v[2] = t.v[2];
    return res;
}

///
pub fn rotate(angle: f32, axis_unorm: Vec3) Mat4 {
    var res: Mat4 = .indentity();
    
    const axis = axis_unorm.normalize();
    const sin_theta = math.sin(radians(angle));
    const cos_theta = math.cos(radians(angle));
    const cos_value = 1.0 - cos_theta;

    res.m[0].v[0] = (axis.v[0] * axis.v[0] * cos_value) + cos_theta;
    res.m[0].v[1] = (axis.v[0] * axis.v[1] * cos_value) + (axis.v[2] * sin_theta);
    res.m[0].v[2] = (axis.v[0] * axis.v[2] * cos_value) - (axis.v[1] * sin_theta);
    res.m[1].v[0] = (axis.v[1] * axis.v[0] * cos_value) - (axis.v[2] * sin_theta);
    res.m[1].v[1] = (axis.v[1] * axis.v[1] * cos_value) + cos_theta;
    res.m[1].v[2] = (axis.v[1] * axis.v[2] * cos_value) + (axis.v[0] * sin_theta);
    res.m[2].v[0] = (axis.v[2] * axis.v[0] * cos_value) + (axis.v[1] * sin_theta);
    res.m[2].v[1] = (axis.v[2] * axis.v[1] * cos_value) - (axis.v[2] * sin_theta);
    res.m[2].v[2] = (axis.v[2] * axis.v[2] * cos_value) + cos_theta;

    return res;
}

/// 
pub fn lookat(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
    var res: Mat4 = .zero();
    
    const f = center.sub(eye).normalize();
    const s = f.cross(up).normalize();
    const u = s.cross(f);

    res.m[0].v[0] =  s.v[0];
    res.m[0].v[1] =  u.v[0];
    res.m[0].v[2] = -f.v[0];

    res.m[1].v[0] =  s.v[1];
    res.m[1].v[1] =  u.v[1];
    res.m[1].v[2] = -f.v[1];

    res.m[2].v[0] =  s.v[2];
    res.m[2].v[1] =  u.v[2];
    res.m[2].v[2] = -f.v[2];

    res.m[3].v[0] = -s.dot(eye);
    res.m[3].v[1] = -u.dot(eye);
    res.m[3].v[2] =  f.dot(eye);
    res.m[3].v[3] =  1.0;

    return res;
}

/// construct a perpective projection matrix from the given params
pub fn persp(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
    const M = Mat4;
    var res: M = .indentity();

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
    const m: Mat(3, 3, i32) = .{ .m = .{
        .{ .v = .{1, 2, 3} },
        .{ .v = .{1, 2, 3} },
        .{ .v = .{1, 2, 3} },
    }};

    const tm = m.transpose();
    const expected: Mat(3, 3, i32) = .{ .m = .{ 
        .{ .v = .{1, 1, 1} },
        .{ .v = .{2, 2, 2} },
        .{ .v = .{3, 3, 3} },
    }};

    try std.testing.expect(std.meta.eql(tm, expected));
}
