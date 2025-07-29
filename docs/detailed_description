Simulator Development

The simulator’s objective function estimates the energy output based on:

* Instantaneous solar irradiance $I$
* Panel area $A$
* Solar panel efficiency $\eta_{\text{panel}}$
* Illumination or shadow function $S(x, y, t)$ at a given position and time

The annual energy estimate is calculated by summing the energy produced in one-hour time steps $t$ at a fixed position $(x, y)$:

$$
E = \sum_{t=t_0}^{t_f} I \cdot A_p \cdot \eta_{\text{panel}}(T(\gamma_s)) \cdot S(x, y, t)
$$

---

### Shadow Module

#### Lunar Topography (2D)

The shadow cast by point **B** on point **A** is computed considering their heights and the solar altitude angle $\gamma$.

* Point B blocks sunlight to A if its height $H_B$ exceeds a critical height $H_C$ calculated by:

$$
H_C = H_A + \tan(\gamma) \cdot \text{distance}_{AB}
$$

* The Moon’s curvature is neglected between points A and B (assumed flat), which can introduce errors for distant points.

To correct this, an apparent height difference $H_{\text{apparent}}$ is added:

$$
H_{\text{apparent}} = \text{distance}_{AB} \cdot \sin\left(\tan^{-1}\left(\frac{\text{distance}_{AB}}{R}\right)\right) - R
$$

where $R$ is the Moon’s radius.

* The point A is in shadow if:

$$
H_B > H_C + H_{\text{apparent}}
$$

* To limit calculations, a comparison radius of 260 km is used based on lunar topography extrema.

---

#### Solar Altitude Angle

The solar altitude angle $\gamma_s$ is:

$$
\gamma_s = \arcsin\left(\sin(\lambda_s) \sin(\lambda_A) + \cos(\lambda_s) \cos(\lambda_A) \cos(\phi_A - \phi_s)\right)
$$

where

* $\lambda_A, \phi_A$: longitude and latitude of point A
* $\lambda_s, \phi_s$: longitude and latitude of the subsolar point

---

#### Subsolar Point Coordinates

* Latitude $\lambda_s$ (solar declination) approximated by:

$$
\lambda_s = \delta = 1.54 \sin\left(\frac{360n - 81}{354.36707}\right)
$$

* Longitude $\phi_s$:

$$
\phi_s = \lambda_0 - 12.19 \times t_{\text{days}}
$$

with $\lambda_0 = -125^\circ$ to adjust correctly, and $t_{\text{days}}$ the elapsed days.

---

#### Illumination Conditions

Point A is illuminated if:

* Solar altitude $\gamma_s > 0$
* All terrain elevations within 260 km in the solar azimuth direction are below the critical + apparent elevations

The illumination function is:

$$
F = f_s(\lambda_A, \phi_A, t) \cdot f_t(\lambda_A, \phi_A, H_A; \lambda_B, \phi_B, H_B, t)
$$

where

$$
f_s(\lambda_A, \phi_A, t) = \begin{cases}
1 & \gamma_s > 0 \\
0 & \text{otherwise}
\end{cases}
$$

and

$$
f_t(\lambda_A, \phi_A, H_A; \lambda_B, \phi_B, H_B, t) = \begin{cases}
0 & H_B \geq H_{\text{critical}} + H_{\text{apparent}} \\
1 & \text{otherwise}
\end{cases}
$$

---

### Temperature Module

The lunar surface temperature $T$ is estimated with a radiative energy balance:

$$
T = \left(\frac{\alpha \cdot I \cdot \cos(\theta_z)}{\varepsilon \cdot \sigma}\right)^{1/4}
$$

where:

* $\alpha \approx 0.85$ — lunar soil absorptivity
* $I \approx 1361\, W/m^2$ — solar constant
* $\theta_z = 90^\circ - \gamma_s$ — solar zenith angle
* $\varepsilon \approx 0.94$ — infrared emissivity of lunar soil
* $\sigma = 5.6704 \times 10^{-8} W m^{-2} K^{-4}$ — Stefan–Boltzmann constant

---

### Efficiency Module

Panel efficiency $\eta_{\text{panel}}$ varies linearly with temperature:

$$
\eta_{\text{panel}} = \eta_{\text{ref}} \cdot \big(1 - \beta_{\text{ref}}(T - T_{\text{ref}})\big)
$$

Parameters for the "Triple-Junction Solar Cell for Space Applications (CTJ30)" panel:

| Parameter                                    | Value        |
| -------------------------------------------- | ------------ |
| Reference efficiency $\eta_{\text{ref}}$     | 0.29         |
| Temperature coefficient $\beta_{\text{ref}}$ | 0.1962 % / K |
| Reference temperature $T_{\text{ref}}$       | 298.15 K     |

---

### Radiation Module

Solar radiation on the Moon is assumed constant:

$$
I = 1361\, W/m^2
$$

since there is no atmosphere to attenuate sunlight.

