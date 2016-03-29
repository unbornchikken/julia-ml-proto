af = ArrayFire{OpenCL}()

@scope af begin
	afArr = array(af, [[1, 2] [3, 4]])
	result = lookup(afArr, array(af, [1]), 0)
	println(host(result))
	result = lookup(afArr, array(af, [0]), 1)
	println(host(result))
	this.result(afArr)
	println("OK")
end
