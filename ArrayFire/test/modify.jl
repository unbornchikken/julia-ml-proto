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

	println("\tjoinArrays")
	afArr1 = array(af, [[1.0f0, 2.0f0] [4.0f0, 3.0f0]])
	afArr2 = array(af, [[5.0f0, 1.0f0] [1.0f0, 5.0f0]])

	@test host(joinArrays(0, afArr1, afArr2)) ==
		Float32[[1.0, 2.0, 5.0, 1.0] [4.0, 3.0, 1.0, 5.0]]
	@test host(joinArrays(1, afArr1, afArr2)) ==
		Float32[[1.0, 2.0] [4.0, 3.0] [5.0, 1.0] [1.0, 5.0]]

	afArr3 = array(af, [[9.0f0, 9.0f0] [9.0f0, 9.0f0]])

	@test host(joinArrays(0, afArr1, afArr2, afArr3)) ==
		Float32[[1.0, 2.0, 5.0, 1.0, 9.0, 9.0] [4.0, 3.0, 1.0, 5.0, 9.0, 9.0]]
end
