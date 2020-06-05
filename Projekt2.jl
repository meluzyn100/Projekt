using AstroLib,Dates,Plots

one_day_s = 86400


function get_mean_anomali_list(Period, days = 3, endDays = 365)
    """
    Zwróć liste "średniej anomali".

    M=2*π/T*t
    M-średnia anomalia
    T-okres orbitalny(Period)
    t- moment czasu dla którego liczymy anomalię
    """

    data_list=[2*π/Period*t*one_day_s for t in 1:days:endDays]
    return data_list
end

function get_eccentric_anomali(M,e)
    """
    Zwróć "Anomalie mimośrodową" w zaleznosci od
    dnia M (średnia anomalia) i e (mimośród).
    """

    data_list = kepler_solver.(M, e)
    return data_list
end


function get_theta(M, e)
    """
    Zwróć kat jakie dana planeta zatoczyła w zaleznosci od M (średnia anomalia) i e (mimośród)
    """

     data_list = mod2pi.(trueanom.(M, e))
     return data_list
end

function get_radius(theta,e,semi_majo)
    """
    Zwróć odległość danej planety od gwiazdy w zaleznosci od katu,
    e (mimośród) i półosi wielkiej.
    """

    r=@. semi_majo*(1-e^2)/(1+e*cos(theta))
    return r
end

function transform_3D(x,y,Theta)
    """
    Funkcja obraca planety wpkół osi OY o podany kat.

    x`=cosθ
    y`=y
    z=-sinθ
    """

    return x*cos(Theta),y,-x*sin(Theta)
end




#--------------------Testowe rysowane wykresu jednej plaentu-------------------
#ustalanie danych planety

function PlotPlanet(planet, days = 3, endDays = 100)
    if typeof(planet) == String
        periodPlanet = AstroLib.planets[planet].period
        eccPlanet = AstroLib.planets[planet].ecc
        semi_mPlanet = AstroLib.planets[planet].axis
    else
        periodPlanet = planet[2]
        eccPlanet = planet[3]
        semi_mPlanet = planet[4]
    end        
    planet_M_list = get_mean_anomali_list(periodPlanet, days, endDays)
    planet_E_list = get_eccentric_anomali(planet_M_list, eccPlanet)
    planet_Theta_list = get_theta(planet_M_list, eccPlanet)
    planet_R_list = get_radius(planet_Theta_list, eccPlanet, semi_mPlanet)
    xs_2D=cos.(planet_Theta_list)
    ys_2D=sin.(planet_Theta_list)
    xs_3D=[transform_3D.(xs_2D,ys_2D,pi/4)[i][1] for i in 1:length(xs_2D)]
    ys_3D=ys_2D
    zs_3D=[transform_3D.(xs_2D,ys_2D,pi/4)[i][3] for i in 1:length(xs_2D)]
    return (planet_R_list, xs_3D, ys_3D , zs_3D)
end     

#Wyswietl wszystko
# plot(erth_R_list.*cos.(erth_Theta_list),erth_R_list.*sin.(erth_Theta_list))
# plot!(aspect_ratio = :equal)|>display



# maxr=maximum(erth_R_list *25)#W przyszłosci bedziemy sprawdzac maksymalna połoś

#animacja
function MaxT(Planets)                               # Funkcja zwracająca max R
    Tmax = []
    for i in Planets
        if typeof(i) == String
            push!(Tmax, AstroLib.planets[i].period)
        else
            push!(Tmax, i[2])
        end
    end
    return floor(maximum(Tmax)/one_day_s)
end 

function MaxR(Planets)                               # Funkcja zwracająca max R
    Rmax = []
    for i in Planets
        if typeof(i) == String
            push!(Rmax, AstroLib.planets[i].axis)
        else
            push!(Rmax, i[4])
        end
    end
    return maximum(Rmax)
end           



function Animation(List, days = 5, maxDay = Nothing)
    if maxDay == Nothing
        T = MaxT(List)
    else
        T = maxDay
    end        
            
    R = MaxR(List)
    
    anim = @animate for i in 1:100                                                                        #  Bedzie trzeba zmienic
        plot(aspect_ratio = :equal,xlim = (-R,R),
            ylim = (-R,R), zlim = (-R,R),
            foreground_color_legend = nothing,
            background_color_legend = nothing, xlabel="x")

        scatter!([0],[0],[0],markersize = 20,
            markercolor = :yellow,
            label="Sun")
        
            for j in List
                planet_R_list = PlotPlanet(j, days, T)[1]
                xs_3D = PlotPlanet(j, days, T)[2]
                ys_3D = PlotPlanet(j, days, T)[3]
                zs_3D = PlotPlanet(j, days, T)[4]
                scatter!([planet_R_list[i] * xs_3D[i]],
                    [planet_R_list * ys_3D[i]],[planet_R_list[i] * zs_3D[i]],
                    label="$(j)")
                    
            end        
    end
    
    gif(anim, "anim_fps15.gif", fps = 15)
end    

#Indeks poprawić i wielkość kropeczek