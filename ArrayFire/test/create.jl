testOnAllBackends("Create Array") do af
	println("\tconstant")
	afArr = constant(af, 1.1f0, 2, 2)
	@test host(afArr) == [[1.1f0, 1.1f0] [1.1f0, 1.1f0]]

	afArr = constant(af, one(Int64), 4)
	@test host(afArr) == [one(Int64), one(Int64), one(Int64), one(Int64)]

	afArr = constant(af, zero(UInt64), 1, 2)
	@test host(afArr) == [zero(UInt64) zero(UInt64)]

	afArr = randu(af, Float32, 1, 2)
	@test host(afArr .>= 0) == [true true]
	@test host(afArr .<= 1) == [true true]

	afArr = randn(af, Float32, 1, 2)
	@test host(afArr .>= -4.0f0) == [true true]
	@test host(afArr .<= 4.0f0) == [true true]
end
