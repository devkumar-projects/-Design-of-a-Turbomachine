%% Turbine Affinity-Law Scaling
%
% For a fixed-geometry runner operated at a different rotational speed,
% the flow rate, head, and power scale according to the standard
% turbomachinery affinity (similarity) laws:
%
%   qv2 / qv1 = N2 / N1
%   H2  / H1  = (N2 / N1)^2
%   P2  / P1  = (N2 / N1)^3
%
% This script takes a reference operating point from the test-bench
% data (see characteristic_curve_reduction.m) and projects it to a
% target speed N2, reproducing the reference scaling exercise recorded
% for the 1500 rpm test line.
%
% Author: Dev Kumar
% Project: Compact Axial Hydraulic Turbine - Arts et Metiers ParisTech
% -------------------------------------------------------------------

clear; close all; clc;

rho = 1000;
g   = 9.81;

% --- Reference operating point (1500 rpm test line, qv = 500 m3/h) ----
N1     = 1500;                 % rpm
qv1_h  = 500;                  % m^3/h
dP1    = 30100;                % Pa

qv1 = qv1_h / 3600;            % m^3/s
H1  = dP1 / (rho * g);         % m
P1  = rho * g * qv1 * H1 / 1000; % kW (hydraulic power, pre-efficiency)

fprintf('Reference point: N1 = %d rpm, qv1 = %.4f m^3/s, H1 = %.3f m, P1 = %.1f kW\n', ...
    N1, qv1, H1, P1);

% --- Target speed and scaled operating point --------------------------
N2 = 1732.0508;   % rpm, target speed

k   = N2 / N1;
qv2 = qv1 * k;
H2  = H1  * k^2;
P2  = P1  * k^3;

fprintf('Target point:    N2 = %.2f rpm, qv2 = %.4f m^3/s, H2 = %.3f m, P2 = %.1f kW\n', ...
    N2, qv2, H2, P2);

fprintf('\nScaled flow rate qv2 = %.2f m^3/h (reference value: 577.35 m^3/h)\n', qv2 * 3600);
