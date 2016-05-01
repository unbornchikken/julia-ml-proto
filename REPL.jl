af = ArrayFire{CPU}()

println("\trange")
afArr = range(af, Float32, [5])
println(host(afArr)) # [0.0f0,1.0f0,2.0f0,3.0f0,4.0f0]

afArr = range(af, Float32, [3, 3])
println(host(afArr)) # [[0.0f0, 1.0f0, 2.0f0] [0.0f0, 1.0f0, 2.0f0] [0.0f0, 1.0f0, 2.0f0]]

afArr = range(af, Float32, [3, 3], 1)
println(host(afArr)) # [[0.0f0, 0.0f0, 0.0f0] [1.0f0, 1.0f0, 1.0f0] [2.0f0, 2.0f0, 2.0f0]]
