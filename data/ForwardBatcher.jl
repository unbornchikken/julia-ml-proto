export ForwardBatcher, next!

type ForwardBatcher{C, A} <: Batcher
    ctx::C
    inputs::A
    targets::A
    size::Int
    index::Int
end

function ForwardBatcher(ctx, inputs, targets, size)
    @assert dims(inputs, 0) == dims(targets, 0)
    @assert size < dims(inputs, 0)
    @assert dims(inputs, 0) % size == 0
    ForwardBatcher(ctx, inputs, targets, size, 0)
end

function next!(br::ForwardBatcher)
    startPos = br.index * br.size
    endPos = startPos + br.size - 1

    inputResult = br.inputs[seq(br.ctx, startPos, endPos), :]
    targetResult = br.targets[seq(br.ctx, startPos, endPos), :]

    br.index += 1
    if br.index == br.size
        br.index = 0
    end

    inputResult, targetResult
end
