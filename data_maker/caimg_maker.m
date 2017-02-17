function [] = caimg_maker(original_matfname)
    wsize = 64;
    XX = wsize;
    YY = wsize;
    NX = 8;
    NY = 8;
    NN = 2000;
    
    snr = 0.018;
    
    KK = NX*NY;
    FF = XX.*YY;
    
    
    root_name = ['sz', num2str(wsize), '_f', num2str(NN), '_k', num2str(KK), '_snr', num2str(snr)];
    save_tiff = [root_name,'.tif'];
    save_mat = [root_name,'.mat'];
    
    %init matrices
    if isempty(original_matfname)
        w=[];
        for ii=1:NX
            for jj=1:NY
                mux = floor(XX./(NX+1)).*ii + ceil((rand(1,1)-0.5).*5);
                muy = floor(YY./(NY+1)).*jj + ceil((rand(1,1)-0.5).*5);
                %when sz=64
                sigm1 = 0.8;
                sigm2 = 1.28;
                %when sz=256
                %sigm1 = 3.2;
                %sigm2 = 5.12;
                k = ii.*NY +jj;
                theta = pi/2.*randn(1,1);
                gf = gauss_fn(XX,YY,mux,muy,sigm1,sigm2,theta,40,0);
                tw = reshape(gf,FF,1);
                w = [w,tw];
            end 
        end
        
        gf = gauss_fn(XX,YY,XX./2,YY./3,300,300,0,1000,0);
        wb = reshape(gf,FF,1);
        %firing rate 1Hz (fr=0.02)
        h = time_sq(KK,NN,0.02,1,5,1);
        hb = ones(1,NN);
    else
        load(original_matfname);
    end
    

    vv=w*h+wb*hb;
    

    %Add noise on the movie data.
    stdSig = mean(std(h, 0, 2));
    stdNoise = stdSig/snr;
    MV =[];
    for n=1:NN
       TM = vv(:,n);
       %VTM = poissrnd(TM);
       VTM = stdNoise.*randn(size(TM)) + TM;
       MV = cat(2,MV,VTM);
    end
    V=MV;
    
    save(save_mat, 'V', 'w','h','wb','hb');


