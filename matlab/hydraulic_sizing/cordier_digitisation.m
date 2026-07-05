%% Cordier Diagram Digitisation - Kaplan Branch
%
% The Kaplan-turbine region of the Cordier diagram was digitised point
% by point (Engauge Digitizer) from the reference chart and imported
% here to obtain a reproducible estimate of the specific radius, rather
% than a purely graphical reading.
%
% This script fits a local linear relation between the dimensionless
% specific angular velocity (Omega) and the specific radius (Rs) over
% the interval relevant to the design specific speed, then solves for
% the specific radius at the design point.

clear; close all; clc;

g = 9.81;
Nsq = 200;                          % engineering specific speed (design class)
Omega_design = pi * Nsq / (30 * g^0.75);

% Two reference points read from the digitised Kaplan branch
Rs1 = 0.2804; Omega1 = 9.224;
Rs2 = 1.31;   Omega2 = 1.987;

slope     = (Omega2 - Omega1) / (Rs2 - Rs1);
intercept = Omega1 - slope * Rs1;

% Solve Omega(Rs) = Omega_design for Rs
Rs_design = (Omega_design - intercept) / slope;

fprintf('Design specific angular velocity Omega = %.3f\n', Omega_design);
fprintf('Specific radius Rs = %.3f\n', Rs_design);

Rs_range = linspace(min(Rs1, Rs2), max(Rs1, Rs2), 50);
Omega_fit = slope * Rs_range + intercept;

figure;
loglog(Rs_range, Omega_fit, 'b-'); hold on;
loglog(Rs_design, Omega_design, 'ro', 'MarkerFaceColor', 'r');
xlabel('Specific radius R_s'); ylabel('Specific angular velocity \Omega');
title('Digitised Kaplan branch of the Cordier diagram');
legend('Linear fit (digitised data)', 'Selected design point', 'Location', 'best');
