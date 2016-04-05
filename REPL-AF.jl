af = ArrayFire{OpenCL}()

afArr1 = array(af, [[1.0f0, 2.0f0] [4.0f0, 3.0f0]])
afArr2 = array(af, [[5.0f0, 1.0f0] [1.0f0, 5.0f0]])

println(host(joinArrays(0, afArr1, afArr2)))
println(host(joinArrays(1, afArr1, afArr2)))

afArr3 = array(af, [[9.0f0, 9.0f0] [9.0f0, 9.0f0]])

println(host(joinArrays(0, afArr1, afArr2, afArr3)))
