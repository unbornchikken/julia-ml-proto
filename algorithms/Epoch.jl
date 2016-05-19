export Epoch, start!, step!, release!

type Epoch{A <: OptAlgo}
    algo::A
    itertaionNo::Int
    started::Bool
end

Epoch{A}(algo::A) = Epoch{A}(algo, 0, false)

Epoch{A}(::Type{A}, pars...) = Epoch{A}(A(pars...), 0, false)

@generated function release!{A}(epoch::Epoch{A})
    if length(methods(release!, (A, ))) > 0
        :( release!(epoch.algo) )
    else
        :( )
    end
end

function start!(epoch::Epoch)
    start!(epoch.algo)
    epoch.itertaionNo = 0
    epoch.started = true
end

function step!(epoch::Epoch)
    !epoch.started && error("Epoch is not started.")
    step!(epoch.algo)
    epoch.itertaionNo += 1
end
