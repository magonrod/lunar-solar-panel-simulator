# Simulation Assumptions and Limitations

This document describes the physical assumptions, simplifications, and constraints used in the lunar solar panel simulator.

## Physical Assumptions

- Solar irradiance is assumed to be constant at 1361 W/m² at lunar distance.

## Thermal Modeling

- Thermal losses are estimated using a simple linear decay model based on simulated shadow time.
- No detailed thermal inertia or regolith interaction is modeled.

## Optimization Module (WIP)

- Currently slow for large grids; future work will integrate gradient-based or heuristic search.

## Limitations

- Simulations assume perfect panel efficiency without degradation over time.
- No atmospheric effects are modeled (Moon has none, but included for future Mars extension).
