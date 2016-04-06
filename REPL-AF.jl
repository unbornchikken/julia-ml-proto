af = ArrayFire{OpenCL}()

afArr = array(af, [[1.0f0, 2.0f0] [4.0f0, 3.0f0]])

println(host(sum(afArr)))
println(host(sum(afArr, 0)))
println(host(sum(afArr, 1)))

afArr = array(af, [[1.0f0, 2.0f0] [4.0f0, NaN32]])

println(host(sum(afArr, 0, 10.0f0)))
println(host(sum(afArr, 1, 10.0f0)))
