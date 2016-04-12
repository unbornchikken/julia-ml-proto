testOnAllBackends("Reduction") do af
	println("\tmax")
	afArr = array(af, [[1.0f0, 2.0f0] [4.0f0, 3.0f0]])

	@test host(max(afArr)) == Float32[2.0 4.0]
	@test host(max(afArr, 0)) == Float32[2.0 4.0]
	@test host(max(afArr, 1)) == Float32[4.0f0, 3.0f0]
	@test host(max(afArr, 2)) == [[1.0f0, 2.0f0] [4.0f0, 3.0f0]]

	println("\tminAll")
	@test minAll(Float32, afArr) == 1.0f0

	println("\timax")
	result = imax(afArr, 0)
	@test host(result[1]) == Float32[2.0 4.0]
	@test host(result[2]) == UInt32[1 0]

	println("\timaxAll")
	result = imaxAll(Float32, afArr)
	@test result == (4.0,0x00000002)

	afArr = array(af, [1 2 3 4 5])

	println("\tmin")
	@test host(min(afArr)) == [1]
	@test host(min(afArr)) == [1]
end
