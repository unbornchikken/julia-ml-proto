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
    entities::Vector{Entity}
end

Population{C}(ctx::C, comparer::AbstractComparer, decode::Function) =
    Population(ctx, comparer, decode, Vector{Entity}())

length(pop::Population) = length(pop.entities)

getindex(pop::Population, idx) = pop.entities[idx]

push!(pop::Population, entity::Entity) = (push!(pop.entities, entity); entity)

push!(pop::Population, dna::DNA) = push!(pop, Entity(dna, pop.decode(dna)))

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
    sort!(pop.entities, by = e -> e.body, lt = pop.comparer)
    first(pop.entities)
end

function release!(pop::Population)
    for entity in pop.entities
        release!(entity)
    end
end

function empty!(pop::Population)
    empty!(pop.entities)
end
