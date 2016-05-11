import Base: getindex, push!, empty!, length, sort!

export
    Population,
    getindex,
    push!,
    empty!,
    length,
    randomize!,
    sort!,
    release!

immutable Population{C}
    ctx::C
    comparer::AbstractComparer
    decode::Function
    _entities::Vector{Entity}
end

Population{C}(ctx::C, comparer::AbstractComparer, decode::Function) =
    Population(ctx, comparer, decode, Vector{Entity}())

length(pop::Population) = length(pop._entities)

getindex(pop::Population, idx) = pop._entities[idx]

push!(pop::Population, entity::Entity) = push!(pop._entities, entity)

push!(pop::Population, dna::DNA) = push!(pop._entities, Entity(dna, pop.decode(dna)))

function randomize!(pop::Population, populationSize::Int, dnaSize::Int)
    empty!(pop)
    for i in 1:populationSize
        dna = DNA(pop.ctx, dnaSize)
        randomizeUniform!(dna)
        push!(pop, dna)
    end
    sort!(pop)
end

function sort!(pop::Population)
    sort!(pop._entities, by = e -> e.body, lt = pop.comparer)
    first(pop._entities)
end

function release!(pop::Population)
    for entity in pop._entities
        release!(entity)
    end
end

function empty!(pop::Population)
    empty!(pop._entities)
end
