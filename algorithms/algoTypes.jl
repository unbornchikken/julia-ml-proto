abstract OptAlgo{C}

abstract PopulationBasedOptAlgo{C} <: OptAlgo{C}

best(algo::PopulationBasedOptAlgo) = algo.popMan.best
