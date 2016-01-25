#CircuitAnalysis: Circuit math
#-------------------------------------------------------------------------------

#==NOTE:
Generic functions are not specialized. They will therefore not be efficient
for DataMD structures.==#


#==Generic functions
===============================================================================#
dB20(x) = 10*log10(abs2(x))
dB10(x) = 10*log10(x) #Power should neither be negative, nor complex

#By definition, P = VRMS²/R & P = IRMS²×R
#For V(t) = Vpk*sin(ωt+ϕ) => P = ∫(V²(t)/R/T)dt = Vpk²/R/2 => VRMS = √(P×R) = Vpk/√2
#Similarly, P = Ipk²×R/2 & IRMS = Ipk/√2
Vpk(V, ::DS{:VRMS}) = V*sqrt(2)
Vpk(P, ::DS{:W}; R=1) = sqrt(P*(2*R))
Vpk{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(Vpk, [T], v, T, args...; kwargs...))
Vpk(v, u::Symbol; kwargs...) = Vpk(v, DS(u); kwargs...)

Ipk(I, ::DS{:IRMS}) = I*sqrt(2)
Ipk(P, ::DS{:W}; R=1) = sqrt(P*(2/R))
Ipk{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(Ipk, [T], v, T, args...; kwargs...))
Ipk(v, u::Symbol; kwargs...) = Ipk(v, DS(u); kwargs...)

VRMS(V, ::DS{:Vpk}) = V/sqrt(2)
VRMS(P, ::DS{:W}; R=1) = sqrt(P*R)
VRMS{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(VRMS, [T], v, T, args...; kwargs...))
VRMS(v, u::Symbol; kwargs...) = VRMS(v, DS(u); kwargs...)

IRMS(I, ::DS{:Ipk}) = I/sqrt(2)
IRMS(P, ::DS{:W}; R=1) = sqrt(P/R)
IRMS{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(IRMS, [T], v, T, args...; kwargs...))
IRMS(v, u::Symbol; kwargs...) = IRMS(v, DS(u); kwargs...)

dB(P, ::DS{:Wratio}) = dB10(P)
dB(V, ::DS{:Vratio}) = dB20(V)
dB(I, ::DS{:Iratio}) = dB20(I)
dB{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(dB, [T], v, T, args...; kwargs...))
dB(v, u::Symbol; kwargs...) = dB(v, DS(u); kwargs...)

dBm(P, ::DS{:W}) = dB10(P) - dB10(1e-3)
dBm(V, ::DS{:VRMS}; R=1) = dB10(abs2(V)/R) - dB10(1e-3)
dBm(V, ::DS{:Vpk}; R=1) = dB10(abs2(VRMS(V, :Vpk))/R) - dB10(1e-3)
dBm{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(dBm, [T], v, T, args...; kwargs...))
dBm(v, u::Symbol; kwargs...) = dBm(v, DS(u); kwargs...)

dBW(P, ::DS{:W}) = dB10(P) - dB10(1)
dBW(V, ::DS{:VRMS}; R=1) = dB10(abs2(V)/R) - dB10(1)
dBW(V, ::DS{:Vpk}; R=1) = dB10(abs2(VRMS(V, :Vpk))/R) - dB10(1)
dBW{T}(v, ::DS{T}, args...; kwargs...) = throw(nosupport(dBW, [T], v, T, args...; kwargs...))
dBW(v, u::Symbol; kwargs...) = dBW(v, DS(u); kwargs...)

#Last line
