af = ArrayFire(OpenCL)
@show infoString(af)
getDeviceCount(af)
@show getDevice(af)
setDevice(af, 1)
@show deviceInfos(af)
@show deviceInfo(af)

arr1 = array(af)
@show arr1

arr2 = array(af, Float32, 4, 5)
@show arr2

arr3 = array(af, [1.1 2.2 3.3 4.4])
@show arr3
