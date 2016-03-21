begin
	af = ArrayFire{CPU}()

	# construct
	empty = array(af)
	@test [0, 0, 0, 0] == dims(empty)
	@test () == size(empty)
	@test_throws MethodError host(empty)

	arr = [1.0f0, 2.0f0]
	afArr = array(af, arr)
	@test [2, 1, 1, 1] == dims(afArr)
	@test (2,) == size(afArr)
	@test host(afArr) == arr

	arr = [1.0f0 2.0f0]
	afArr = array(af, arr)
	@test [1, 2, 1, 1] == dims(afArr)
	@test (1,2) == size(afArr)
	@test host(afArr) == arr

	afArr = array(af, Float32, 3)
	@test [3, 1, 1, 1] == dims(afArr)
	@test (3,) == size(afArr)
	arr = host(afArr)
	@test typeof(arr) == Array{Float32, 1}
	@test (3,) == size(arr)

	afArr = array(af, Float32, 1, 3)
	@test [1, 3, 1, 1] == dims(afArr)
	@test (1, 3) == size(afArr)
	arr = host(afArr)
	@test typeof(arr) == Array{Float32, 2}
	@test (1, 3) == size(arr)

	arr = [1.0f0, 2.0f0]
	afArr = array(af, arr, 1, 2)
	@test [1, 2, 1, 1] == dims(afArr)
	@test (1, 2) == size(afArr)
	@test host(afArr) == [1.0f0 2.0f0]

	arr = [1.0f0 2.0f0]
	afArr = array(af, arr, 2)
	@test [2, 1, 1, 1] == dims(afArr)
	@test (2, ) == size(afArr)
	@test host(afArr) == [1.0f0, 2.0f0]
end
