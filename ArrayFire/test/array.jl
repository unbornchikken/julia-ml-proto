testOnAllBackends("AFArray") do af
    println("\tconstruct")

    arr = [1.0f0, 2.0f0]
    afArr = array(af, arr)
    @test [2, 1, 1, 1] == dims(afArr)
    @test (2,) == size(afArr)
    @test host(afArr) == arr
    @test dType(afArr) == f32
    @test numdims(afArr) == length(size(afArr))

    arr = [1.0f0 2.0f0]
    afArr = array(af, arr)
    @test [1, 2, 1, 1] == dims(afArr)
    @test (1,2) == size(afArr)
    @test host(afArr) == arr
    @test dType(afArr) == f32
    @test numdims(afArr) == length(size(afArr))

    afArr = array(af, Float32, 3)
    @test [3, 1, 1, 1] == dims(afArr)
    @test (3,) == size(afArr)
    arr = host(afArr)
    @test typeof(arr) == Array{Float32, 1}
    @test (3,) == size(arr)
    @test dType(afArr) == f32
    @test numdims(afArr) == length(size(afArr))

    afArr = array(af, Float32, 1, 3)
    @test [1, 3, 1, 1] == dims(afArr)
    @test (1, 3) == size(afArr)
    arr = host(afArr)
    @test typeof(arr) == Array{Float32, 2}
    @test (1, 3) == size(arr)
    @test dType(afArr) == f32
    @test numdims(afArr) == length(size(afArr))

    arr = [1.0f0, 2.0f0]
    afArr = array(af, arr, 1, 2)
    @test [1, 2, 1, 1] == dims(afArr)
    @test (1, 2) == size(afArr)
    @test host(afArr) == [1.0f0 2.0f0]
    @test dType(afArr) == f32
    @test numdims(afArr) == length(size(afArr))

    arr = [one(Int32) zero(Int32)]
    afArr = array(af, arr, 2)
    @test [2, 1, 1, 1] == dims(afArr)
    @test (2, ) == size(afArr)
    @test host(afArr) == [one(Int32), zero(Int32)]
    @test dType(afArr) == s32
    @test numdims(afArr) == length(size(afArr))

    println("\tindex get")
    idx = AF.ArrayIndex(afArr)
    aPtr = AF.ptr(idx)
    @test aPtr == afArr.ptr
    afArr = AF.AFArray{getBackend(af)}(af, aPtr, false)
    @test [2, 1, 1, 1] == dims(afArr)
    @test (2, ) == size(afArr)
    @test host(afArr) == [one(Int32), zero(Int32)]
    @test dType(afArr) == s32
    @test numdims(afArr) == length(size(afArr))

    afArr = array(af, [1, 2, 3, 4, 5])
    indexed = afArr[seq(af, 1)]
    @test host(indexed) == [2]
    indexed = afArr[3]
    @test host(indexed) == [3]
    indexed = afArr[2:4]
    @test host(indexed) == [2, 3, 4]

    afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
    indexed = afArr[3:5]
    @test host(indexed) == [3, 4, 5]
    indexed = afArr[1:3, 2:3]
    @test host(indexed) == [[5, 6, 7] [9, 10, 11]]
    indexed = afArr[-1, 3:4]
    @test host(indexed) == [12 16]
    # span
    indexed = afArr[span(af)]
    @test host(indexed) == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
    indexed = afArr[2,:]
    @test host(indexed) == [2 6 10 14]

    afArr = array(af, [1, 2, 3, 4, 5])
    afIdx = array(af, [1.0f0, 0.0f0, 2.0f0])
    indexed = afArr[afIdx]
    @test host(indexed) == [2, 1, 3]

    afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
    afIdx = array(af, [[1.0f0, 0.0f0, 2.0f0] [5.0f0, 10.0f0, 2.0f0]])
    indexed = afArr[afIdx]
    @test host(indexed) == [2,1,3,6,11,3]

    # Col, Row
    afArr = array(af, [[0,1,2] [3,4,5] [6,7,8]])

    @test host(afArr[row(af, 0)]) == [0 3 6]
    @test host(afArr[row(af, 2)]) == [2 5 8]

    @test host(afArr[rows(af, 0, 1)]) == [[0,1] [3,4] [6,7]]

    @test host(afArr[col(af, 0)]) == [0,1,2]
    @test host(afArr[col(af, 2)]) == [6,7,8]

    @test host(afArr[cols(af, 1,2)]) == [[3,4,5] [6,7,8]]

    println("\tindex assign")
    afArr = array(af, [1,2,3,4])
    afArr[:] = 5
    @test host(afArr) == [5,5,5,5]

    afArr = array(af, [1,2,3,4])
    afArr[2:3] = 5.5f0
    @test host(afArr) == [1,5,5,4]

    afArr = array(af, [1,2,3,4])
    afArr[1:2] = array(af, [10.1f0, 11.1f0])
    @test host(afArr) == [10,11,3,4]

    @test_throws AFErrorException afArr[1:2] = array(af, [10.1f0, 11.1f0, 12.2f0])

    afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
    afArr[:, 3:4] = array(af, [[1,2,3,4] [5,6,7,8]])
    @test host(afArr) == [[1,2,3,4] [5,6,7,8] [1,2,3,4] [5,6,7,8]]

    afArr[3:4, :] = 1.1f0
    @test host(afArr) == [[1,2,1,1] [5,6,1,1] [1,2,1,1] [5,6,1,1]]

    afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
    afArr[array(af, [10, 11, 12, 13, 14, 15])] = array(af, [55, 66, 77, 88, 99, 100])
    @test host(afArr) == [[1,2,3,4] [5,6,7,8] [9,10,55,66] [77, 88, 99, 100]]
    afArr[array(af, [[1, 2, 3] [4, 5, 6]])] = array(af, [55, 66, 77, 88, 99, 100])
    @test host(afArr) == [[1,55,66,77] [88,99,100,8] [9,10,55,66] [77, 88, 99, 100]]

    @test_throws AFErrorException afArr[array(af, [[1, 2, 3] [4, 5, 6]])] = array(af, [[55, 66, 77] [88, 99, 100]])

    afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
    afArr[array(af, [[1, 2, 3] [4, 5, 6]])] = -1
    @test host(afArr) == [[1,-1,-1,-1] [-1,-1,-1,8] [9,10,11,12] [13, 14, 15, 16]]

    println("\tCOW")
    arr1 = array(af, [1, 2, 3])
    arr2 = arr1[]

    @test host(arr1) == [1, 2, 3]
    @test host(arr2) == [1, 2, 3]

    arr1[1] = 5

    @test host(arr1) == [5, 2, 3]
    @test host(arr2) == [1, 2, 3]

    println("\tempty")
    arr1[] = array(af)

    @test dType(arr1) == 0
    @test dims(arr1) == [0, 0, 0, 0]
    @test size(arr1) == ()
    @test isEmpty(arr1)
    @test host(arr2) == [1, 2, 3]
    @test_throws ErrorException host(arr1)
end
