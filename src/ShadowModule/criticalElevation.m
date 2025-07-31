function H = CriticalElevation(latA, lonA, HA, latB, lonB)
    % Computes critical elevation H at B needed to shadow A

    Rmoon = 1737.4e3; % mean lunar radius in meters

    % Altura critica del punto B. si esta es mayor que la verdadera altura
    % de B, el sitio A está iluminado
    H = (Rmoon + HA)/...
        (sind(latA)*sind(latB) + cosd(latA)*cosd(latB)*cosd(lonA - lonB))...
        - Rmoon;
end

