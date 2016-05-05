export Epoch, start, step

type Epoch{A}
    algo::A
    itertaionNo::Int
    started::Bool
end

Epoch{A}(algo::A) = Epoch{A}(algo, 0, false)

Epoch{A}(::Type{A}, pars...) = Epoch{A}(A(pars...), 0, false)

function start(epoch::Epoch)
    iniialize!(epoch.algo)
    epoch.itertaionNo = 0
    epoch.started = true
end

function step(epoch::Epoch)
    !epoch.started && error("Epoch is not started.")
    step!(epoch.algo)
    epoch.itertaionNo += 1
end
