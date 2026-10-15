
const helpers = @import("helpers.zig");

/// construct an `N` dimensional vector with elements of type `T`
pub fn Vec(N: comptime_int, T: type) type {
    if (!helpers.isScalar(T)) 
        @compileError(@typeName(T) ++ " is not a valid scalar type");

    return extern struct {
        v: @Vector(N, T),
        const V = @This();

        // TODO : vector functions
    };
}

// TODO : tests
