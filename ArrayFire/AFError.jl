type AFErrorException <: Exception
	code
end

Base.showerror(io::IO, e::AFErrorException) =
	print(io, "AF Error Code: ", e.code);

assertErr(err) = (err != 0) && throw(AFErrorException(err))
