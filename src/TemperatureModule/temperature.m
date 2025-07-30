function T = temperature(params, solarElevation)
    alpha = params.alpha;
    I_solar = params.I_solar;
    epsilon = params.epsilon;
    sigma = params.sigma;

    theta = deg2rad(90 - solarElevation);
    if solarElevation <= 0
        T = 50;  % fallback nighttime temperature
    else
        T = ((alpha * I_solar * cos(theta)) / (epsilon * sigma)) ^ 0.25;
    end
end

