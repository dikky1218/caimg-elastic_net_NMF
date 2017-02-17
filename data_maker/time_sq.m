function [ h ] = time_sq(KK,NN,fr,Amp,tau,dt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

h = [];
th = zeros(KK,1);
for n=1:NN
    In = Amp.*(rand(KK,1) < fr).*tau./dt;
    dh = (-th + In)./tau;
    th = th + dt.*dh;
    h = [h, th];
end

end

