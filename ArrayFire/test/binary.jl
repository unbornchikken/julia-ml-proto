testOnAllBackends("Binary Operators") do af
	println("arithmetic")
	afArr = array(af, [[1, 2] [3, 4]])

	println("./")
	result = afArr ./ 2
	@test host(result) == [[0, 1] [1, 2]]

	println(".+=")
	result .+= 1
	@test host(result) == [[1, 2] [2, 3]]

	println(".*=")
	result .*= 2
	@test host(result) == [[2, 4] [4, 6]]

	println(".-=")
	result .-= 1.5f0
	@test host(result) == [[0.5f0, 2.5f0] [2.5f0, 4.5f0]]

	println(".\=")
	result .\= 2.0
	@test host(result) == [[4.0, 0.8] [0.8, 0.4444444444444444]]

	afArr = array(af, [[1, 2] [3, 4]])

	println("./")
	result = afArr ./ array(af, [[2, 2] [2, 2]])
	@test host(result) == [[0, 1] [1, 2]]

	println(".+=")
	result .+= array(af, [[1, 1] [1, 1]])
	@test host(result) == [[1, 2] [2, 3]]

	println(".*=")
	result .*= array(af, [[2, 2] [2, 2]])
	@test host(result) == [[2, 4] [4, 6]]

	println(".-=")
	result .-= array(af, [[1.5f0, 1.5f0] [1.5f0, 1.5f0]])
	@test host(result) == [[0.5f0, 2.5f0] [2.5f0, 4.5f0]]

	println(".\=")
	result .\= array(af, [[2.0, 2.0] [2.0, 2.0]])
	@test host(result) == [[4.0, 0.8] [0.8, 0.4444444444444444]]

	println("logic")
	afArr = array(af, [[1, 2] [3, 4]])

	println(".<")
	result = afArr .< array(af, [[2, 2] [2, 2]])
	@test host(result) == [[true, false] [false, false]]

	println(".<=")
	result = afArr .<= array(af, [[2, 2] [2, 2]])
	@test host(result) == [[true, true] [false, false]]

	println("==")
	result = afArr == array(af, [[2, 2] [2, 2]])
	@test host(result) == [[false, true] [false, false]]

	println("!=")
	result = afArr != array(af, [[2, 2] [2, 2]])
	@test host(result) == [[true, false] [true, true]]

	println(".>")
	result = afArr .> array(af, [[2, 2] [2, 2]])
	@test host(result) == [[false, false] [true, true]]

	println(".>=")
	result = afArr .>= 2
	@test host(result) == [[false, true] [true, true]]

	afArr = array(af, [[0, 1] [2, 0]])

	println("and")
	result = and(afArr, array(af, [[true, false] [true, false]]))
	@test host(result) == [[false, false] [true, false]]

	println("or")
	result = or(afArr, array(af, [[true, false] [true, false]]))
	@test host(result) == [[true, true] [true, false]]
end
