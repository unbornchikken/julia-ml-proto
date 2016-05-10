testOnAllContexts("Comparers") do ctx
    println("\tComparer")
    arr = [1,3,2]
    sorted = sort!(arr, lt = Comparer())
    @test sorted == [1,2,3]
    sorted = sort!(arr, lt = Comparer((x,y) -> >(x, y)))
    @test sorted == [3,2,1]
    sorted = sort!(arr, lt = Comparer(Comparer()))
    @test sorted == [1,2,3]

    println("\tCalculateComparer")
    arr = [1,3,2,1]
    calculations = 0
    factory = x -> (calculations += 1; -x)
    sorted = sort!(arr, lt = CalculateComparer(factory))
    @test sorted == [3,2,1,1]
    sorted = sort!(arr, lt = CalculateComparer(factory, (x,y) -> >(x, y)))
    @test sorted == [1,1,2,3]
    sorted = sort!(arr, lt = CalculateComparer(factory, Comparer()))
    @test sorted == [3,2,1,1]
    @test calculations == 3 * 3

    println("\tFastComparer")
    arr = [1,2,2,1,2,1,1,1,1,2,1]
    comparisons = 0
    compare = (x,y) -> (comparisons += 1; <(x, y))
    sorted = sort!(arr, lt = Comparer(compare))
    @test sorted == [1,1,1,1,1,1,1,2,2,2,2]
    @test comparisons == 28

    fc = FastComparer(compare)

    comparisons = 0
    sorted = sort!(arr, lt = fc)
    @test sorted == [1,1,1,1,1,1,1,2,2,2,2]
    @test comparisons == 6

    comparisons = 0
    sorted = sort!(arr, lt = fc)
    @test sorted == [1,1,1,1,1,1,1,2,2,2,2]
    @test comparisons == 0

    comparisons = 0
    reset!(fc)
    sorted = sort!(arr, lt = fc)
    @test sorted == [1,1,1,1,1,1,1,2,2,2,2]
    @test comparisons == 6

    println("\tArrayComparer")
    ac = ArrayComparer()

    println("\t- throws when attempt to compare non arrays")
    @test_throws TypeError ac(1, 2)

    println("\t- compares arrays of same size")
    a1 = [1, 2, 3]
    a2 = [2, 3, 4]
    @test ac(a1, a2) == true
    @test ac(a2, a1) == false
    @test ac(a1, a1) == false
    @test ac(a2, a2) == false

    println("\t- compares arrays of different sizes")
    a1 = [1, 2, 3, 4]
    a2 = [4, 5]
    @test ac(a1, a2) == true
    @test ac(a2, a1) == false
    @test ac(a1, a1) == false
    @test ac(a2, a2) == false

    println("\t- compares same arrays")
    a1 = [1, 2, 3]
    a2 = [1, 2, 3]
    @test ac(a1, a2) == false
    @test ac(a2, a1) == false
    @test ac(a1, a1) == false
    @test ac(a2, a2) == false
end
