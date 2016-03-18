export infoString
export getDeviceCount
export setDevice
export getDevice
export deviceInfo
export deviceInfos

immutable AFDevice
	infoString
	getDeviceCount
	setDevice
	getDevice
	deviceInfo

	function AFDevice(ptr)
		new(
			try
				Libdl.dlsym(ptr, :af_info_string)
			catch
				C_NULL
			end,
			Libdl.dlsym(ptr, :af_get_device_count),
			Libdl.dlsym(ptr, :af_set_device),
			Libdl.dlsym(ptr, :af_get_device),
			Libdl.dlsym(ptr, :af_device_info)
		)
	end
end

function infoString(af::ArrayFire)
	if (af.device.infoString != C_NULL)
		result = Ref{Ptr{Cchar}}()
		ccall(af.device.infoString, Cint, (Ptr{Ptr{Cchar}}, Cuchar), result, false)
		bytestring(result[])
	else
		info = deviceInfo(af)
		convert(AbstractString, info)
	end
end

function getDeviceCount(af::ArrayFire)
	count = Ref{Cint}(0)
	err = ccall(af.device.getDeviceCount, Cint, (Ref{Cint},), count)
	assertErr(err)
	count[]
end

function setDevice(af::ArrayFire, device)
	err = ccall(af.device.setDevice, Cint, (Cint,), device)
	assertErr(err)
end

function getDevice(af::ArrayFire)
	device = Ref{Cint}(0)
	err = ccall(af.device.getDevice, Cint, (Ref{Cint},), device)
	assertErr(err)
	device[]
end

function deviceInfo(af::ArrayFire)
	name = Array(Cchar, 256)
	platform = Array(Cchar, 256)
	toolkit = Array(Cchar, 256)
	compute = Array(Cchar, 256)
	err = ccall(
		af.device.deviceInfo,
		Cint,
		(Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}),
		name, platform, toolkit, compute)
	assertErr(err)
	DeviceInfo(
		getDevice(af),
		bytestring(pointer(name)),
		bytestring(pointer(platform)),
		bytestring(pointer(toolkit)),
		bytestring(pointer(compute)))
end

function deviceInfos(af::ArrayFire)
	curr = getDevice(af)
	count = getDeviceCount(af)
	result = Array(DeviceInfo, count)
	try
		for id = 0:(count - 1)
			setDevice(af, id)
			result[id + 1] = deviceInfo(af)
		end
	finally
		setDevice(af, curr)
	end
	result
end
