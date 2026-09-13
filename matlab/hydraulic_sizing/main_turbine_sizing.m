%% Axial Hydraulic Turbine - Preliminary Hydraulic and Blade-Row Sizing
%
% Pipeline:
%   1) Similarity-based sizing using the Cordier diagram (specific speed /
%      specific radius) to fix the operating point and runner envelope.
%   2) Radial distribution of velocity triangles (blade speed, whirl
%      component, inlet/outlet/discharge angles) between hub and tip.
%   3) Blade mean-line construction from the local inlet/outlet angles.
%   4) Thickness distribution using a modified NACA law (see
%      fit_naca_thickness.m), scaled by radial solidity.
%   5) 3-D point-cloud generation and export to a CATIA V5 Generative
%      Shape Design "Point/Spline/Loft from Excel" macro.
%
% Author: Dev Kumar
% Project: Compact Axial Hydraulic Turbine - Arts et Metiers ParisTech
% -------------------------------------------------------------------

clear; close all; clc;

% Resolve helper functions and generated files relative to this script.
scriptDirectory = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDirectory));
outputDirectory = fullfile(repoRoot, 'outputs');
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end
addpath(scriptDirectory);

turbineName = 'axial_kaplan_turbine';

%% Constants
g = 9.81; % m/s^2

%% -----------------------------------------------------------------
%  Design brief
%  -----------------------------------------------------------------
N   = 1500;         % rpm, rotational speed
Re  = 0.103;        % m, penstock / runner outer radius
Nsq = 200;           % engineering specific speed (design target class)

omega = N * 2 * pi / 60;                  % rad/s
vas   = Nsq * 2 * pi / 60 / g^0.75;        % dimensionless specific angular velocity

%% -----------------------------------------------------------------
%  Cordier-diagram sizing
%  -----------------------------------------------------------------
% Specific radius read from the digitised Kaplan branch of the Cordier
% diagram (see docs/cordier_digitisation.m for the interpolation).
Lambda = 0.701;

% Graphical solution for the design head H: intersect the two relations
%   vas   = omega * sqrt(qv) / (g*H)^0.75
%   Lambda = Re * (g*H)^0.25 / sqrt(qv)
H_scan = 0.1:0.1:10;
residual = vas / omega * (g * H_scan).^0.75 - Re / Lambda * (g * H_scan).^0.25;

figure('Name', 'Design head - graphical solution');
plot(H_scan, residual, 'b'); hold on;
yline(0, 'k-');
xlabel('H (m)'); ylabel('Residual');
title('Graphical solution used to fix the design head');

H = 3.8;                          % m, selected design head
[~, graphicalIndex] = min(abs(residual));
graphicalHead = H_scan(graphicalIndex);
if abs(H - graphicalHead) > 0.2
    warning('Turbine:HeadMismatch', ...
        'Selected head %.3f m differs from graphical solution %.3f m.', ...
        H, graphicalHead);
end
qv = (Nsq * H^0.75 / N)^2;        % m^3/s, corresponding flow rate

fprintf('Design head H = %.2f m\n', H);
fprintf('Design flow rate qv = %.4f m^3/s\n', qv);

%% -----------------------------------------------------------------
%  Runner envelope and radial discretisation
%  -----------------------------------------------------------------
Za  = 6;      % number of blades
eta = 0.92;   % target hydraulic efficiency
T   = 0.38;   % hub-to-tip ratio Ri/Re

Ri = floor(1000 * Re * T) / 1000;   % hub radius, rounded to the mm
fprintf('Re = %.4f m, Ri = %.4f m\n', Re, Ri);

nr = 5;                              % number of radial sections
r  = floor(1000 * linspace(Ri, Re, nr)) / 1000;

%% -----------------------------------------------------------------
%  Velocity triangles and blade-row construction
%  -----------------------------------------------------------------
Ca = qv / (pi * (Re^2 - Ri^2));      % axial velocity component, m/s
fprintf('Axial velocity Ca = %.3f m/s\n', Ca);

XXX.ext = struct('R', {});
XXX.int = struct('R', {});

fprintf('\n%8s %10s %10s %10s\n', 'r [m]', 'beta_1', 'beta_2', 'alpha_2');

