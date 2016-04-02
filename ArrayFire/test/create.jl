testOnAllBackends("Create Array") do af
	println("\tconstant")
	afArr = constant(af, 1.1f0, 2, 2)
	@test host(afArr) == [[1.1f0, 1.1f0] [1.1f0, 1.1f0]]

	afArr = constant(af, one(Int64), 4)
	@test host(afArr) == [one(Int64), one(Int64), one(Int64), one(Int64)]

	afArr = constant(af, zero(UInt64), 1, 2)
	@test host(afArr) == [zero(UInt64) zero(UInt64)]

	println("\trandu")
	afArr = randu(af, Float32, 1, 2)
	@test host(afArr .>= 0) == [true true]
	@test host(afArr .<= 1) == [true true]

	println("\trandn")
	afArr = randn(af, Float32, 1, 2)
	@test host(afArr .>= -4.0f0) == [true true]
	@test host(afArr .<= 4.0f0) == [true true]

	println("\tlookup")
	afArr = array(af, [[1, 2] [3, 4]])
	result = lookup(afArr, array(af, [1]), 0)
	@test host(result) == [2 4]
	result = lookup(afArr, array(af, [0]), 1)
	@test host(result) == [1, 2]

	println("\ttranspose")
	afArr = array(af, [[1, 2] [3, 4]])
	result = host(transpose(afArr))

	@test result == [[1, 3] [2, 4]]

	afArr = array(af, [1, 2, 3, 4])
	result = host(transpose(afArr))

	@test result == [1 2 3 4]

	afArr = array(af, [[1, 2] [3, 4]])
	transpose!(afArr)

	@test host(afArr) == [[1, 3] [2, 4]]
end
