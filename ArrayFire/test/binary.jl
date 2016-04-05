testOnAllBackends("Binary Operators") do af
	println("\tarithmetic")
	afArr = array(af, [[1, 2] [3, 4]])

	println("\t./")
	result = afArr ./ 2
	@test host(result) == [[0, 1] [1, 2]]

	println("\t.+=")
	result .+= 1
	@test host(result) == [[1, 2] [2, 3]]

	println("\t.*=")
	result .*= 2
	@test host(result) == [[2, 4] [4, 6]]

	println("\t.-=")
	result .-= 1.5f0
	@test host(result) == [[0.5f0, 2.5f0] [2.5f0, 4.5f0]]

	println("\t.\=")
	result .\= 2.0
	@test host(result) == [[4.0, 0.8] [0.8, 0.4444444444444444]]

	afArr = array(af, [[1, 2] [3, 4]])

	println("\t./")
	result = afArr ./ array(af, [[2, 2] [2, 2]])
	@test host(result) == [[0, 1] [1, 2]]

	println("\t.+=")
	result .+= array(af, [[1, 1] [1, 1]])
	@test host(result) == [[1, 2] [2, 3]]

	println("\t.*=")
	result .*= array(af, [[2, 2] [2, 2]])
	@test host(result) == [[2, 4] [4, 6]]

	println("\t.-=")
	result .-= array(af, [[1.5f0, 1.5f0] [1.5f0, 1.5f0]])
	@test host(result) == [[0.5f0, 2.5f0] [2.5f0, 4.5f0]]

	println("\t.\=")
	result .\= array(af, [[2.0, 2.0] [2.0, 2.0]])
	@test host(result) == [[4.0, 0.8] [0.8, 0.4444444444444444]]

	println("\tlogic")
	afArr = array(af, [[1, 2] [3, 4]])

	println("\t.<")
	result = afArr .< array(af, [[2, 2] [2, 2]])
	@test host(result) == [[true, false] [false, false]]

	println("\t.<=")
	result = afArr .<= array(af, [[2, 2] [2, 2]])
	@test host(result) == [[true, true] [false, false]]

	println("\t.==")
	result = afArr .== array(af, [[2, 2] [2, 2]])
	@test host(result) == [[false, true] [false, false]]

	println("\t.!=")
	result = afArr .!= array(af, [[2, 2] [2, 2]])
	@test host(result) == [[true, false] [true, true]]

	println("\t.>")
	result = afArr .> array(af, [[2, 2] [2, 2]])
	@test host(result) == [[false, false] [true, true]]

	println("\t.>=")
	result = afArr .>= 2
	@test host(result) == [[false, true] [true, true]]

	afArr = array(af, [[0, 1] [2, 0]])

	println("\tand")
	result = and(afArr, array(af, [[true, false] [true, false]]))
	@test host(result) == [[false, false] [true, false]]

	println("\tor")
	result = or(afArr, array(af, [[true, false] [true, false]]))
	@test host(result) == [[true, true] [true, false]]

	println("\tmaxOf, minOf")
	afArr1 = array(af, [[1.0f0, 2.0f0] [4.0f0, 3.0f0]])
	afArr2 = array(af, [[5.0f0, 1.0f0] [1.0f0, 5.0f0]])

	@test host(maxOf(afArr1, afArr2)) == [[5.0f0, 2.0f0] [4.0f0, 5.0f0]]
	@test host(minOf(afArr1, 2)) == [[1.0f0, 2.0f0] [2.0f0, 2.0f0]]
	@test host(maxOf(2.0, afArr2)) == [[5.0, 2.0] [2.0, 5.0]]
end