for u = 1:numel(r)

    % --- Local velocity triangle -----------------------------------
    U        = omega * r(u);
    Cu2_th   = -g * H / U;      % Euler relation (theoretical whirl)
    Cu2      = Cu2_th * eta;    % corrected for hydraulic efficiency

    beta_1  = atand(U / Ca);
    beta_2  = atand((U - Cu2) / Ca);
    alpha_2 = atand(Ca / Cu2);

    fprintf('%8.4f %10.4f %10.4f %10.4f\n', r(u), beta_1, beta_2, alpha_2);

    % --- Mean-line construction --------------------------------------
    xba = [0, logspace(-6, -2, 10)];  % refined leading-edge region
    xmc = linspace(0.011, 0.1, 9);    % mid-chord region
    xbf = linspace(0.11, 1, 9);       % trailing-edge region
    xx  = [xba, xmc, xbf];

    [yy, beta_i] = blade_mean_line(beta_1, beta_2, xx);

    figure(10); hold on;
    plot(xx, yy, 'r'); axis equal;
    xlabel('x / chord'); ylabel('y / chord');
    title('Unit-chord blade mean lines');

    % --- Radial thickness law (hub-thick, tip-thin) -------------------
    thicknessHub = 0.13;
    thicknessTip = 0.03;
    relativeThickness = linspace(thicknessHub, thicknessTip, nr);

    figure(11); hold on;
    plot(r, relativeThickness);
    xlabel('r (m)'); ylabel('relative thickness');
    title('Radial thickness law');

    [xp1, yp1, xp2, yp2] = apply_thickness_law(xx, yy, beta_i, relativeThickness(u));
    xp1 = xp1'; yp1 = yp1';
    xp2 = xp2'; yp2 = yp2';

    % --- Row solidity and physical scaling -----------------------------
    solidity = 0.6;                     % chord-to-pitch ratio
    chord    = solidity * (2 * pi * r(u) / Za);

    xp1 = xp1 * chord; yp1 = yp1 * chord;
    xp2 = xp2 * chord; yp2 = yp2 * chord;

    % --- Cylindrical projection onto the runner surface -----------------
    zz  = ones(size(xx')) * r(u);
    the1 = yp1 ./ unique(zz);
    the2 = yp2 ./ unique(zz);

    XXext = zeros(numel(xx), 3);
    XXint = zeros(numel(xx), 3);

    XXext(:,1) = xp1;               XXint(:,1) = xp2;
    XXext(:,2) = r(u) * cos(the1);  XXint(:,2) = r(u) * cos(the2);
    XXext(:,3) = r(u) * sin(the1);  XXint(:,3) = r(u) * sin(the2);

    % --- Blade-row replication and visualisation ------------------------
    figure(12); hold on; axis equal; view(-30, 0);
    plot3(XXext(:,1), XXext(:,2), XXext(:,3), 'b');
    plot3(XXint(:,1), XXint(:,2), XXint(:,3), 'g');
    replicate_blade_row(XXext, Za, [0 0 0]);
    replicate_blade_row(XXint, Za, [1 0 0]);
    title('Full blade-row geometry');

    XXX.ext(u).R = XXext * 1000;    % mm, for CATIA export
    XXX.int(u).R = XXint * 1000;

end

%% -----------------------------------------------------------------
%  Export point cloud for CATIA V5 (Generative Shape Design)
%  -----------------------------------------------------------------
export_name = fullfile(outputDirectory, 'blade_sections_GSD.xlsx');
export_table = {'StartLoft', '', ''};

for u = 1:nr
    export_table = [export_table; {'StartCurve', '', ''}];
    for k = 1:size(XXX.ext(u).R, 1)
        export_table = [export_table; num2cell(XXX.ext(u).R(k, :))]; %#ok<AGROW>
    end
    export_table = [export_table; {'EndCurve', '', ''}];

    export_table = [export_table; {'StartCurve', '', ''}];
    for k = 1:size(XXX.int(u).R, 1)
        export_table = [export_table; num2cell(XXX.int(u).R(k, :))]; %#ok<AGROW>
    end
    export_table = [export_table; {'EndCurve', '', ''}];
end

export_table = [export_table; {'EndLoft', '', ''}; {'End', '', ''}];

writecell(export_table, export_name);
fprintf('\nBlade point cloud exported to %s\n', export_name);
fprintf('Import in CATIA V5 with GSD_PointSplineLoftFromExcel.xls\n');
