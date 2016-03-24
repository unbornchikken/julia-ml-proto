af = ArrayFire{OpenCL}()

afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
print(code_typed(getindex, (AFArrayWithData{Float32, 1}, Int, AFArrayWithData{Float32, 1}, Colon)))

# afArr = array(af, [[1,2,3,4] [5,6,7,8] [9,10,11,12] [13, 14, 15, 16]])
# indexed = AF.index(afArr, AF.SeqIndex(2, 4))
# print(host(indexed))
#
# indexed = AF.index(afArr, AF.SeqIndex(0, 2), AF.SeqIndex(1, 2))
# print(host(indexed))
#
# indexed = AF.index(afArr, AF.SeqIndex(-1), AF.SeqIndex(2, 3))
# print(host(indexed))
