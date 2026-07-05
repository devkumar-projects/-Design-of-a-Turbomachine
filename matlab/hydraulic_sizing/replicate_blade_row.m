function replicate_blade_row(sectionPoints, numBlades, rgb)
%REPLICATE_BLADE_ROW  Plot a full blade row by circumferential
%replication of a single projected section curve about the runner axis.
%
%   REPLICATE_BLADE_ROW(SECTIONPOINTS, NUMBLADES, RGB) rotates the
%   Nx3 array SECTIONPOINTS (axial, y, z) NUMBLADES times about the
%   x-axis and plots each copy in the colour RGB, reproducing the
%   circular-pattern operation later performed in CATIA V5 Part Design.
%
%   Inputs
%     sectionPoints - Nx3 array of [x, y, z] points for one blade curve
%     numBlades     - number of blades in the row
%     rgb           - 1x3 RGB colour triplet, e.g. [0 0 0]

hold on;
for k = 0:numBlades-1
    theta = 2*pi*k/numBlades;
    R = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
    rotated = (R * sectionPoints')';
    plot3(rotated(:,1), rotated(:,2), rotated(:,3), 'Color', rgb);
end

end
