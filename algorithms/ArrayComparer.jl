type ArrayComparer{T::Vector} <: AbstractComparer{T}
    c::Comparer{T}
end

ArrayComparer{T}() = ArrayComparer{T}(Comparer{T}())

ArrayComparer{T}(fn::Function) = ArrayComparer{T}(Comparer{T}(fn))

ArrayComparer{T}(ac::AbstractComparer{T}) = ArrayComparer{T}(Comparer{T}(ac))

fn{T}(ac::ArrayComparer{T}) = (a, b) ->
begin
    baseFn = fn(ac.c)

    all = map(i -> (i, 1), a)
    merge!(all, map(i -> (i, 2), b))

    sort!(all, by = i -> i[1], lt = baseFn)

    score = 0
    arr1Points = 0
    arr2Points = 0

    for idx in 1:length(all)
        result = 0
        if idx > 1
            result = baseFn(all[idx - 1][1], all[idx][1])
        end
        if result < 0
            arr1Points += score
        else
            arr2Points += score
        end
    end

    arr1Points < arr2Points
end

function reset!{T}(ac::ArrayComparer{T})
    reset!(ac.c)
end
