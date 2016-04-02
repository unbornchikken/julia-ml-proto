af = ArrayFire{OpenCL}()

@scope af begin
	afArr = array(af, [[1, 2] [3, 4]])
	result = host(transpose(afArr))

	println(result)

	afArr = array(af, [1, 2, 3, 4])
	result = host(transpose(afArr))

	println(result)

	afArr = array(af, [[1, 2] [3, 4]])
	transpose!(afArr)

	println(host(afArr))
end
