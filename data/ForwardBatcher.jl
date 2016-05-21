export ForwardBatcher, next!

type ForwardBatcher{C, A} <: Batcher
    ctx::C
    inputs::A
    targets::A
    size::Int
    index::Int

    ForwardBatcher(ctx, inputs, targets, size) =
        new(ctx, inputs, targets, size, 0)
end

function ForwardBatcher(ctx, inputs, targets, size)
    @assert dims(inputs, 1) == dims(targets, 1)
    @assert size < dims(inputs, 1)
    @assert dims(inputs, 1) % size == 0
    ForwardBatcher(ctx, inputs, targets)
end

function next!(br::ForwardBatcher)
    startPos = br.index * br.size
    endPos = startPos + br.size - 1

    inputResult = br.inputs[seq(af, startPos, endPos), :]
    targetResult = br.targets[seq(af, startPos, endPos), :]

    br.index += 1
    br.index == br.size && br.index = 0

    inputResult, targetResult
end
