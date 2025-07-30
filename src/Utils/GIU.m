function params = GIU()
% GIU - GUI to configure solar model parameters
% Returns a struct with all params or [] if dialog is closed

params = [];

d = dialog('Name', 'Solar Model Configuration', 'Position', [300 150 720 650]);
tgroup = uitabgroup('Parent', d, 'Position', [0.05 0.15 0.9 0.8]);

% --- Tab 1: General Params + Temp Model Selection ---
tab1 = uitab('Parent', tgroup, 'Title', 'General Parameters');

labels1 = {'Latitude (deg) 40:', ...
    'Longitude (deg) 50:', ...
    'Solar panel area (m²):', ...
    'Calculation time (hours, max 8760):', ...
    'Start date (UTC, yyyy-MM-dd HH:mm:ss):', ...
    'Influence radius (km):'};
defaults1 = {'40', '50', '1', '8760', datestr(datetime('now'),'yyyy-MM-dd HH:mm:ss'), '260'};
ypos1 = linspace(420, 150, numel(labels1));

editBoxes1 = gobjects(numel(labels1), 1);
for i = 1:numel(labels1)
    uicontrol('Parent', tab1, 'Style', 'text', 'Position', [20 ypos1(i) 280 25], ...
        'String', labels1{i}, 'HorizontalAlignment', 'left', 'FontSize', 10);
    editBoxes1(i) = uicontrol('Parent', tab1, 'Style', 'edit', 'Position', [310 ypos1(i) 180 30], ...
        'String', defaults1{i}, 'FontSize', 10, 'Tag', ['edit' num2str(i)]);
end

