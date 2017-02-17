

function []=movie_maker(V, width, height, file_name)

sizeV = size(V);
NN = sizeV(2); 
IMG = zeros(height, width, 1, NN);

for k = 1:NN
    frame = reshape(V(:,k), height, width);
    gray_scaled_f = mat2gray(frame);
    IMG(:,:,1,k) = gray_scaled_f;
end

vw = VideoWriter(file_name);
vw.FrameRate=30;

open(vw);
writeVideo(vw, IMG);
close(vw);

strcat('movie is saved : ', file_name)
