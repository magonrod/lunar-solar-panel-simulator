function totalEnergy = totalEnergy(params, DEM, R)
    lat = params.lat;
    lon = params.lon;
    areaPanel = params.areaPanel;
    t_hours = params.t_hours;
    t_0 = params.t_0;

    totalEnergy = 0;
    endTime = t_0 + hours(t_hours);
    timeVec = t_0:hours(1):endTime;

    [rowA, colA] = geographicToDiscrete(R, lat, lon);
    if rowA < 1 || rowA > size(DEM, 1) || colA < 1 || colA > size(DEM, 2)
        warning('Point outside DEM bounds');
        totalEnergy = NaN;
        return;
    end

    HA = DEM(rowA, colA);  % Elevation at the point

    for t = 1:length(timeVec)
        utc_time = timeVec(t);
        [solarAlt, solarAzimuth, ~, ~] = solarAltitude(lon, lat, utc_time);

        if solarAlt > 0
            shadowed = checkShadow(lat, lon, HA, DEM, R, solarAzimuth, solarAlt);
            if shadowed == 1
                T = temperature(params, solarAlt);
                eta = efficiency(params, T);
                I = solarRadiation(params);
                E = I * areaPanel * eta;
            else
                E = 0;
            end
        else
            E = 0;
        end
        totalEnergy = totalEnergy + E;
    end
end
