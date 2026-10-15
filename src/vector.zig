
const std = @import("std");
const helpers = @import("helpers.zig");

/// construct an `N` dimensional vector with elements of type `T`
pub fn Vec(N: comptime_int, T: type) type {
    if (!helpers.isScalar(T)) 
        @compileError(@typeName(T) ++ " is not a valid scalar type");

    return extern struct {
        v: @Vector(N, T),
        const V = @This();

        // TODO : vector functions
        // - dot splat cross ...
        // - swizzle
        // - idk
        
        /// add two vectors
        pub fn add(a: V, b: V) V {
            return .{ .v = a.v + b.v };
        }
        
        /// subtract two vectors
        pub fn sub(a: V, b: V) V {
            return .{ .v = a.v - b.v };
        }
        
        /// multiply two vectors
        pub fn mul(a: V, b: V) V {
            return .{ .v = a.v * b.v };
        }
        
        /// divide two vectors
        pub fn div(a: V, b: V) V {
            return .{ .v = a.v / b.v };
        }

        /// return the dot product of two vectors
        pub fn dot(a: V, b: V) T {
            return @reduce(.Add, a.v * b.v);
        }

        pub fn splat(e: T) V {
            return .{ .v = @splat(e) };
        }

        /// return the magnitude of the vector
        pub fn len(v: V) T {
            return std.math.sqrt(v.dot(v));
        }
    };
}

// TODO : tests

test "basic math" {
    const a: Vec(3, u32) = .splat(1);
    const b: Vec(3, u32) = .splat(2);
    
    const c = a.add(b);
    try std.testing.expect(std.meta.eql(c, Vec(3, u32).splat(3)));
    
    const d = c.mul(c);
    try std.testing.expect(std.meta.eql(d, Vec(3, u32).splat(9)));
    
    const e = d.sub(.splat(3));
    try std.testing.expect(std.meta.eql(e, Vec(3, u32).splat(6)));

    const f = e.div(.splat(3));
    try std.testing.expect(std.meta.eql(f, Vec(3, u32).splat(2)));
}

test "dot product" {
    const x: Vec(3, i32) = .{ .v = .{1, 0, 0} };
    const y: Vec(3, i32) = .{ .v = .{0, 1, 0} };

    try std.testing.expect(x.dot(y) == 0);
}

test "length" {
    // TODO 
}
