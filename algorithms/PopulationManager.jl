export
    PopulationManager,
    createEmpty,
    randomize!,
    chooseParentIndex

immutable PopulationManager
    population::Population
    populationSize::Int
    dnaSize::Int
    best::BestEntity
end

PopulationManager(ctx, populationSize::Int, dnaSize::Int, comparer::Comparer, decode::Function) =
    PopulationManager(Population(ctx, comparer, decode), populationSize, dnaSize)

createEmpty(popMan::PopulationManager) =
    Population(popMan.population.ctx, popMan.population.comparer, popMan.population.decode)

function randomize!(popMan::PopulationManager)
    first = randomize!(popMan.population, popMan.populationSize, popMan.dnaSize)
    set!(popMan.best, first)
end

chooseParentIndex(popMan::PopulationManager, stdDev::Float64) =
    chooseParentIndex(popMan, stdDev, length(popMan.population))

function chooseParentIndex(stdDev::Float64, size::Int)
    v = abs(randn() * stdDev)
    v = v - floor(v)
    Int(round(v * size))
end

# keepElites(newPop) {
#     let keep = this.options.keepElitesRate < 1 ? Math.round(this.population.length * this.options.keepElitesRate) : this.options.keepElitesRate;
#     debug("Keeping %d elites from the previous population.", keep);
#     for (let i = 0; i < keep; i++) {
#         newPop.pushEntity(this.population.at(i).clone());
#     }
# }
#
# *registerNewPopulationAsync(newPop, noSort) {
#     if (!noSort) {
#         yield this.updateBestAsync(yield newPop.sortAsync());
#     }
#     else {
#         let best = null;
#         for (let entity of newPop.entities) {
#             if (best === null || (yield this.comparer.compareAsync(entity.body, best.body)) < 0) {
#                 best = entity;
#             }
#         }
#         yield this.updateBestAsync(best);
#     }
#     this.population.free();
#     this.population = newPop;
# }
