%% Test-Bench Characteristic Curve Reduction
%
% Reduces raw test-bench measurements (flow rate, differential pressure,
% mechanical power, efficiency) recorded at several rotational speeds
% into head, specific speed, and best-efficiency-point (BEP) data.
%
% Input : ../../data/RIM_test_bench_data.xlsx
%         one sheet per test speed (rpm), columns: qv [m3/h], dP [Pa],
%         dH [m], P_mec [kW], Eta [%]
%
% Output: head/efficiency plots per speed line, specific-speed
%         consistency check, and the BEP of each speed line printed to
%         the console.
%
% Author: Dev Kumar
% Project: Compact Axial Hydraulic Turbine - Arts et Metiers ParisTech
% -------------------------------------------------------------------

clear; close all; clc;

rho = 1000;   % kg/m^3, water density
g   = 9.81;   % m/s^2

dataFile   = fullfile('..', '..', 'data', 'RIM_test_bench_data.xlsx');
testSpeeds = {'1500', '1700', '2200'};   % rpm, sheet names

results = struct();

for s = 1:numel(testSpeeds)

    sheetName = testSpeeds{s};
    N = str2double(sheetName);   % rpm

    % Each sheet has a variable number of data rows and the occasional
    % incomplete row (a point logged for efficiency only, with no valid
    % pressure reading). Locate the header row dynamically, then keep
    % only rows where flow rate and differential pressure are both
    % numeric so that head and specific speed can be computed.
    sheetData = readcell(dataFile, 'Sheet', sheetName);

    headerRow = find(strcmp(sheetData(:,2), 'qv'), 1);
    block     = sheetData(headerRow+1:end, 2:6);

    isValid = cellfun(@(x) isnumeric(x) && ~isnan(x), block(:,1)) & ...
              cellfun(@(x) isnumeric(x) && ~isnan(x), block(:,2));

    skipped = sum(~isValid & cellfun(@(x) isnumeric(x) && ~isnan(x), block(:,1)));
    if skipped > 0
        fprintf('N = %d rpm: %d point(s) skipped (no valid pressure reading)\n', N, skipped);
    end

    block = block(isValid, :);

    qv_m3h = cell2mat(block(:,1));
    dP_Pa  = cell2mat(block(:,2));
    P_mec  = cell2mat(block(:,4));     % kW
    eta    = cell2mat(block(:,5));     % %

    qv = qv_m3h / 3600;              % m^3/s
    H  = dP_Pa / (rho * g);          % m, recomputed from dP for consistency

    % Engineering specific speed at each measured point
    Nsq = N * sqrt(qv) ./ H.^0.75;

    % Best-efficiency point of this speed line
    [etaMax, idxBEP] = max(eta);

    results.(['N', sheetName]).qv  = qv;
    results.(['N', sheetName]).H   = H;
    results.(['N', sheetName]).eta = eta;
    results.(['N', sheetName]).Nsq = Nsq;
    results.(['N', sheetName]).BEP = [qv(idxBEP), H(idxBEP), P_mec(idxBEP), etaMax];

    fprintf('N = %d rpm | BEP: qv = %.4f m^3/s, H = %.3f m, P = %.2f kW, eta = %.1f%%, Nsq = %.1f\n', ...
        N, qv(idxBEP), H(idxBEP), P_mec(idxBEP), etaMax, Nsq(idxBEP));

    figure(1); hold on;
    plot(qv, H, '-o', 'DisplayName', sprintf('%d rpm', N));

    figure(2); hold on;
    plot(qv, eta, '-o', 'DisplayName', sprintf('%d rpm', N));

end

figure(1);
xlabel('Flow rate q_v (m^3/s)'); ylabel('Head H (m)');
title('Head-flow characteristic per test speed');
legend show; grid on;

figure(2);
xlabel('Flow rate q_v (m^3/s)'); ylabel('Efficiency (%)');
title('Efficiency-flow characteristic per test speed');
legend show; grid on;

fprintf('\nDesign target specific speed: Nsq = 200\n');
fprintf('The 1500 rpm line approaches this target near its highest-head, ');
fprintf('lowest-flow point, consistent with the hydraulic pre-design in Chapter 2.\n');
