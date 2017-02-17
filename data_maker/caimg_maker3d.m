clear all;

wsize = 32;

XX = wsize;
YY = wsize;
ZZ = wsize;

NX = 4;
NY = 4;
NZ = 4;

NN = 1000;

snr = 10;

KK = NX*NY*NZ;
FF = XX.*YY.*ZZ;


root_name = ['sz3d', num2str(wsize), '_f', num2str(NN), '_k', num2str(KK), '_snr', num2str(snr)];
save_mat = [root_name,'.mat'];


w=[];
for ii=1:NX
    for jj=1:NY
        for kk=1:NZ
            cell_space = floor(XX./(NX+1));
            mux = cell_space.*ii + ceil((rand(1,1)-0.5).*cell_space/2);
            cell_space = floor(YY./(NY+1));
            muy = cell_space.*jj + ceil((rand(1,1)-0.5).*cell_space/2);
            cell_space = floor(ZZ./(NZ+1));
            muz = cell_space.*kk + ceil((rand(1,1)-0.5).*cell_space/2);

            sigm1 = 0.8;
            sigm2 = 1.28;
            sigm3 = 1.00;

            k = ii.*NY.*NZ + jj.*NZ + kk;

            theta1 = pi/2.*randn(1,1);
            theta2 = pi/2.*randn(1,1);
            theta3 = pi/2.*randn(1,1);

            data3d = gauss3d_fun(XX, YY, ZZ, mux, muy, muz, 2, 1, 1.5, theta1, theta2, theta3, 1, 0.3);

            %convert 3d to 1d.
            tw = reshape(data3d,FF,1);
            %2d matrix size: FF*KK
            w = [w,tw];
        end
    end 
end

gf = gauss3d_fun(XX, YY, ZZ, XX/2, YY/2, ZZ/2, 100, 100, 100, 0, 0, 0, 1, 0.3);
wb = reshape(gf,FF,1);

%firing rate 1Hz (fr=0.02)
h = time_sq(KK,NN,0.02,1,5,1);

hb = ones(1,NN);
vv=w*h+wb*hb;

%Add noise on the movie data.
stdSig = mean(std(h, 0, 2));
stdNoise = stdSig/snr;

V4d = [];
V2d = [];
for n=1:NN
   %4d
   V4dFrame  = reshape(vv(:,n),XX,YY,ZZ);
   noiseAddedV4d = stdNoise.*randn(size(V4dFrame)) + V4dFrame;
   V4d = cat(4,V4d,noiseAddedV4d);
   %2d
   V2dFrame  = vv(:,n);
   noiseAddedV2d = stdNoise.*randn(size(V2dFrame)) + V2dFrame;
   V2d = cat(2,V2d,noiseAddedV2d);
end

v=vv;%2d matrix without noise

save(save_mat,'V4d', 'V2d', 'v', 'w','h','wb','hb');
