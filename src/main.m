close all; clc;
addpath('EfficiencyModule'); 
addpath('EnergyModule'); 
addpath('ShadowModule'); 
addpath('SolarRadiationModule'); 
addpath('TemperatureModule'); 
addpath('Utils'); 

useGUI = true; % Change to false to use manual inputs

if useGUI
    % Call GUI helper to get parameters
    params = GIU();
    if isempty(params)
        error('User canceled the configuration dialog.');
    end
else
    % Manual input example
    params.lat = 40;
    params.lon = 50;
    params.areaPanel = 1;
    params.t_0 = datetime('now');
    params.t_hours = 8760;
    params.influence_radius = 260;

    params.temperatureModel = 'Instantaneous';
    params.alpha = 0.85;
    params.I_solar = 1361;
    params.epsilon = 0.94;
    params.sigma = 5.6704e-8;

    params.T_ref = 298.15;
    params.beta_ref = 0.001962;
    params.eta_ref = 0.29;
end

fprintf('\n---- Model Parameters ----\n');
fprintf('Latitude: %.2f°\n', params.lat);
fprintf('Longitude: %.2f°\n', params.lon);
fprintf('Solar panel area: %.2f m²\n', params.areaPanel);
fprintf('Calculation time: %.0f hours\n', params.t_hours);
fprintf('Start date (UTC): %s\n', datestr(params.t_0));
fprintf('Influence radius: %.0f km\n', params.influence_radius);
fprintf('---------------------------\n', params.influence_radius);
fprintf('Temperature model: %s\n', params.temperatureModel);
if strcmp(params.temperatureModel, 'Instantaneous')
    fprintf('Albedo α: %.2f\n', params.alpha);
    fprintf('Solar radiation I: %.1f W/m²\n', params.I_solar);
    fprintf('Emissivity ε: %.2f\n', params.epsilon);
    fprintf('Stefan-Boltzmann constant σ: %.4e W/m²K⁴\n', params.sigma);
end
fprintf('---------------------------\n', params.influence_radius);
fprintf('T_ref: %.2f\n', params.T_ref);
fprintf('beta_ref I: %.4f W/m²\n', params.beta_ref);
fprintf('eta_ref: %.4f\n', params.eta_ref);
fprintf('---------------------------\n', params.influence_radius);
S = load('SLDEM2015_north_to_south.mat'); %% This should be the name of your DEM file
DEM = S.Z_flipped;
R = S.R_flipped;

% Energy module - final energy calculation

%%energyOutput = totalEnergy(lat, lon, DEM, R);
energyOutput = totalEnergy(params, DEM, R);

%energyOutput = totalEnergy(radiationOutput, shadowOutput, efficiencyOutput);
% Display final energy
  
fprintf('\n');
fprintf('╔══════════════════════════════╗\n');
fprintf('║     Total Energy Computed    ║\n');
fprintf('╚══════════════════════════════╝\n');
fprintf('%.4f W\n', energyOutput);


