%% Modified NACA Thickness-Law Identification
%
% Standard NACA00xx sections were found to be too thin for the intended
% prototype and its structural constraints. This script fits a thicker
% analytical thickness law to XFoil-exported section points using an
% unconstrained least-squares search (fminsearch), and reports the
% resulting polynomial coefficients used throughout the sizing pipeline
% (see apply_thickness_law.m).
%
% Required input: an XFoil point-save ("psave") file for the reference
% section, e.g. NACA0015_DEV_KUMAR.txt.

clear; close all; clc;

sectionFile = 'NACA0015_DEV_KUMAR.txt';
relThickness = 0.15;   % relative thickness of the section being fitted

data = load(sectionFile);

figure; hold on; axis equal;
plot(data(:,1), data(:,2), 'b-');

% Upper surface only (first half of the XFoil point set)
nPts  = size(data, 1);
xdata = data(1:ceil(nPts/2), 1);
ydata = data(1:ceil(nPts/2), 2);
plot(xdata, ydata, 'g-');

% Standard NACA00xx thickness coefficients (baseline / initial guess)
naca_standard = [0.2969, -0.1260, -0.35116, 0.2843, -0.1015];

naca_thickness = @(coeffs, x) relThickness/0.2 * ( ...
    coeffs(1)*x.^0.5 + coeffs(2)*x + coeffs(3)*x.^2 + ...
    coeffs(4)*x.^3 + coeffs(5)*x.^4);

y0 = naca_thickness(naca_standard, xdata);
plot(xdata, y0, 'm-');

% Least-squares fit of the modified coefficients
sumSquaredError = @(coeffs) sum((ydata - naca_thickness(coeffs, xdata)).^2);
naca_modified = fminsearch(sumSquaredError, naca_standard);

disp('Modified NACA thickness coefficients:');
disp(naca_modified);

plot(xdata, naca_thickness(naca_modified, xdata), 'r*:');
legend('Raw XFoil points', 'Upper surface (fit data)', ...
       'Standard NACA00xx', 'Modified fit', 'Location', 'best');
xlabel('x / chord'); ylabel('y / chord');
title('Modified NACA thickness-law identification');
