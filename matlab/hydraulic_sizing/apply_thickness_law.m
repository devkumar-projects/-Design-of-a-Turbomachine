function [xp1, yp1, xp2, yp2] = apply_thickness_law(xx, yy, beta_i, relThickness)
%APPLY_THICKNESS_LAW  Distribute a modified NACA thickness law about a
%mean line to build the pressure- and suction-side envelopes.
%
%   [XP1, YP1, XP2, YP2] = APPLY_THICKNESS_LAW(XX, YY, BETA_I, RELTHICKNESS)
%
%   Inputs
%     xx           - normalised mean-line abscissae (0 to 1)
%     yy           - mean-line ordinates at xx
%     beta_i       - local blade angle at xx [deg]
%     relThickness - relative thickness (t/c) of the section
%
%   Outputs
%     xp1, yp1 - pressure-side (or suction-side) point coordinates
%     xp2, yp2 - the complementary surface
%
%   The polynomial coefficients below were obtained by fitting a
%   thickened NACA-type law to XFoil section data using MATLAB's
%   fminsearch (see fit_naca_thickness.m for the identification
%   routine). They replace the standard NACA00xx coefficients to give
%   a thicker, structurally more robust trailing region.

naca = [0.2947, -0.1129, -0.3719, 0.3214, -0.0981];

yt = relThickness / 0.2 * ( naca(1) * xx.^0.5 ...
                           + naca(2) * xx      ...
                           + naca(3) * xx.^2    ...
                           + naca(4) * xx.^3    ...
                           + naca(5) * xx.^4 );

chord = (xx(end)^2 + yy(end)^2)^0.5;

xp1 = xx - chord * yt .* sind(beta_i);
yp1 = yy + chord * yt .* cosd(beta_i);

xp2 = xx + chord * yt .* sind(beta_i);
yp2 = yy - chord * yt .* cosd(beta_i);

xp1 = xp1 / chord; yp1 = yp1 / chord;
xp2 = xp2 / chord; yp2 = yp2 / chord;

end
