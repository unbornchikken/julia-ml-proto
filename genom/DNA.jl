import Base.copy

export DNA, copy

type DNA{C, A}
    ctx::C
    array::A

    function DNA(ctx, size::Int)
        new(ctx, constant(ctx, 0.0f0, size))
    end

    function DNA(ctx, arr::A)
        new(ctx, copy(arr))
    end

    function DNA(other::DNA{A})
        new(other.ctx, copy(other.arr))
    end

    function DNA(ctx, arr::Vector{Float32})
        new(ctx, array(ctx, arr))
    end
end

@generated function release!{C, A}(dna::DNA{C, A})
    if length(methods(release!, (A, ))) > 0
        :( release!(dna.array) )
    else
        :( )
    end
end

size(dna::DNA) = dims(dna.array, 0)

zero!(dna::DNA) = dna.array[:] = 0.0f0

function randomizeUniform!(dna::DNA, strength = 1.0f0)
    scope!(dna.ctx) do this
        dna.array[] = randu(dna.ctx, Float32, size(dna)) .* strength
    end
end

function mutate!(dna::DNA, probability = 0.0f0, strength = 0.0f0, normalize = true)
    if probability <= 0.0f0 || strength <= 0.0f0
        return
    end

    scope!(dna.ctx) do this
        dnaSize = size(dna)
        values = dna.array .+ ((randu(dna.ctx, Float32, dnaSize) .* strength) - strength / 2.0f0)
        prob = randu(dna.ctx, Float32, dnaSize)
        where = prob .< probability
        dna.array[] = select(where, values, normalize ? _normalizedArray(dna.array) : dna.array)
    end
end

function crossover{C, A}(dna1::DNA{C, A}, dna2::DNA{C, A})
    dnaSize = size(dna1)
    dnaSize != size(dna2) && error("Size mismatch.")
    scope!(dna.ctx) do this
        arr = select(randu(ctx, Bool, dnaSize), dna1.array, dna2.array)
        this.result(arr)
        DNA(dna1.ctx, arr)
    end
end

function normalized(dna::DNA)
    scope!(dna.ctx) do this
        arr = _normalizedArray(dna.array)
        this.result(arr)
        DNA(dna.ctx, arr)
    end
end

function normalize!(dna::DNA)
    scope!(dna.ctx) do this
        dna.array[] = _normalizedArray(dna.array)
    end
end

Array(dna::DNA) = Array(dna.array)

copy(dna::DNA) = DNA(dna)

_normalizedArray(arr) = 1f0 .- abs(abs(abs(arr) .% 4f0 .- 2f0) .- 1f0)
