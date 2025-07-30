function shadowed = checkShadow(latA, lonA, HA, DEM, R, solarAzimuth,solarElevation)
    % Constants
    Rmoon = 1737.4e3; % Mean lunar radius in meters
    max_distance = 260e3; % Maximum shadow distance to check
    pixel_scale = 2369.01;
    %pixel_scale = 214.53; para lunarX
    num_steps = round(max_distance / pixel_scale);

    shadowed = 1; % Assume illuminated by default


    % Step along the solar azimuth
    for step = 1:num_steps
        distance = step * pixel_scale;
        dx = distance * sind(solarAzimuth);
        dy = distance * cosd(solarAzimuth);

        % Convert displacements to degrees (approximation)
        dlat = (dy / (2 * pi * Rmoon)) * 360;
        dlon = (dx / (2 * pi * Rmoon * cosd(latA))) * 360;

        latB = latA + dlat;
        lonB = lonA + dlon;

        % Skip if outside valid bounds
        if latB < R.LatitudeLimits(1) || latB > R.LatitudeLimits(2) || ...
           lonB < R.LongitudeLimits(1) || lonB > R.LongitudeLimits(2)
            continue;
        end

        [rowB, colB] = latlon2pix(R, latB, lonB);
        rowB = round(rowB);
        colB = round(colB);

        if rowB < 1 || rowB > size(DEM, 1) || colB < 1 || colB > size(DEM, 2)
            continue;
        end

        HB = DEM(rowB, colB);
        %Hcrit = CriticalElevation(latA, lonA, HA, latB, lonB);
        HsunRay = HA + tand(solarElevation) * distance;
        Haparente = distance /sin(atan(distance/Rmoon))-Rmoon;
        % tand(solarElevation)
        % tand(solarElevation) * distance
        % if mod(step, 1) == 0
        %      fprintf('[DEBUG] Step %d: latB=%.2f, lonB=%.2f | H_B=%.2f, H_crit=%.2f, H_sunray=%.2f\n', ...
        %          step, latB, lonB, HB, Hcrit,HsunRay);
        % end

        if HB >= HsunRay + Haparente
            shadowed = 0;  % In shadow
            % if HB >= HsunRay
            %     shadowed = 0;  % In shadow
            %     return;
            % end
            return;
        end
    end
end

