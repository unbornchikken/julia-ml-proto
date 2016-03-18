af = ArrayFire{OpenCL}()

arr1 = array(af, [1.0f0, 2.0f0, 3.0f0])
arr2 = array(af, [2.0f0, 2.0f0, 2.0f0])

result = arr1 .< arr2
host(result)
