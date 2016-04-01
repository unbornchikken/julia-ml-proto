af = ArrayFire{OpenCL}()

afArr = array(af, [[1, 2] [3, 4]])
result = host(moddims(afArr, 4))

println(result)

afArr = array(af, [1, 2, 3, 4, 5, 6])
result = host(moddims(afArr, 2, 3))

println(result)

afArr = array(af, [1, 2, 3, 4, 5, 6])
result = host(moddims(afArr, 2, 2))

println(result)
