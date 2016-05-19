immutable WeightDim
    rows::Int
    cols::Int
    size::Int
end

immutable WeightPos{S}
    seq::S
    dims::Tuple{DimT, DimT}
end

WeightPos{S}(seq::S, dims1, dim2) = WeightPos{S}(deq, (dim1, dim2))

immutable MLP{C, A}
    ctx::C
    numLayers::Int
    weightCount::Int
    empty::A
    weightsArray::A
    signal::Vector{A}
    weights::Vector{WeightPos}
end

function MLP{C}(ctx::C, weightDims::Vector{WeightDim})
    numLayers = length(dims) + 1
    empty = array(ctx, Float32)
    A = typeof(empty)
    weights = Vector{A}()
    signal = Vector{WeightPos}()
    weightCount = map(d -> d.size, weightDims) |> sum
    weightsArray = array(ctx, Float32, weightCount)
    wIdx = 0
    for i in 1:numLayers
        push!(signal, array(af))
        if i != numLayers
            dims = weightDims[i]
            # TODO: make Seq and co context dependent ASAP!
            push!(weights, WeightPos(Seq(wIdx, wIdx + dims.size - 1), dims.rows, dims.cols)
            wIdx += dims.size
        end
    end
end

# _addBias(input) {
#     let af = this.context.af;
#     return af.join(1, af.constant(1, input.dims(0), af.dType.f32), input);
# }
#
# makeInputVector(index) {
#     return this._addBias(this.signal[index]);
# }
#
# forwardPropagate(input) {
#     let af = this.context.af;
#     this.signal[0].set(input);
#     const end = this.numLayers - 2;
#     for (let i = 0; i <= end; i++) {
#         af.scope(() => {
#             let inVec = this.makeInputVector(i);
#             let weights = this.weights[i];
#             let currWeights = new af.AFArray(this.weightsArray.at(weights.seq), weights.dim4);
#             let value = af.matMul(inVec, currWeights);
#             if (i === end) {
#                 this.signal[i + 1].set(af.sigmoid(value));
#                 //this.signal[i + 1].set(af.sin(value.div(4)));
#             }
#             else {
#                 //this.signal[i + 1].set(af.sigmoid(value));
#                 this.signal[i + 1].set(af.sin(value.div(4)));
#                 //this.signal[i + 1].set(af.tanh(value));
#             }
#         });
#     }
# }
#
# peekPredicted(input) {
#     this.forwardPropagate(input);
#     return this.signal[this.numLayers - 1];
# }
#
# predict(input) {
#     return this.peekPredicted(input).copy();
# }
#
# setWeights(weights) {
#     let af = this.context.af;
#     if (weights instanceof af.AFArray) {
#         if (weights.dims(0) === this.weightCount && weights.dims(1) === 1) {
#             this.weightsArray.set(weights);
#         }
#         else {
#             throw new Error("Weights dimensions doesn't match.");
#         }
#     }
#     else {
#         throw new TypeError("Value of argument 'weights' must be an instance of AFArray.");
#     }
# }
#
# reset() {
#     let af = this.context.af;
#     for (let s of this.signal) {
#         s.set(this.emptyArray);
#     }
# }