% Temperature model selection
uicontrol('Parent', tab1, 'Style', 'text', 'Position', [20 90 200 25], ...
    'String', 'Select Temperature Model:', 'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

bg = uibuttongroup('Parent', tab1, 'Position', [0.55 0.11 0.4 0.12], ...
    'SelectionChangedFcn', @tempModelChanged);

uicontrol(bg, 'Style', 'radiobutton', 'String', 'Instantaneous', ...
    'FontSize', 10, 'Position', [10 30 150 25], 'Value', 1);
uicontrol(bg, 'Style', 'radiobutton', 'String', 'Diffusion (Not Available)', ...
    'FontSize', 10, 'Position', [10 5 180 25], 'Enable', 'off');

% Add default temp model tab
tabInstant = createInstantaneousTab(tgroup);
currentTempTab = tabInstant;

% --- Tab: Efficiency Parameters ---
tabEff = uitab('Parent', tgroup, 'Title', 'Efficiency Parameters');
effLabels = {'Reference Temperature T_{ref} (K):', ...
             'Temperature Coefficient β_{ref} (1/K):', ...
             'Reference Efficiency η_{ref}:'};
effDefaults = {'298.15', '0.001962', '0.29'};
effTags = {'TrefEdit', 'betaRefEdit', 'etaRefEdit'};
effYPos = 350:-70:210;

for i = 1:numel(effLabels)
    uicontrol('Parent', tabEff, 'Style', 'text', 'Position', [20 effYPos(i) 300 30], ...
        'String', effLabels{i}, 'HorizontalAlignment', 'left', 'FontSize', 11);
    uicontrol('Parent', tabEff, 'Style', 'edit', 'Position', [310 effYPos(i)+3 180 30], ...
        'String', effDefaults{i}, 'FontSize', 11, 'Tag', effTags{i});
end


% OK Button
uicontrol('Parent', d, 'Position', [210 20 100 40], 'String', 'OK', 'FontSize', 12, ...
    'Callback', @(~,~) uiresume(d));

uiwait(d);

% Return if dialog closed without pressing OK
if ~isvalid(d)
    return;
end

try
    lat = str2double(editBoxes1(1).String);
    lon = str2double(editBoxes1(2).String);
    areaPanel = str2double(editBoxes1(3).String);
    t_hours = str2double(editBoxes1(4).String);
    t0_str = editBoxes1(5).String;
    influence_radius = str2double(editBoxes1(6).String);
catch
    errordlg('Error reading general parameters. Please check inputs.','Input Error');
    return;
end

% Parse datetime
try
    t_0 = datetime(t0_str, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
catch
    warning('Incorrect date format, using current datetime.');
    t_0 = datetime('now');
end

% Read temperature model tab
tempModel = bg.SelectedObject.String;

if strcmp(tempModel, 'Instantaneous')
    % Use findobj + handle indexing to avoid placeholder errors
    alphaBox = findobj(tabInstant, 'Tag', 'alphaEdit');
    IBox = findobj(tabInstant, 'Tag', 'IEdit');
    epsilonBox = findobj(tabInstant, 'Tag', 'epsilonEdit');
    sigmaBox = findobj(tabInstant, 'Tag', 'sigmaEdit');

    if isempty(alphaBox) || isempty(IBox) || isempty(epsilonBox) || isempty(sigmaBox)
        errordlg('Temperature parameter fields missing.','Input Error');
        return;
    end

    alpha = str2double(alphaBox(1).String);
    I_solar = str2double(IBox(1).String);
    epsilon = str2double(epsilonBox(1).String);
    sigma = str2double(sigmaBox(1).String);
else
    alpha = NaN; I_solar = NaN; epsilon = NaN; sigma = NaN;
end

% Read Efficiency Parameters
TrefBox = findobj(tabEff, 'Tag', 'TrefEdit');
betaRefBox = findobj(tabEff, 'Tag', 'betaRefEdit');
etaRefBox = findobj(tabEff, 'Tag', 'etaRefEdit');

params.T_ref = str2double(TrefBox(1).String);
params.beta_ref = str2double(betaRefBox(1).String);
params.eta_ref = str2double(etaRefBox(1).String);


close(d);

% Package everything
params.lat = lat;
params.lon = lon;
params.areaPanel = areaPanel;
params.t_hours = t_hours;
params.t_0 = t_0;
params.influence_radius = influence_radius;

params.temperatureModel = tempModel;
params.alpha = alpha;
params.I_solar = I_solar;
params.epsilon = epsilon;
params.sigma = sigma;

% ---- NESTED FUNCTIONS ----
    function tempModelChanged(~, event)
        if isvalid(currentTempTab)
            delete(currentTempTab);
        end

        switch event.NewValue.String
            case 'Instantaneous'
                currentTempTab = createInstantaneousTab(tgroup);
            case 'Diffusion (Not Available)'
                currentTempTab = uitab('Parent', tgroup, 'Title', 'Diffusion Model');
                uicontrol('Parent', currentTempTab, 'Style', 'text', ...
                    'Position', [20 250 460 50], ...
                    'String', 'Diffusion model is not yet available.', ...
                    'FontSize', 12, 'ForegroundColor', 'r', 'HorizontalAlignment', 'center');
        end
    end
end

function tab = createInstantaneousTab(parentGroup)
tab = uitab('Parent', parentGroup, 'Title', 'Instantaneous Temperature');

paramLabels = {'Albedo α:', 'Solar radiation I (W/m²):', 'Emissivity ε:', 'Stefan-Boltzmann constant σ (W/m²K⁴):'};
paramTags = {'alphaEdit', 'IEdit', 'epsilonEdit', 'sigmaEdit'};
paramDefaults = {'0.85', '1361', '0.94', '5.6704e-8'};
ypos = 350:-60:150;

for k = 1:numel(paramLabels)
    uicontrol('Parent', tab, 'Style', 'text', 'Position', [20 ypos(k) 280 30], ...
        'String', paramLabels{k}, 'HorizontalAlignment', 'left', 'FontSize', 11);
    uicontrol('Parent', tab, 'Style', 'edit', 'Position', [310 ypos(k)+3 180 30], ...
        'String', paramDefaults{k}, 'FontSize', 11, 'Tag', paramTags{k});
end
end
