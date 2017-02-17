function [ F2 ] = binning(F,bs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[w h T] = size(F);

F2 = [];
flt = ones(bs,bs);
for k=1:T
    MT = conv2(F(:,:,k),flt,'same');
    F2 = cat(3,F2,MT(1:bs:(w-bs+1),1:bs:(h-bs+1)));
end

end

