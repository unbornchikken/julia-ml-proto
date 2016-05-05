import Base: isnull, get

export BestEntity, isnull, get, reset!, set!, update!

type BestEntity
    comparer::Comparer
    value::Nullable{Entity}

    BestEntity(comparer) = new(comparer, Nullable{Entity}())
end

isnull(best::BestEntity) = isnull(best.value)

get(best::BestEntity) = get(best.value)

reset!(best::BestEntity) = set!(best, Nullable{Entity}())

function set!(best::BestEntity, value::Nullable{Entity})
    if !isnull(best)
        release!(get(best))
    end
    if isnull(value)
        best.value = Nullable{Entity}()
    else
        best.value = copy(get(value))
    end
end

function update!(best::BestEntity, other)
    if isnull(best) || fn(best.comparer)(other, get(best))
        set!(best, other)
        return true
    end
    false
end
