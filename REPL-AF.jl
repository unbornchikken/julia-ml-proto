af = ArrayFire{OpenCL}()

one = constant(af, 1.0f0, 4, 2)
arr = host(one)

rnd = randu(af, Bool, 1, 5)
arr = host(rnd)

gc()
