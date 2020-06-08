module PlanetarySystem

export one_day_s, get_mean_anomali_list, get_eccentric_anomali, get_theta,
get_radius, transform_3D, DataPlanet, MaxT, MaxR, CreateDataList, System_Animation

using AstroLib,Plots

one_day_s = 86400                                                                   # Ilość sekund w jednym dniu

@doc """
    get_mean_anomali_list(Period, days = 3, endDays = 365)

    Zwraca listę "średniej anomali".

    M = 2*π/T*t
    M - średnia anomalia
    T - okres orbitalny(Period)
    t - moment czasu, dla którego liczymy anomalię

""" function get_mean_anomali_list(Period, days = 3, endDays = 365)
    data_list = [2 * π / Period * t * one_day_s for t in 1:days:endDays]
    return data_list
end

@doc """
    get_eccentric_anomali(M, e)

    Zwraca "Anomalie mimośrodową" w zaleznosci od
    dnia M (średnia anomalia) i e (mimośród).

""" function get_eccentric_anomali(M, e)
    data_list = kepler_solver.(M, e)
    return data_list
end


@doc """
    get_theta(M, e)

    Zwraca kąty(prawdziwa anomalia) jakie dana planeta zatoczyła w zaleznosci
    od M (średnia anomalia) i e (mimośród)

""" function get_theta(M, e)
     data_list = mod2pi.(trueanom.(M, e))
     return data_list
end

@doc """
    get_radius(theta,e,semi_majo)

    Zwróć odległość danej planety od gwiazdy w zaleznosci od kata,
    e (mimośród) i półosi wielkiej.

""" function get_radius(theta,e,semi_majo)
    r=@. semi_majo*(1-e^2)/(1+e*cos(theta))
    return r
end

@doc """
    transform_3D(x,y,Theta)
    
    Funkcja  obraca  punkt o współrzędnych (x,y,0) wokół OY o podany kąt.

    x`= cosθ*x
    y`= y
    z = -sinθ*x

""" function transform_3D(x,y,Theta)
    return x*cos(Theta),y,-x*sin(Theta)
end


@doc """
    DataPlanet(planet, days = 3, endDays = 365)

    Funkcja zwracająca listy promieni i położeń (R, x, y, z)

    planet - wybrana planeta
    days - co ile dni są liczone dane
    endDays - dzień do którego liczone są dane

""" function DataPlanet(planet, days = 3, endDays = 365)                            # Funkcja przygotowująca planety do animowania
    if planet == "pluto"                                                            # Od 2006r Pluton to nie planeta, jednak AstroLib pozwala na kożystanie z jego danych
        return @error("Pluton to nie planeta  :(")                                  # Natomiast jego promień jest tak duży, że animacje generują sie zbyt długo
    elseif typeof(planet) == String                                                 # Użydkownik może wpisać nazwe planety z Układu Słonecznego np. "earth"
        periodPlanet = AstroLib.planets[planet].period                              # Biblioteka AstroLib pozwoli zwrócić jego: okres obiegu,
        eccPlanet = AstroLib.planets[planet].ecc                                    # Zakrzywienie elipsy,
        semi_mPlanet = AstroLib.planets[planet].axis                                # Półoś wielką
        incPlanet = AstroLib.planets[planet].inc                                    # Oraz kąt nachylenia elipsy
    else                                                                            # Użytkownik może również stworzyć swoją własną planetę
        namePlanet=planet[1]                                                        # Jej tworzenie wytłumacze później
        periodPlanet = planet[2]
        eccPlanet = planet[3]
        semi_mPlanet = planet[4]
        incPlanet = planet[5]
    end                                                                             # Korzystamy z wyżej napisanych funkcji
    planet_M_list = get_mean_anomali_list(periodPlanet, days, endDays)              # Generujemy listę średnich anomalii
    planet_E_list = get_eccentric_anomali(planet_M_list, eccPlanet)                 # Lista anomalii mimśrodowych
    planet_Theta_list = get_theta(planet_M_list, eccPlanet)                         # Zwraca listę kątów jakie dana planeta zatoczyła
    planet_R_list = get_radius(planet_Theta_list, eccPlanet, semi_mPlanet)          # Lista odległości od słońca
    xs_2D = cos.(planet_Theta_list)
    ys_2D = sin.(planet_Theta_list)
    xs_3D = [transform_3D.(xs_2D,ys_2D,incPlanet)[i][1] for i in 1:length(xs_2D)]   # Dwuwymiarową elipsę odchylamy o kąt nachylenia orbity względem płaszczyzny ekliptyki
    ys_3D = ys_2D
    zs_3D = [transform_3D.(xs_2D,ys_2D,incPlanet)[i][3] for i in 1:length(xs_2D)]
    return (planet_R_list, xs_3D, ys_3D , zs_3D)                                    # Zwracamy tuplę odpowiednio z listami promieni oraz położenia względem odi OX, OY, OZ
