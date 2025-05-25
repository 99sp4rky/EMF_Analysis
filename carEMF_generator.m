%% RESOLUTION CONTROL
theta_res = 90;     % was 180
phi_res = 180;      % was 360

%% Spherical Grid
theta = linspace(0, pi, theta_res);       % elevation
phi = linspace(0, 2*pi, phi_res);         % azimuth
[TH, PH] = meshgrid(theta, phi);
A = sin(TH).^2;

%% Cartesian Conversion
r = A;
X = r .* sin(TH) .* cos(PH);
Y = r .* sin(TH) .* sin(PH);
Z = r .* cos(TH);

%% Vertices
vertices = [X(:), Y(:), Z(:)];

%% Build face list
rows = size(X, 1);
cols = size(X, 2);
faces = [];

for i = 1:rows-1
    for j = 1:cols-1
        % Calculate linear indices of quad corners
        v1 = sub2ind([rows, cols], i, j);
        v2 = sub2ind([rows, cols], i+1, j);
        v3 = sub2ind([rows, cols], i+1, j+1);
        v4 = sub2ind([rows, cols], i, j+1);

        % Split quad into 2 triangles
        faces(end+1, :) = [v1, v2, v3];
        faces(end+1, :) = [v1, v3, v4];
    end
end

%% Colors from Amplitude
amplitude = A(:);
amplitude = (amplitude - min(amplitude)) / (max(amplitude) - min(amplitude));
R = round(255 * amplitude);
G = zeros(size(R));
B = round(255 * (1 - amplitude));

%% Write PLY
filename = 'dipole_fixed_optimized.ply';
fid = fopen(filename, 'w');
fprintf(fid, 'ply\nformat ascii 1.0\n');
fprintf(fid, 'element vertex %d\n', size(vertices,1));
fprintf(fid, 'property float x\nproperty float y\nproperty float z\n');
fprintf(fid, 'property uchar red\nproperty uchar green\nproperty uchar blue\n');
fprintf(fid, 'element face %d\n', size(faces,1));
fprintf(fid, 'property list uchar int vertex_index\n');
fprintf(fid, 'end_header\n');

for i = 1:size(vertices,1)
    fprintf(fid, '%f %f %f %d %d %d\n', ...
        vertices(i,1), vertices(i,2), vertices(i,3), R(i), G(i), B(i));
end
for i = 1:size(faces,1)
    fprintf(fid, '3 %d %d %d\n', ...
        faces(i,1)-1, faces(i,2)-1, faces(i,3)-1);  % 0-based indexing
end
fclose(fid);
