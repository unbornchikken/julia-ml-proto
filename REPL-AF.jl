af = ArrayFire{OpenCL}()

arr1 = array(af, [1.1, 2.2, 3.2])
arr2 = array(af, [1, 0.1, 4])

result = arr1 ./ arr2
host(result)

result = arr2 .\ arr1
host(result)
