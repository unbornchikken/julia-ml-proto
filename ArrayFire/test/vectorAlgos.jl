testOnAllBackends("Vector Algos") do af
	println("\twhere")
	afArr = array(af, [0.0, 0.1, 0.0, 0.3, 0.0, 0.5, 0.0, 0.7, 0.8, 0.0])
	result = where(afArr)
	@test host(result) == [0x00000001,0x00000003,0x00000005,0x00000007,0x00000008]
end
