import Base: isnull, get

export BestEntity, isnull, get, reset!, set!, update!, release!

type BestEntity
    comparer::AbstractComparer
    value::Nullable{Entity}

    BestEntity(comparer) = new(comparer, Nullable{Entity}())
end

release!(best::BestEntity) = reset!(best)

isnull(best::BestEntity) = isnull(best.value)

get(best::BestEntity) = get(best.value)

reset!(best::BestEntity) = set!(best, Nullable{Entity}())

set!(best::BestEntity, value::Entity) = set!(best, Nullable{Entity}(value))

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

update!(best::BestEntity, value::Entity) = update!(best, Nullable{Entity}(value))

function update!(best::BestEntity, other::Entity)
    if isnull(best) || best.comparer(other.body, get(best).body)
        set!(best, other)
        return true
    end
    false
end
