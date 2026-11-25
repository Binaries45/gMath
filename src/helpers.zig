
const math = @import("std").math;

/// returns true if T is a valid scalar type
pub fn isScalar(T: type) bool {
    return switch (@typeInfo(T)) {
        .int, 
        .comptime_int, 
        .float, 
        .comptime_float => true,
        else => false,
    };
}

pub fn radians(deg: f32) f32 {
    return deg * (math.pi / 180.0);
}
