af = ArrayFire{OpenCL}()

afArr = array(af, [0.0, 0.1, 0.0, 0.3, 0.0, 0.5, 0.0, 0.7, 0.8, 0.0])
result = host(where(!afArr))
println(result)
