type T
end

f(t::T) = 5

t = T()

@show length(methods(f, (T, )))
