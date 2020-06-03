#Jesli to czytasz zanczy ze wsztyko działa

#Plik do testeów

using AstroLib,Measurements,Plots,Dates

M = range(0, stop=2pi, length=1001)[1:end-1];
plot()
for ecc in (0, 0.5, 0.1)
    plot!(cos.((trueanom.(kepler_solver.(M, ecc), ecc))), sin.((trueanom.(kepler_solver.(M, ecc), ecc))))
end
plot!()|>display
plot(aspect_ratio = :equal)
ecc=0.01671123
a=1.49598261e+11
M = range(0, stop=2pi, length=1001)[1:end-1];
xs = (trueanom.(kepler_solver.(M, ecc), ecc))
ys = (trueanom.(kepler_solver.(M, ecc), ecc))
theta = mod2pi.(trueanom.(kepler_solver.(M, ecc), ecc))
r=@. a*(1-ecc^2)/(1+ecc*cos(theta))

plot(r.*cos.(theta),r.*sin.(theta),aspect_ratio=:equal)

AstroLib.planets["mars"]
(AstroLib.planets["earth"].period)/jdcnv(Day(1))

daycnv(2459000)
daycnv(2)
daycnv(3)
daycnv(4)4
(jdcnv(1))
Second(Day(1))



M = LinRange(0, 2pi, 1001)[1:end-1];
for ecc in (0.9)
    plot(M, mod2pi.(trueanom.(kepler_solver.(M, ecc), ecc)))
end
plot!()|>display
