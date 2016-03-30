af = ArrayFire{OpenCL}()

arr1 = array(af, [1, 2, 3])
arr2 = arr1[]

println(host(arr1))
println(host(arr2))

arr1[1] = 5

println(host(arr1))
println(host(arr2))

arr1[] = array(af)

println(dType(arr1))
println(dims(arr1))
println(size(arr1))
println(host(arr2))
