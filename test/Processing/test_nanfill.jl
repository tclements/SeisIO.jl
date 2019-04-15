S = randSeisData()
L = length(S.x[1])
C = deepcopy(S[1])
Ev = SeisEvent(hdr=randSeisHdr(), data=deepcopy(S))

inds = rand(1:L, div(L,2))
S.x[1][inds] .= NaN

inds = rand(1:L, div(L,2))
Ev.data.x[1][inds] .= NaN

inds = rand(1:L, div(L,2))
C.x[inds] .= NaN

nanfill!(Ev)
nanfill!(S)
nanfill!(C)

ungap!(Ev, tap=true)
ungap!(C, tap=true)
ungap!(S, tap=true)

demean!(C)
detrend!(C)
demean!(Ev)
detrend!(Ev)