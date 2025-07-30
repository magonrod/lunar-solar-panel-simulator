function eta = efficiency(params, T)
    eta = params.eta_ref * (1 - params.beta_ref * (T - params.T_ref));
end
