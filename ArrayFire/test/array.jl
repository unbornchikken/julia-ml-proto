testOnAllBackends("AFArray", d ->
begin
	af = ArrayFire{d}()

	# construct
	empty = array(af)
	@test [0, 0, 0, 0] == dims(empty)
	@test () == size(empty)
	@test_throws MethodError host(empty)
	@test aftype(empty) == f32
	@test numdims(empty) == length(size(empty))

	arr = [1.0f0, 2.0f0]
	afArr = array(af, arr)
	@test [2, 1, 1, 1] == dims(afArr)
	@test (2,) == size(afArr)
	@test host(afArr) == arr
	@test aftype(afArr) == f32
	@test numdims(afArr) == length(size(afArr))

	arr = [1.0f0 2.0f0]
	afArr = array(af, arr)
	@test [1, 2, 1, 1] == dims(afArr)
	@test (1,2) == size(afArr)
	@test host(afArr) == arr
	@test aftype(afArr) == f32
	@test numdims(afArr) == length(size(afArr))

	afArr = array(af, Float32, 3)
	@test [3, 1, 1, 1] == dims(afArr)
	@test (3,) == size(afArr)
	arr = host(afArr)
	@test typeof(arr) == Array{Float32, 1}
	@test (3,) == size(arr)
	@test aftype(afArr) == f32
	@test numdims(afArr) == length(size(afArr))

	afArr = array(af, Float32, 1, 3)
	@test [1, 3, 1, 1] == dims(afArr)
	@test (1, 3) == size(afArr)
	arr = host(afArr)
	@test typeof(arr) == Array{Float32, 2}
	@test (1, 3) == size(arr)
	@test aftype(afArr) == f32
	@test numdims(afArr) == length(size(afArr))

	arr = [1.0f0, 2.0f0]
	afArr = array(af, arr, 1, 2)
	@test [1, 2, 1, 1] == dims(afArr)
	@test (1, 2) == size(afArr)
	@test host(afArr) == [1.0f0 2.0f0]
	@test aftype(afArr) == f32
	@test numdims(afArr) == length(size(afArr))

	arr = [one(Int32) zero(Int32)]
	afArr = array(af, arr, 2)
	@test [2, 1, 1, 1] == dims(afArr)
	@test (2, ) == size(afArr)
	@test host(afArr) == [one(Int32), zero(Int32)]
	@test aftype(afArr) == s32
	@test numdims(afArr) == length(size(afArr))
end)
