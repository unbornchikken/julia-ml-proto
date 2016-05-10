export ArrayComparer, fn, reset!

type ArrayComparer <: AbstractComparer
    c::AbstractComparer
end

ArrayComparer() = ArrayComparer(Comparer())

ArrayComparer(fn::Function) = ArrayComparer(Comparer(fn))

fn(ac::ArrayComparer) = (a::Vector, b::Vector) ->
begin
    baseFn = fn(ac.c)

    all = [map(i -> (i, 1), a); map(i -> (i, 2), b)]

    sort!(all, by = i -> i[1], lt = baseFn)

    score = 0
    arr1Points = 0
    arr2Points = 0

    for idx in 1:length(all)
        if idx > 1 && baseFn(all[idx - 1][1], all[idx][1])
            score += 1
        end
        if all[idx][2] == 1
            arr1Points += score
        else
            arr2Points += score
        end
    end

    arr1Points < arr2Points
end

function reset!(ac::ArrayComparer)
    reset!(ac.c)
end
