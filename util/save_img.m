
function [] = save_img(fig, filename)

width = 14;
height = 10;

%fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 width height];

fig.PaperSize = [width height];

print(fig, filename, '-dpng');
