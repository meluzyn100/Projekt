


M = LinRange(0, 2pi, 1001)[1:end-1];
for ecc in (0.9)
    plot(M, mod2pi.(trueanom.(kepler_solver.(M, ecc), ecc)))
end
pusto=[]
xs=LinRange(-2,2,100)
nxs=cos(pi/2).* xs
nzs=-sin(pi/2).*xs
pusto=push!(pusto,xs.+1)
plot(xs,xs,zeros(100))
scatter!(nxs,xs,nzs,camera=(0,0))

for i in 1:2
    scatter!([1,2,3],lololo[i,:])
end
plot!()|>display
