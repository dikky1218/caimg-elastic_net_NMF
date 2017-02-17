function [r_W, r_H, r_wb] = initNMF3d(gpu_mode, loopN, KK, sps_params, V4d)

FWidth = size(V4d, 1);
FHeight = size(V4d, 2);
FDepth = size(V4d, 3);
TT = size(V4d, 4);
FF = FWidth.*FHeight;

V2dMat = [];
for t=1:TT
    v3dFrame = V4d(:,:,:,t);
    frame = reshape(mean(v3dFrame, 3), FF,1);
    V2dMat = cat(2, V2dMat, frame);
end

%for debug
%loopN = 50;

[V, W, H, wb, hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = enNMF(gpu_mode, loopN, V2dMat, KK, sps_params, false, '', [], [], []);

%wsize = FWidth;
%root_fname= 'sz3d16_f1000_k8_snr10';
%output_result(loopN, V, W, H, wb, hb, KK, wsize, wsize, root_fname, sps_params, objs);

%copy the 2d frame in z axis direction.
r_W = [];
r_wb = [];
r_H = H;
for d=1:FDepth
    r_W = cat(1, r_W, W);
    r_wb = cat(1, r_wb, wb);
end

