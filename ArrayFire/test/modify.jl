testOnAllBackends("Modify Array") do af
	println("\tmoddims")
	afArr = array(af, [[1, 2] [3, 4]])
	result = host(moddims(afArr, 4))

	@test result == [1, 2, 3, 4]

	afArr = array(af, [1, 2, 3, 4, 5, 6])
	result = host(moddims(afArr, 2, 3))

	@test result == [[1, 2] [3, 4] [5, 6]]

	afArr = array(af, [1, 2, 3, 4, 5, 6])
	@test_throws AFErrorException moddims(afArr, 2, 2)
end
