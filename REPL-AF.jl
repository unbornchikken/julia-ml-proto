af = ArrayFire{OpenCL}()

arr1 = array(af, [true, false, true])
arr2 = array(af, [1, 0, 0])

result = and(arr1, arr2)
host(result)

result = or(arr1, arr2)
host(result)

arr1 = array(af, [1, 1, 0])

result = arr1 == arr2
host(result)

result = arr1 != arr2
host(result)
