function [gamma, Az, latS, lonS] = solarAltitude(lonA, latA, utc_time)
    % Computes solar altitude and azimuth at lunar site A

    jd = juliandate(utc_time);
    T = (jd - 2451545.0)/36525;

    delta = 1.54* sind(360 * (day(utc_time, 'dayofyear') - 81) / 354.36707);
    
    latS = delta;

    % Subsolar longitude estimation
    lambda_0 = -125; %ajuste %9.985;%-33.442;%-69.985; %Assume subsolar longitude at J2000
    %Sub-Solar Longitude, Latitude	-134.198°, 0.242° from https://svs.gsfc.nasa.gov/4768/
    hours_since_j2000 = (jd - 2451545.0) * 24;
    t_days = hours_since_j2000 / 24;
    lonS = mod(lambda_0 - 12.19 * t_days, 360);
    if lonS < 0
        lonS = lonS + 360;
    end

    R_sm = 1; %aproximadamente
     
    gamma = asind( ...
    sind(latS)*sind(latA) + ...
    cosd(latS)*cosd(latA)*cosd(lonA - lonS) );

    
    % --- Solar Azimuth ---
    Sx = cosd(latS)*sind(lonS-lonA);
    Sy = cosd(latA)*sind(latS)-sind(latA)*cosd(latS)*cosd(lonS-lonA);
    %Sz = sind(latA)*sind(latS)+cosd(latA)*cosd(latS)*cosd(lonS-lonA);
    %Az = atan2d( sind(lonS - lonA), cosd(latA)*tand(latS) - sind(latA)*cosd(lonS - lonA) );
    Az = atan2d(Sx,Sy);

    %Az = mod(Az +360, 360); % Normalize to [0, 360)
end

