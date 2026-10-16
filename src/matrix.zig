
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
            inline for (0..C) |i| res[i][i] = @as(T, 1);
            return res;
        }

        // TODO : 
        // - transpose
        // - scalar ops
        // - mul (mat x vec, vec x mat, mat x mat)
        // - look at
        // - perspective
        // - rotate
        // - other transformations too
    };
}
