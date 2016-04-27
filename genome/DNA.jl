import Base: copy, length, Array

export
    DNA,
    copy,
    length,
    Array,
    release!,
    zero!,
    mutate!,
    crossover,
    normalize!,
    normalized,
    randomizeUniform!

type DNA{C, A}
    ctx::C
    array::A
end

function DNA{C}(ctx::C, size::Int)
    arr = constant(ctx, 0f0, size)
    DNA{C, typeof(arr)}(ctx, arr)
end

function DNA{C, A}(ctx::C, arr::A)
    DNA{C, A}(ctx, copy(arr))
end

function DNA{C, A}(other::DNA{C, A})
    DNA{C, A}(other.ctx, copy(other.array))
end

function DNA{C}(ctx::C, vec::Vector{Float32})
    arr = array(ctx, vec)
    DNA{C, typeof(arr)}(ctx, arr)
end

@generated function release!{C, A}(dna::DNA{C, A})
    if length(methods(release!, (A, ))) > 0
        :( release!(dna.array) )
    else
        :( )
    end
end

length(dna::DNA) = dims(dna.array, 0)

zero!(dna::DNA) = dna.array[:] = 0f0

function randomizeUniform!(dna::DNA, strength = 1f0)
    scope!(dna.ctx) do this
        dna.array[] = randu(dna.ctx, Float32, length(dna)) .* strength
    end
end

function mutate!(dna::DNA, probability = 0f0, strength = 0f0, normalize = true)
    if probability <= 0f0 || strength <= 0f0
        return
    end

    scope!(dna.ctx) do this
        dnaLength = length(dna)
        values = dna.array .+ ((randu(dna.ctx, Float32, dnaLength) .* strength) .- strength / 2f0)
        prob = randu(dna.ctx, Float32, dnaLength)
        where = prob .< probability
        dna.array[] = select(where, values, normalize ? _normalizedArray(dna.array) : dna.array)
    end
end

function crossover{C, A}(dna1::DNA{C, A}, dna2::DNA{C, A})
    dnaLength = length(dna1)
    dnaLength != length(dna2) && error("Size mismatch.")
    ctx = dna1.ctx
    scope!(ctx) do this
        dna = DNA(ctx, select(randu(ctx, Bool, dnaLength), dna1.array, dna2.array))
        this.result(dna.array)
        dna
    end
end

function normalized(dna::DNA)
    scope!(dna.ctx) do this
        dna = DNA(dna.ctx, _normalizedArray(dna.array))
        this.result(dna.array)
        dna
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
