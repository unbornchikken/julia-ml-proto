export ForwardBatcher, next!, current, release!

type ForwardBatcher{C, A} <: Batcher
    ctx::C
    inputs::A
    targets::A
    size::Int
    index::Int
    inputSeg::A
    targetSeg::A
end

function ForwardBatcher(ctx, inputs, targets, size)
    @assert dims(inputs, 0) == dims(targets, 0)
    @assert size < dims(inputs, 0)
    @assert dims(inputs, 0) % size == 0
    A = typeof(inputs)
    ForwardBatcher(ctx, inputs, targets, size, 0, array(ctx), array(ctx))
end

function release!(br::ForwardBatcher)
    release(br.inputSeg)
    release(br.targetSeg)
end

function next!(br::ForwardBatcher)
    scope!(br.ctx) do this
        startPos = br.index * br.size
        endPos = startPos + br.size - 1

        br.inputSeg[] = br.inputs[seq(br.ctx, startPos, endPos), :]
        br.targetSeg[] = br.targets[seq(br.ctx, startPos, endPos), :]

        if endPos == dims(br.inputs, 0) - 1
            br.index = 0
        else
            br.index += 1
        end
    end
end

current(br::ForwardBatcher) = (isEmpty(br.inputSeg) && error("Bacher is not initialized."); (br.inputSeg, br.targetSeg))
