function [high_cut_V, rPV] = high_cut_filter(argV)

V=argV;
sizeV = size(V);
FF = sizeV(1);
NN = sizeV(2);

PV = zeros(FF, NN);
Y = zeros(FF, NN);

for i=1:FF
    Y(i,:)=fft(V(i,:));
    PV(i,:)=abs(Y(i,:));
end


aveP = mean(PV,1);
mAveP = zeros(1,NN);

base_n=150;
%startF=180;
%mAveP(startF:base_n) = aveP(startF:base_n);
%x=[1:NN];
%[sortedP, Psorted_idx]=sort(mAveP, 'descend');
%
%cut_n = 10;

for i=1:FF
    %smoothing
    %for k=1:cut_n
    %    idx = Psorted_idx(k);
    %    Y(i,idx) = (Y(i,idx-20)+Y(i,idx+20))./2;
    %    PV(i,idx) = (PV(i,idx-20)+PV(i,idx+20))./2;
    %end

    %low pass filter
    Y(i,(base_n+1):NN) = zeros(1,(NN-base_n));

    V(i,:)=ifft(Y(i,:));
end

rPV=PV;
V=abs(V);
V=max(V,0);
high_cut_V = V;
