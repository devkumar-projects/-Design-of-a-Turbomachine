function [yy, beta_i] = blade_mean_line(beta_1, beta_2, xx)
%BLADE_MEAN_LINE  Unit-chord mean line of a blade section.
%
%   [YY, BETA_I] = BLADE_MEAN_LINE(BETA_1, BETA_2, XX) returns the
%   mean-line ordinates YY and the local blade angle BETA_I for a
%   section whose inlet angle is BETA_1 and outlet angle is BETA_2,
%   sampled at the normalised chordwise abscissae XX (0 to 1).
%
%   The local tangent is assumed to vary linearly between the inlet
%   and outlet angles:
%       dyy/dx = (tan(beta_2) - tan(beta_1)) * x + tan(beta_1)
%   which integrates to a parabolic mean line.
%
%   Inputs
%     beta_1 - blade inlet angle [deg]
%     beta_2 - blade outlet angle [deg]
%     xx     - normalised chordwise abscissae, 0 <= xx <= 1
%
%   Outputs
%     yy     - mean-line ordinates (same size as xx)
%     beta_i - local blade angle at each xx [deg]

dyy = (tand(beta_2) - tand(beta_1)) .* xx + tand(beta_1);
yy  = 0.5 * (tand(beta_2) - tand(beta_1)) .* xx.^2 + tand(beta_1) .* xx;

beta_i = atand(dyy);

end
