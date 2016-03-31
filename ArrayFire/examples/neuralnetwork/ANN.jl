type ANN
	af::ArrayFire
	numLayers::Int
	signal::Vector{AFArray{Float32, 2}}
	weights::Vector{AFArray{Float32, 2}}

	function ANN(af, layers, range = 0.05f0)
		numLayers = length(layers)
		signal = Vector{AFArray{Float32, 2}}()
		weights = Vector{AFArray{Float32, 2}}()

		for i in 1:numLayers
			push!(signal, empty(af, Float32, 2))
			if i != numLayers
				w = randu(af, Float32, layers[i] + 1, layers[i + 1])
				push!(weights, w)
			end
		end

		new(af, numLayers, signal, weights)
	end
end

deriv(out) = out .* (1.0f0 - out)

addBias(input) = join(1, constant(af(input), 1.0f0, dims(input, 0)), input)

function calculateError(out, pred)
	diff = out - pred;
	sq = diff * diff;
	sqrt(sum(qs)) / elements(sq)
end

function forwardPropagate(ann::ANN, input)
	ann.signal[1][] = input
	for 1:(ann.numLayers - 1)
		@scope ann.af begin
			inVec = addBias(ann.signal[i])
			outVec = matmul(inVec, ann.weights[i])
			ann.signal[i + 1][] = sigmoid(outVec)
		end
	end
end

# proto.backPropagate = function (target, alpha) {
#     let self = this;
#     let af = self.af;
#     let Seq = self.af.Seq;
#
#     // Get error for output layer
#     af.scope(function() {
#         let outVec = self.signal[self.numLayers - 1];
#         let err = outVec.sub(target);
#         let m = target.dims(0);
#
#         for (let i = self.numLayers - 2; i >= 0; i--) {
#             af.scope(function() {
#                 let inVec = self.addBias(self.signal[i]);
#                 let delta = af.transpose(self.deriv(outVec).mul(err));
#
#                 // Adjust weights
#                 let grad = af.matMul(delta, inVec).mul(alpha).neg().div(m);
#                 self.weights[i].addAssign(af.transpose(grad));
#
#                 // Input to current layer is output of previous
#                 outVec = self.signal[i];
#                 err.set(self.af.matMulTT(delta, self.weights[i]));
#
#                 // Remove the error of bias and propagate backward
#                 err.set(err.at(af.span, new Seq(1, outVec.dims(1))));
#             });
#         }
#     });
# };
#
# proto.predict = function (input) {
#     this.forwardPropagate(input);
#     return this.signal[this.numLayers - 1].copy();
# };
#
# proto.train = function(input, target, options) {
#     let self = this;
#     let af = self.af;
#     let Seq = self.af.Seq;
#
#     let numSamples = input.dims(0);
#     let numBatches = numSamples / options.batchSize;
#
#     let err = 0;
#
#     for (let i = 0; i < options.maxEpochs; i++) {
#         const start = now();
#         for (let j = 0; j < numBatches - 1; j++) {
#             af.scope(() => {
#                 let startPos = j * options.batchSize;
#                 let endPos = startPos + options.batchSize - 1;
#
#                 let x = input.at(new Seq(startPos, endPos), af.span);
#                 let y = target.at(new Seq(startPos, endPos), af.span);
#
#                 self.forwardPropagate(x);
#                 self.backPropagate(y, options.alpha);
#             });
#         }
#
#         af.scope(() => {
#             // Validate with last batch
#             let startPos = (numBatches - 1) * options.batchSize;
#             let endPos = numSamples - 1;
#             let outVec = self.predict(input.at(new Seq(startPos, endPos), af.span));
#             err = self._calculateError(outVec, target.at(new Seq(startPos, endPos), af.span));
#         });
#
#         const end = now();
#         console.log(`Epoch: ${i + 1}, Error: ${err.toFixed(6)}, Duration: ${((end - start) / 1000).toFixed(4)} seconds`);
#
#         // Check if convergence criteria has been met
#         if (err < options.maxError) {
#             console.log(`Converged on Epoch: ${i + 1}`);
#             break;
#         }
#     }
#
#     return err;
# };
