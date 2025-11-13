function energy = simularEnergia(lat, lon, DEM, R)
    A = 1;      % Área del panel (m²)
    I = 1361;   % Irradiancia solar (W/m²)
    totalEnergy = 0;

    % Definir el intervalo temporal
    startTime = datetime(2025, 1, 1, 1, 0, 0);
    endTime = datetime(2025, 12, 31, 12, 59, 59);
    timeVec = startTime:hours(1):endTime;
    
    [rowA, colA] = geographicToDiscrete(R, lat, lon);

    % Ensure indices are within bounds
    if rowA < 1 || rowA > size(DEM, 1) || colA < 1 || colA > size(DEM, 2)
        shadowReason = "Point outside DEM bounds";
        HA = NaN;  
        return;
    end

    HA = DEM(rowA, colA);  % Elevation at the point

    for t = 1:length(timeVec)
        utc_time = timeVec(t);
        currentDateVec = datevec(utc_time);

        [solarAltitude, solarAzimuth, latS, lonS] = SolarAltitude(lon, lat, utc_time);
        
        if solarAltitude > 0
            shadowed = CheckShadow(lat, lon, HA, DEM, R, solarAzimuth, solarAltitude);
            if shadowed == 1
                T = temperaturaInstantanea(solarAltitude);
                eta = rendimientoPanel(T);
                energy = I * A * eta;
            else
                energy = 0;
            end  
        else
            energy = 0;
        end

        totalEnergy = totalEnergy + energy;
    end

    energy = totalEnergy; % Positivo: producción total anual (o mensual)
end

