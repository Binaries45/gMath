
const std = @import("std");
const helpers = @import("helpers.zig");

/// construct an `N` dimensional vector with elements of type `T`
pub fn Vec(N: comptime_int, T: type) type {
    if (N > 4) 
        @compileError("vectors can have no more than 4 components");
    
    if (!helpers.isScalar(T)) 
        @compileError(@typeName(T) ++ " is not a valid scalar type");

    return extern struct {
        v: @Vector(N, T),
        const V = @This();

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

        /// add some scalar to each element in the vector
        pub fn addScalar(v: V, s: T) V {
            return .{ .v = v.v + V.splat(s) };
        }
        
        /// subtract some scalar from each element in the vector
        pub fn subScalar(v: V, s: T) V {
            return .{ .v = v.v - V.splat(s) };
        }
        
        /// multiply some scalar by each element in the vector
        pub fn mulScalar(v: V, s: T) V {
            return .{ .v = v.v * V.splat(s) };
        }
        
        /// divide each element in the vector by some scalar
        pub fn divScalar(v: V, s: T) V {
            return .{ .v = v.v / V.splat(s) };
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

        pub fn swizzle(v: V, comptime mask: []const u8) Vec(mask.len, T) {
            const m = comptime blk: {
                var m: [mask.len]i32 = undefined;
                for (mask, 0..) |c, i| {
                    const lane: i32 = switch (c) {
                        'x', 'r' => 0,
                        'y', 'g' => 1,
                        'z', 'b' => 2,
                        'w', 'a' => 3,
                        else => @compileError("invalid swizzle char " ++ c),
                    };
                    if (lane >= N) @compileError("swizzle out of range");
                    m[i] = lane;
                } 
                break :blk m;
            };
            return .{ .v = @shuffle(T, v.v, undefined, m) };
        }
    };
}

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

// TODO : test scalar ops

test "dot product" {
    const x: Vec(3, i32) = .{ .v = .{1, 0, 0} };
    const y: Vec(3, i32) = .{ .v = .{0, 1, 0} };

    try std.testing.expect(x.dot(y) == 0);
}

test "length" {
   const x: Vec(2, f32) = .{ .v = .{1, 0} }; 
   const a: Vec(3, f32) = .splat(3); 

   try std.testing.expect(x.len() == 1);
   try std.testing.expect(a.len() == std.math.sqrt(@as(f32, 27)));
}

test "swizzle" {
    const a: Vec(4, f32) = .{ .v = .{1, 2, 3, 4} };
    const s = a.swizzle("wzyx");

    try std.testing.expect(std.meta.eql(s, .{ .v = .{4, 3, 2, 1} }));
}
