using Plots

function r(a,e,theta)
    r = a * (1 - e^2)/(1 + e*cos(theta))
end

function circle(x,y,r)
    theta = LinRange(0,2*pi,360)
    return x .+ r*cos.(theta), y .+ r*sin.(theta)
end

a=	1.49598261*10^11 #pól os wie
e = 0.01671123
theta = LinRange(0,2*pi,360)

rp = a*(1 - e)
ra = a*(1 + e)

sun = (ra -rp)/2
sr = 6.96340*10^8
kat = 0
kat1 = pi
allr = r.(a,e,theta)
# scatter(theta,r.(a,e,theta),proj=:polar
x = allr.* cos.(theta) * cos(kat)
y = allr.*sin.(theta)
z = -allr.* cos.(theta) * sin(kat)

plot()
plot([allr.* cos.(theta) .+ cos(kat)],[allr.*sin.(theta)],[-allr.* cos.(theta) .+ sin(kat)])
plot!([allr.* cos.(theta) .+ cos(kat1)],[allr.*sin.(theta)],[-allr.* cos.(theta) .+ sin(kat1)])
plot!()|>display

# plot!(circle(sun,0,sr))
# scatter!([0],[0],  markershape = :hexagon,)
