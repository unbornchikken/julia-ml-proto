af = ArrayFire{OpenCL}()

afArr = array(af, [[1.0f0, 2.0f0] [4.0f0, 3.0f0]])

println(host(max(afArr)))
println(host(max(afArr, 0)))
println(host(max(afArr, 1)))
println(host(max(afArr, 2)))

println(minAll(afArr))

result = imax(afArr, 0)
println(string(host(result[1]), "\t", host(result[2])))

result = imaxAll(afArr)
println(result)

afArr = array(af, [1 2 3 4 5])

println(host(min(afArr)))
println(host(min(afArr, 1)))
