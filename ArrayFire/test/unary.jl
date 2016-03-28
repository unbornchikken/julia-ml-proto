testOnAllBackends("Unary Operators") do af
	println("\tlogical")
	println("\t!")
	afArr = array(af, [0.0, 0.1, 0.0, 0.3, 0.0, 0.5, 0.0, 0.7, 0.8, 0.0])
	result = host(where(!afArr))
	@test result == [0x00000000,0x00000002,0x00000004,0x00000006,0x00000009]
end
