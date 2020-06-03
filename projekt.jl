using AstroLib,Dates,Plots

one_day_s = 86400


function get_mean_anomali_list(Period)
    """
    Zwróć liste "średniej anomali".

    M=2*π/T*t
    M-średnia anomalia
    T-okres orbitalny(Period)
    t- moment czasu dla którego liczymy anomalię
    """

    data_list=[2*π/Period*t*one_day_s for t in 1:3:365]
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


period =AstroLib.planets["earth"].period
e = AstroLib.planets["earth"].ecc
semi_m =AstroLib.planets["earth"].axis
earth_M_list = get_mean_anomali_list(period)
erth_E_list = get_eccentric_anomali(earth_M_list, e)
erth_Theta_list = get_theta(earth_M_list, e)
erth_R_list = get_radius(erth_Theta_list, e, semi_m)

plot(erth_R_list.*cos.(erth_Theta_list),erth_R_list.*sin.(erth_Theta_list))
plot!(aspect_ratio = :equal)
