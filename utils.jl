export cleanup!

@generated function cleanup!(f, args)
    if args<:Tuple
        quote
            try
                f(args...)
            finally
                for arg in args
                    release!(args)
                end
            end
        end
    else
        quote
            try
                f(args)
            finally
                release!(args)
            end
        end
    end
end
