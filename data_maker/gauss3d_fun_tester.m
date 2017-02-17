clear all;

cube_size = 16;

%data3d = gauss3d_fun(cube_size, cube_size, cube_size, 12, 12, 12, 7, 5, 4, 0, 0, 0, 1, 0.3);
theta1 = pi/2.*randn(1,1);
theta2 = pi/2.*randn(1,1);
theta3 = pi/2.*randn(1,1);
data3d = gauss3d_fun(cube_size, cube_size, cube_size, 8, 8, 8, 2, 1, 1.5, theta1, theta2, theta3, 1, 0.3);


n_gridpoints = cube_size*cube_size*cube_size;
plotXvec = zeros(n_gridpoints,1);
plotYvec = zeros(n_gridpoints,1);
plotZvec = zeros(n_gridpoints,1);
col_vec = zeros(n_gridpoints,1);

i=1;

for zi=[1:cube_size]
    for yi=[1:cube_size]
        for xi=[1:cube_size]
            plotXvec(i) = xi;
            plotYvec(i) = yi;
            plotZvec(i) = zi;
            col_vec(i) = data3d(xi,yi,zi);

            i=i+1;
        end
    end
end

figure();
%scatter3(plotXvec, plotYvec, plotZvec, 1, col_vec, 'filled');

%xslice = [cube_size/2 cube_size cube_size/4]; 
%yslice = [cube_size cube_size/4];
%zslice = ([0 cube_size/4]);
%slice(1:cube_size,1:cube_size,1:cube_size, data3d, xslice, yslice, zslice);

xslice = [1:0.1:cube_size]; 
yslice = [];
zslice = [];
%contourslice(1:cube_size,1:cube_size,1:cube_size, data3d, xslice, yslice, zslice);
%contourslice(data3d, xslice, yslice, zslice);
p = patch(isosurface(data3d));
isonormals(data3d, p);
p.FaceColor='blue';
p.EdgeColor='none';
%daspect([1,1,1]);
view(3);
axis([0 cube_size 0 cube_size 0 cube_size]);
camlight;
lighting gouraud;