end


@doc """
    MaxT(Planets)

    Funkcja zwracająca największy okres obiegu

    Planets - lista planet

""" function MaxT(Planets)                                                          # Ta funkcja będzie potrzebna do proponowania długości animacji
    Tmax = []                                                                       # Tworzymy pustą listę
    for i in Planets                                                                # Dla każdej planety z listy
        if typeof(i) == String                                                      # Jeżeli element jest nazwą np. "Jupiter"
            push!(Tmax, AstroLib.planets[i].period)                                 # Dodajemy jego okres obiegu do listy Tmax
        else                                                                        # Jeśli nie jest nazwą pobieramy odpowiedni element tupli
            push!(Tmax, i[2])                                                       # I dodajemy do listy Tmax
        end
    end
    return floor(maximum(Tmax)/one_day_s)                                           # Wybieramy największą wartość, dzielimy prze ilość sekung by otrzymać wynik w dniach
end                                                                                 # I przybliżamy ją do liczby całkowitej

@doc """
    MaxR(Planets)

    Funkcja zwracająca największy promień

    Planets - lista planet

""" function MaxR(Planets)                                                          # Funkcja przyda sie do wyznaczenia przdziałów animacji
    Rmax = []                                                                       # Działa podobnie do powyższej
    for i in Planets
        if typeof(i) == String
            push!(Rmax, AstroLib.planets[i].axis)                                   # Jednak zwraca półosie wielkie planet
        else
            push!(Rmax, i[4])
        end
    end
    return maximum(Rmax)                                                            # Ponownie wybieramy największą
end

@doc """
    CreateDataList(days, T, list)

    Zwróci liste odlegosci,współzednych x, współzednych y, współzednych z
    w zaleznosci od dnia

    days - Co ile dni ma byc zwracana wartość
    T - Ostati dzień
    list - lista planet dla ktorych maja być zwrócone wartosci

""" function CreateDataList(days, T, list)                                          # Fukcja jest przydatna do optymalizacji programu, zamiast wywoływać funkcję DataPlanet w animacji zapisujemy jej wynik wcześniej
    r_list = []                                                                     # Tworzymy puste listyodpowiadające promieniom
    x_list = []                                                                     # Oraz współżednym X
    y_list = []                                                                     # Y
    z_list = []                                                                     # Z
    for i in list                                                                   # Dla każdej planety z listy
        data = DataPlanet(i, days, T)                                               # Wywołujemy powyższą funkcję DataPlanet
        push!(r_list,data[1])                                                       # I wywołanie w odpowiednich listach
        push!(x_list,data[2])
        push!(y_list,data[3])
        push!(z_list,data[4])
    end
    return r_list, x_list,y_list, z_list                                            # Zwracamy te listy
end

@doc """
    Name(name)

    Funkcja zwracająca nazwę planety

    name - planeta z której wyznaczamy nazwę

""" function Name(name)                                                             # Podczas tworzenia własnych orbitali nazwa planety nie jest bezpośrednim elementem listy planet z której będziemy korzysta
    if typeof(name) == String                                                       # Jeżeli element jest tylko nazwą
        return name                                                                 # To zwraca jego samego
    else                                                                            # Jeśli nie
        return name[1]                                                              # Zwraca element tupli, który odpowiada nazwie
    end
end


