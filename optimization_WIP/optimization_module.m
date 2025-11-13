%% GRADIENT
clc,clear,close all
format long
warning('off','MATLAB:fplot:NotVectorized');

S = load('SLDEM2015_north_to_south.mat');
DEM = S.Z_flipped;
R = S.R_flipped;


x0=[40 90];
lb = [-60, 0];
ub = [60, 360];

% === Modify options setting ===
options = optimoptions('fmincon');
options = optimoptions(options,'Display', 'iter');
%options = optimoptions(options,'OutputFcn', { @plot_iter });
%options = optimoptions(options,'Algorithm', 'sqp');
%options = optimoptions(options,'Algorithm', 'quasi-newton');
% === Define the objective function ===
F = @(x) -simularEnergia(x(1), x(2), DEM, R);
[x,fval,exitflag,output,lambda, grad,hessian] = fmincon(F, x0,[],[],[],[],lb,ub,[], options);
fprintf('F1: Minimum is at x(1)=%f x(2)=%f, Function value is %f\n', x(1), x(2), fval);

x,fval,exitflag,output,lambda, grad,hessian
cond_H = cond(hessian);
fprintf('Número de condición de Hessiana: %e\n', cond_H);

save('resultado_gradiente.mat', 'x', 'fval');  

%% SCALING AND SENSITIVITY ANALYSIS

scale1 = 1/ sqrt(hessian(1,1)) 
scale2 = 1/ sqrt(hessian(2,2))  

F_scaled = @(xt) -simularEnergia(scale1 * xt(1), scale2 * xt(2) , DEM, R);

xt0 = [x(1) / scale1; x(2) / scale2];

lb_scaled = [lb(1)/scale1; lb(2)/scale2]
ub_scaled = [ub(1)/scale1; ub(2)/scale2]

options_scaled = options;

[xt_opt, fval_scaled, exitflag_scaled, output_scaled, lambda_scaled, grad_scaled, hessian_scaled] = ...
    fmincon(F_scaled, xt0, [], [], [], [], lb_scaled, ub_scaled, [], options_scaled);

x_opt = [scale1 * xt_opt(1); scale2 * xt_opt(2)];

% === Results ===
fprintf('Solución reescalada:\n');
fprintf('x1 (latitud) = %.8f\n', x_opt(1));
fprintf('x2 (longitud) = %.8f\n', x_opt(2));
fprintf('Valor función objetivo = %.8f\n', fval_scaled);

xt_opt, fval_scaled, exitflag_scaled, output_scaled, lambda_scaled, grad_scaled, hessian_scaled

fprintf('Número de condición de Hessiana escalada: %e\n', cond(hessian_scaled));


%% Heuristic Methods
warning('off', 'all');
rng default

% === General Setup ===
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
logfile = 'resultados_optimizacion.txt';

S = load('SLDEM2015_north_to_south.mat');
DEM = S.Z_flipped; R = S.R_flipped;
F = @(x) -simularEnergia(x(1), x(2), DEM, R);
nvars = 2; lb = [-60, 0]; ub = [60, 360];

% === Run all optimizers ===
run_optimizer('GA', F, lb, ub, @ga_tracker_inline, logfile, ...
    optimoptions('ga', 'Display','iter','MaxGenerations',15,'PopulationSize',15, 'OutputFcn', @ga_tracker_inline), ...
    optimoptions('ga', 'Display','iter','MaxGenerations',30,'PopulationSize',30, 'OutputFcn', @ga_tracker_inline),...
    optimoptions('ga', 'Display','iter','MaxGenerations',50,'PopulationSize',50, 'OutputFcn', @ga_tracker_inline));

run_optimizer('PSO', F, lb, ub, @pso_tracker_inline, logfile, ...
    optimoptions('particleswarm','Display','iter','MaxIterations',15,'OutputFcn', @pso_tracker_inline), ...
    optimoptions('particleswarm','Display','iter','MaxIterations',30,'OutputFcn', @pso_tracker_inline),...
    optimoptions('particleswarm','Display','iter','MaxIterations',50,'OutputFcn', @pso_tracker_inline));

