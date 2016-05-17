export Stabilizer, start!, step!

const MIN_MOVEMENT = 0.00001f0

immutable Stabilizer{C, A} <: OptAlgo{C}
    ctx::C
    populationSize::Int
    dnaSize::Int
    followRate::Float32
    pitchRate::Float32
    historySize::Int
    steps::Int
    dissolvingChance::Float32
    comparer::AbstractComparer
    decode::Function
    best::BestEntity
    mean::A
    strength::A
    history::Vector{Tuple{A, A}}
    lastEntity::Nullable{Entity}
end

Stabilizer(
    ctx,
    dnaSize,
    comparer::AbstractComparer,
    decode::Function;
    followRate = 0.8f0,
    pitchRate = 0.7f0,
    historySize = 100,
    steps = 20,
    dissolvingChance = 0.1f0) =
Stabilizer(
    ctx,
    populationSize,
    dnaSize,
    followRate,
    pitchRate,
    historySize,
    step,
    dissolvingChance,
    comparer,
    decode,
    BestEntity(comparer),
    array(ctx),
    array(ctx),
    Vector{Tuple{A, A}}(),
    Nullable{Entity}())

function start!(st::Stabilizer)
    reset!(st.comparer)

    scope!(st.ctx) do this
        st.mean[] = constant(st.ctx, 0.5f, st.dnaSize)
        st.strength[] = constant(st.ctx, 1f, st.dnaSize)
    end

    clearHistory!(st)

    if !isnull(st.lastEntity)
        releae!(get(st.lastEntity))
    end
    entity = createEntity(st)
    st.lastEntity = entity

    try
        update!(st.best, entity)
    finally
        release!(entity)
    end
end

function step!(st::Stabilizer)
    reset!(st.comparer)

    for i in 1:st.steps
        newEntity = createEntity(st)
        if st.comparer(newEntity.body, st.lastEntity.body)
            scope!(st.ctx) do this
                shrink!(st, follow!(st, newEntity.dna.array))
            end
            update!(st.best, newEntity)
            pushToHistory!(st)
        elseif rand() < st.dissolvingChance
            item = popFromHistory!(st)
            if !isnull(item)
                savedMean, savedStr = get(item)
                st.mean[] = savedMean
                st.strength[] = savedStr
                release!(savedMean)
                release!(savedStr)
            end
        end
        release!(get(st.lastEntity))
        st.lastEntity = newEntity
    end
end

function follow!(st::Stabilizer, arr)
    movement = (arr .- st.mean) .* st.followRate
    addAssign!(st.mean, movement)
    maxOf(abs(movement), MIN_MOVEMENT)
end

shrink!(st::Stabilizer, movement) = subAssign!(st.strength, st.strength .* movement .* st.pitchRate)

function createEntity(st::Stabilizer)
    dna = scope!(st.ctx) do this
        arr = (randu(st.ctx, Float32, st.dnaSize) .* st.strength) .+ (st.mean .- st.strength ./ 2.0f)
        dna = DNA(st.ctx, arr)
        normalize!(dna)
        this.result(dna.array)
    end
    Entity(dna, st.decode(dna))
end

function clearHistory!(st::Stabilizer)
    for arr1, arr2 in st.history
        release!(arr1)
        release!(arr2)
    end
    empty!(st.history)
end

function pushToHistory!(st::Stabilizer)
    push!(st.history, (st.mean, st.strength))
    if length(st.history) > st.historySize
        release!(shift!(st.history))
    end
end

popFromHistory!{C, A}(st::Stabilizer{C, A}) =
    length(st.history) > 0 ?
        Nullable{Tuple{A, A}}(pop!(st.history)) :
        Nullable{Tuple{A, A}}()