@doc """
    System_Animation(List; days = 8, maxDay = nothing, directory = "SolarSystem", fps = 15, elips = true)

    Funkcja tworząca animacje wybranych planet układu Słonecznego.
    Aby działała poprwnie należy podać jej listę z nazwami wybranych
    planet z układu słonecznego. Pozwola ona równierz na tworzenie własnych
    orbitali. Należy podać typlę z odpowiednimi argumentami:
    ("nazwa planety", okres obiegu wokół słońca, zakrzywienie elipsy (mimośród), półoś wielka elipsy, i kąt nachylenia elipsy)
    Przykładowym wywołanie tej funkcji jest np.
    System_Animation(["earth", "venus",  "mercury", ("Death Star", 3.15581497635456e7, 0.00677672, 1.0820947453737917e11, 1.149691)], days = 4, maxDay = 366, directory = "System", fps = 15, elips = true).
    Funkcja wykorzystuje keywords, pozwala to na wybrane dowolnego argumentu opcionalnego bez potrzeby wbisywania
    wszystkich poprzednich (np. fps = 30)

    List - lista planet
    days - co ile dni mierzymy pozycje planety (opcionalne, domyślnie 8)
    maxDay - dzień do którego liczymy pozycję planet (opcionalne)
    directory - kierunek i nazwa animacji(opcjinalne, domyślnie "SolarSystem.gif")
    fps - ilość klatek na sekundę animacji
    elips -  decyduje czy funkcja będzie rysować tor ruchu planet (opcionalne, domyślnie true)

""" function System_Animation(List; days = 8, maxDay = nothing, directory = "SolarSystem",
                   fps = 15, elips = true)                                          # Funkcja generująca animacje obiegu planet
    for k in List                                                                   # Jeżeli użytkownik poda nazwe planety z wielkiej litery to program nie zadziała
        if typeof(k) == String                                                      # Więc każdą kolejną nazwę
            replace(List, k => lowercase(k))                                        # Sprowadzamy do małych liter wyłącznie
        end
    end

    if maxDay == nothing                                                            # Jeżeli nie wybierzemy w jakiem miejscu kończyć sie będzie animacja
        T = MaxT(List)                                                              # Program domyślnie wybierze planetę o najwyższym okresie, a animacjua będzie trwac do końca jej obiegu
    else                                                                            # Jeżeli jednak zdecydujemy o długości dni
        T = maxDay                                                                  # Funkcja wybierze tą wartość
    end

    R = MaxR(List)                                                                  # Wyznaczamy maksymalną półoś wielką

    data_list = CreateDataList(days, T, List)                                       # Wywołujemy funkcję CreateDataList
    planet_R_list =data_list[1]                                                     # Zapisujemy odpowiednie wywołania w zmiennych
    xs_3D=data_list[2]
    ys_3D=data_list[3]
    zs_3D=data_list[4]

    anim = @animate for i in 1:Int(floor(T/days))                                   # Generujemy animacje. Okres z funkcji MaxT(Planets) przyda sie tutaj do proponowania dnia kończącego animacje
        plot(aspect_ratio = :equal, xlim = (-R,R),                                  # Tworzymy tło
            ylim = (-R,R), zlim = (-R,R),                                           # Dzięki funkcji MaxR(Planets) wykorzystaliśmy promień najbardziej oddalonej planety do ograniczenia przestrzeni
            foreground_color_legend = nothing,                                      # Dalej dopracowywujemy odpowiednie parametry tła
            background_color_legend = nothing, xlabel="X",
            ylabel="Y", zlabel="Z", title = "Planetar system",
            legendfontsize = 14, titlefontsize = 20,
            xtickfontsize = 12, ytickfontsize = 12, ztickfontsize = 12,
            size = (1440, 900),legendtitle = "$(i*days) day",
            legendtitlefontsize = 14)

        scatter!([0],[0],[0],markersize = 20,                                       # Generujemy Słońce (punk o współżędnych 0, 0, 0)
                markercolor = :yellow, alpha=0.5,                                   # Powiększamy go i wybieramy kolor
                label="Sun")

        if elips
            for k in 1:length(List)
                r=planet_R_list[k]
                plot!([r.*xs_3D[k]], [r.*ys_3D[k]], [r.*zs_3D[k]], label = nothing)
            end
        end

        for j in 1:length(List)                                                     # Pętla animująca każdą planetę
            r = planet_R_list[j][i]                                                 # Wykorzystując wcześniej wyszukane i opisane informacje
            scatter!([r*xs_3D[j][i]], [r*ys_3D[j][i]], [r*zs_3D[j][i]],             # Animujemy każdą zwróconą pozycje planet
            label= uppercasefirst(Name(List[j])), markersize = 7 )                  # Nadajemy im nazwy w legendzie i wybieramy wielkość znaczników
        end
    end
    gif(anim, "$directory.gif", fps = fps)                                          # Zapisujemy animacje (domyślnie 15 fps)
end
end
