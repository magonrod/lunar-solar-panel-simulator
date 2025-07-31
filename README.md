# Lunar Solar Panel Simulator

A MATLAB-based tool for simulating and optimizing the positioning of solar panels on the Moon. This simulator estimates solar energy generation over time at a given lunar location, accounting for shadowing, thermal conditions and the Sun's motion. It also includes a module for optimizing panel positioning to maximize energy yield during a mission period.

## Features

- Simulation of solar energy yield based on time, position, and environmental conditions
- Shadow analysis and thermal modeling for realistic performance estimation
- Optimization module for panel placement (experimental, currently slow)
- Modular structure for integrating terrain data or mission-specific inputs

## Use Cases

- Lunar mission planning and rover energy budgeting
- Academic research in extraterrestrial energy systems
- Visualization of solar availability in different lunar regions

## More information and contact

- For a more comprehensive explanation of the operationS, hypotesis and limitations, check docs/
- This is my first project on github, so if you have questions, suggestions, or feedback, feel free to reach out: glezrodriguezmaria@gmail.com

## How to use

The main code is located in the src folder, and the folder structure must remain unchanged.
To run the simulation:

- Open main.m.
- Execute the file. A pop-up window will appear displaying the input interface.
- Modify the values as needed.

If you prefer not to use the graphical interface (GUI), you can disable it by setting the appropriate flag on line 9 of main.m, then manually edit the input values in the subsequent lines.
The current version of the code calculates estimated energy output based on the model described in the /docs folder.

## Upcoming Features

- Test scripts for validating results across different dates (to account for variations in solar altitude).
- Inclusion of a DEM (Digital Elevation Model) file.
- Improve speed and scalability of optimization
- Integration with external simulation frameworks
- Add orientation configurations and optimization
