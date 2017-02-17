clear all;
wsize = 64;
XX = wsize;
YY = wsize;
NX = 1;
NY = 1;
NN = 1000;
n_overlap = 2;
d_overlap_cells = 1;

snr = 1;

KK = NX*NY*n_overlap;
FF = XX.*YY;


root_name = ['ov', num2str(n_overlap), '_sz', num2str(wsize), '_f', num2str(NN), '_k', num2str(KK), '_snr', num2str(snr), 'd_ovcel', num2str(d_overlap_cells)];
save_tiff = [root_name,'.tif'];
save_mat = [root_name,'.mat'];


w=[];
for ii=1:NX
    for jj=1:NY
        for oo=1:n_overlap
            mux = floor(XX./(NX+1)).*ii + (oo-1).*d_overlap_cells;
            muy = floor(YY./(NY+1)).*jj;% + (oo-1).*d_overlap_cells;
            %sigm1 = 2.0;
            %sigm2 = 1.5;
            sigm1 = 4.0;
            sigm2 = 3.0;
            k = ii.*NY +jj;
            theta = pi/2.*(oo-1);
            gf = gauss_fn(XX,YY,mux,muy,sigm1,sigm2,theta,40,0);
            tw = reshape(gf,FF,1);
            w = [w,tw];
        end
    end 
end

sigAmp = max(max(w));
noiseVar = (sqrt(sigAmp)/snr).^2;

gf = gauss_fn(XX,YY,XX./2,YY./3,300,300,0,1000,0);
wb = reshape(gf,FF,1);

%firing rate 1Hz (fr=0.02)
h = time_sq(KK,NN,0.02,1,5,1);

hb = ones(1,NN);
vv=w*h+wb*hb;

MV =[];
for n=1:NN
   TM = reshape(vv(:,n),XX,YY);
   %VTM = poissrnd(TM);
   %VTM = sqrt(sigAmp).*randn(size(TM)) + TM;
   VTM = sqrt(noiseVar).*randn(size(TM)) + TM;
   MV = cat(3,MV,VTM);
end

%figure(4);
imwrite(uint16(MV(:,:,1)),save_tiff,'tif');
for n = 2:NN
    imagesc(MV(:,:,n));
    axis image;
    colormap(gray);
    drawnow;
    imwrite(uint16(MV(:,:,n)),save_tiff,'tif','writemode','append');
end

save(save_mat,'w','h','wb','hb');