run_optimizer('SA', F, lb, ub, @sa_tracker_inline, logfile, ...
    optimoptions('simulannealbnd','Display','iter','MaxIterations',100,'OutputFcn', @sa_tracker_inline), ...
    optimoptions('simulannealbnd','Display','iter','MaxIterations',200,'OutputFcn', @sa_tracker_inline),...
    optimoptions('simulannealbnd','Display','iter','MaxIterations',300,'OutputFcn', @sa_tracker_inline));


% === Optimization Wrapper ===
function run_optimizer(name, F, lb, ub, outFcn, logfile, options1, options2,options3)
    configs = {options1, options2,options3};
    for k = 1:length(configs)
        opt = configs{k};
        tstart = tic;

        % Random x0 if needed
        x0 = rand(1,2).*(ub - lb) + lb;

        % Run and capture text output
        switch name
            case 'GA'
                cmd = '[x,fval,exitflag,output] = ga(F,2,[],[],[],[],lb,ub,[],opt);';
            case 'PSO'
                cmd = '[x,fval,exitflag,output] = particleswarm(F,2,lb,ub,opt);';
            case 'SA'
                cmd = '[x,fval,exitflag,output] = simulannealbnd(F,x0,lb,ub,opt);';
        end
        output_text = evalc(cmd);
        duration = toc(tstart);
        timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

        % Log output
        fid = fopen(logfile, 'a');
        if fid == -1, error('Cannot open log file'); end
        fprintf(fid, '---\nInicio: %s\nAlgoritmo: %s (config %d)\n\n', timestamp, name, k);
        fprintf(fid, '%s\n', output_text);
        fprintf(fid, 'Resultado: lat = %.6f, lon = %.6f, valor = %.6f\n', x(1), x(2), fval);
        fprintf(fid, 'Duración: %.2f segundos\n---\n\n', duration);
        fclose(fid);

        % Save convergence plot if available
        if evalin('base', 'exist(''bestf_history'', ''var'')')
            bestf = evalin('base', 'bestf_history');
            figure;
            plot(bestf, 'LineWidth', 2);
            xlabel('Iteración'); ylabel('Mejor valor de la función objetivo');
            title(sprintf('Convergencia de %s - Configuración %d', name, k));
            grid on;

            % Ensure directory exists
            if ~exist('Imagenes', 'dir'), mkdir('Imagenes'); end
            filename = sprintf('Imagenes/convergencia_%s_%d.png', name, k);
            exportgraphics(gcf, filename, 'Resolution', 300);
            close(gcf);
        end
    end
end


% === Tracking Functions ===
function [state, options, optchanged] = ga_tracker_inline(options, state, flag)
    optchanged = false;
    persistent hist all_points;
    switch flag
        case 'init', hist = []; all_points = [];
        case 'iter', hist(end+1) = state.Best(end); all_points = [all_points; state.Population];
        case 'done'
            assignin('base', 'bestf_history', hist);
            assignin('base', 'evaluated_points', all_points);
    end
end

function stop = pso_tracker_inline(optimValues, state)
    stop = false;
    persistent hist all_points;
    switch state
        case 'init', hist = []; all_points = [];
        case 'iter', hist(end+1) = optimValues.bestfval; all_points = [all_points; optimValues.bestx];
        case 'done'
            assignin('base', 'bestf_history', hist);
            assignin('base', 'evaluated_points', all_points);
    end
end

function [stop, options, optchanged] = sa_tracker_inline(options, optimvalues, flag)
    stop = false; optchanged = false;
    persistent hist all_points;
    switch flag
        case 'init', hist = []; all_points = [];
        case 'iter', hist(end+1) = optimvalues.fval; all_points = [all_points; optimvalues.x];
        case 'done'
            assignin('base', 'bestf_history', hist);
            assignin('base', 'evaluated_points', all_points);
    end
end

