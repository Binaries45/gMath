
const std = @import("std");
const Vec = @import("vector.zig").Vec;

pub fn Quat(T: type) type {
    // ensure T is a float type

    return struct {
        v: @Vector(4, T),

        const Q = @This();
        const V = Vec(4, T);

        pub const zero: Q = .{ .v = V.splat(0).v };

        pub const identity: Q = .{ .v  = V.fromArray(.{0, 0, 0, 1}).v };
    
        pub const nan: Q = .{ .v = V.splat(std.math.nan(T)).v };
   
        // TODO : from xyzw, array, vec4,
        //        from axis angle, from scaled axis, 
        //        from rotation (x,y,z,w)
        //        from euler, from roation axes
        //        from mat3 & mat4
        //        to array, to xyz vector
        //        conjugate
        //        inverse, dot, length, length^2
        //        length reciprocal,
        //        is finite, is nan, is normalized
        //        ...OTHERS 
    };
}

test "basic" {
    const eql = std.meta.eql;
    const expect = std.testing.expect;

    try expect(eql(Quat(f32).zero.v, Vec(4, f32).splat(0).v));
}
