import Base: copy

export Entity, release!, copy

immutable Entity{T}
    dna::DNA
    body::T
end

function Entity{T}(dna::DNA, body::T)
    Entity{T}(dna, body)
end

@generated function release!{T}(entity::Entity{T})
    if length(methods(release!, (T, ))) > 0
        :( release!(entity.body); release!(entity.dna) )
    else
        :( release!(entity.dna) )
    end
end

@generated function copy{T}(entity::Entity{T})
    if length(methods(copy, (T, ))) > 0
        :( Entity(copy(entity.dna), copy(entity.body)) )
    elseif length(methods(deepcopy, (T, ))) > 0
        :( Entity(copy(entity.dna), deepcopy(entity.body)) )
    else
        :( Entity(copy(entity.dna), entity.body) )
    end
end
