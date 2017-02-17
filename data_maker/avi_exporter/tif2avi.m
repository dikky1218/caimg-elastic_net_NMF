
function y=tifplayer(load_name)

%load_name = './f1000df200t2000.tif';
%load_name = '../real_data/92min_soma21_sine2_019.TIF';


info = imfinfo(load_name); 

NN = size(info,1); 
FF = info(1,1).Height*info(1,1).Width;
IMG = zeros(info(1,1).Height,info(1,1).Width,1,NN);



for k = 1:NN 
    frame = imread(load_name,'Tiff',k);
    IMG(:,:,1,k) = mat2gray(frame);
end

savefile=strcat(load_name,'.avi')

vw = VideoWriter(savefile);
vw.FrameRate=30;

open(vw);
writeVideo(vw, IMG);
close(vw);

y=strcat('movie is saved : ', savefile)
