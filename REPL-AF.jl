type A{T}
    x
    y

    A{N}(x::T, y::N) = new(x,y)
end

v = A{Int}(1, 2.0)
typeof(v.y)
