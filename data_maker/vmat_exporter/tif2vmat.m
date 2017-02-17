
function [rV]=saveVmat(filename, bs, wiener_filter, highcut_filter)

info = imfinfo(filename);
wsize_h = info(1,1).Height/bs;
wsize_w = info(1,1).Width/bs;

TT = size(info,1);
FF = wsize_w * wsize_h;


V = [];
IMG = zeros(info(1,1).Height,info(1,1).Width,TT);

% loading the movie.
for k = 1:TT
    IMG(:,:,k) = imread(filename,'Tiff',k);
end

IMG = double(IMG);

% binning 
if bs > 1
    IMG2 = binning(IMG,bs);
else
    IMG2 = IMG;
end

%create V.
for k = 1:TT
    if wiener_filter
        IMG2(:,:,k) = wiener2(IMG2(:,:,k),[3,3]);
    end
    TM = reshape(IMG2(:,:,k),FF,1);
    V = cat(2,V,TM);
end

if highcut_filter
    V = highcut_filter(V);
end

save(strcat(filename,'.mat'), 'V', '-v7.3');
rV=V;
