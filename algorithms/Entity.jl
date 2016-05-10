import Base: copy

export Entity, release!, copy

immutable Entity{C, A, T}
    dna::DNA{C, A}
    body::T
end

Entity{C, A, T}(dna::DNA{C, A}, body::T) = DNA{C, A, T}(dna, body)

@generated function release!{C, A, T}(entity::Entity{C, A, T})
    if length(methods(release!, (T, ))) > 0
        :( release!(entity.body); release!(entity.dna) )
    else
        :( release!(entity.dna) )
    end
end

@generated function copy{C, A, T}(entity::Entity{C, A, T})
    if length(methods(copy, (T, ))) > 0
        :( Entity(copy(entity.dna), copy(entity.body)) )
    elseif length(methods(deepcopy, (T, ))) > 0
        :( Entity(deepcopy(entity.body)) )
    else
        :( Entity(copy(entity.dna), entity.body) )
    end
end
