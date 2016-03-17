af = ArrayFire{OpenCL}()
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

arr3 = array(af, [1.1f0 2.2f0 3.3f0 4.4f0])
@show arr3
release!(arr3)

begin
	global arr4
	global arr5
	scope!(af) do s
	  global arr4 = array(af)
	  global arr5 = array(af, [1, 2, 3])
	  s.result(arr5)
	end
	print(release!(arr4))
	print(release!(arr5))
end

arr6 = array(af, [1.1f0 2.2f0 3.3f0 4.4f0], 2, 2)
