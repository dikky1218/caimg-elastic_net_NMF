function [] = zslice_outputter(k,Wcolumn, Hrow, cube_size, file_name)

ncolumn=round(sqrt(cube_size));
nrow = round(sqrt(cube_size));

fig = figure('visible', 'off');
title(['k',num2str(k)]);

frame2dsize = cube_size^2;

%W
for z=1:cube_size
    RR = reshape(Wcolumn(((z-1)*frame2dsize+1):(z*frame2dsize)), cube_size, cube_size);
    subplot(nrow, ncolumn, z);
    imagesc(RR);
    title(['z:', num2str(z)])
end;

ROI_file_name = [file_name,'ROI_W', num2str(k)];
save_img(fig, ROI_file_name);

if k>0
    %H
    fig = figure('visible', 'off');
    title(['k',num2str(k)]);
    plot(Hrow);
    ROI_file_name = [file_name,'ROI_H', num2str(k)];
    save_img(fig, ROI_file_name);
end
