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

function DataPlanet(planet, days = 3, endDays = 365)
    if planet == "pluto"
        return @error("Pluton to nie planeta  :(")
    elseif typeof(planet) == String
        periodPlanet = AstroLib.planets[planet].period
        eccPlanet = AstroLib.planets[planet].ecc
        semi_mPlanet = AstroLib.planets[planet].axis
        incPlanet = AstroLib.planets[planet].inc
    else
        namePlanet=planet[1]
        periodPlanet = planet[2]
        eccPlanet = planet[3]
        semi_mPlanet = planet[4]
        incPlanet = planet[5]
    end
    planet_M_list = get_mean_anomali_list(periodPlanet, days, endDays)
    planet_E_list = get_eccentric_anomali(planet_M_list, eccPlanet)
    planet_Theta_list = get_theta(planet_M_list, eccPlanet)
    planet_R_list = get_radius(planet_Theta_list, eccPlanet, semi_mPlanet)
    xs_2D=cos.(planet_Theta_list)
    ys_2D=sin.(planet_Theta_list)
    xs_3D=[transform_3D.(xs_2D,ys_2D,incPlanet)[i][1] for i in 1:length(xs_2D)]
    ys_3D=ys_2D
    zs_3D=[transform_3D.(xs_2D,ys_2D,incPlanet)[i][3] for i in 1:length(xs_2D)]
    return (planet_R_list, xs_3D, ys_3D , zs_3D)
end



#Wyswietl wszystko
# plot(erth_R_list.*cos.(erth_Theta_list),erth_R_list.*sin.(erth_Theta_list))
# plot!(aspect_ratio = :equal)|>display



# maxr=maximum(erth_R_list *25)#W przyszłosci bedziemy sprawdzac maksymalna połoś

#animacja
function MaxT(Planets)                           # Funkcja zwracająca max R
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

function Create_data_list(days, T, list)
    """
    Zwróć liste odlegosci,współzednych x, współzednych y, współzednych z
    w zaleznosci od dnia

    days - Co ile dni ma byc zwracana wartosc
    T - Ostati dzień
    list - lista planet dla ktorych maja byc zwrucone wartosci
    """
    r_list=[]
    x_list=[]
    y_list=[]
    z_list=[]
    for i in list
        data = DataPlanet(i, days, T)
        push!(r_list,data[1])
        push!(x_list,data[2])
        push!(y_list,data[3])
        push!(z_list,data[4])
    end
    return r_list,x_list,y_list,z_list
end

function Name(name)
    if typeof(name) == String
        return name
    else
        return name[1]
    end
end

function Animation(List, days = 8, maxDay = nothing)
    List = lowercase.(List)

    if maxDay == nothing
        T = MaxT(List)
    else
        T = maxDay
    end
    R = MaxR(List)


    data_list = Create_data_list(days,T,List)
    planet_R_list =data_list[1]
    xs_3D=data_list[2]
    ys_3D=data_list[3]
    zs_3D=data_list[4]
    anim = @animate for i in 1:Int(floor(T/days))
        plot(aspect_ratio = :equal,xlim = (-R,R),
            ylim = (-R,R), zlim = (-R,R),
            foreground_color_legend = nothing,
            background_color_legend = nothing, xlabel="x",
            size = (1280, 720))
                                                                                   #  Bedzie trzeba zmienic
            scatter!([0],[0],[0],markersize = 20,
                    markercolor = :yellow, alpha=0.5,
                    label="Sun")

            for k in 1:length(List)
                r=planet_R_list[k]
                plot!([r.*xs_3D[k]],[r.*ys_3D[k]],[r.*zs_3D[k]], label = nothing)
            end


            for j in 1:length(List)
                r=planet_R_list[j][i]
                scatter!([r*xs_3D[j][i]],[r*ys_3D[j][i]],[r*zs_3D[j][i]],label= uppercasefirst(Name(List[j])), markersize = 7 )
            end
    end
    gif(anim, "anim_SolarSystem.gif", fps = 15)

end
