
result_mat_fname = '../../result/conclusion4/exp4_3dNMF/sz3d32_f1000_k64_snr10_K64_0.03_0.01_1.2_0_100loop_170118005257/sz3d32_f1000_k64_snr10_K64_0.03_0.01_1.2_0_100loop_W_H_wb_hb';

wsize = 32;
xsize = wsize;
ysize = wsize;
zsize = wsize;
KK = 64;


load(result_mat_fname, '-mat', 'W', 'H', 'wb', 'hb', 'objs', 'cc1_w', 'cc2_w', 'cc_h', 'accuracies', 'tcosts');

Ws=[];


figure();

for k=1:KK
    data3d = reshape(W(:,k), xsize, ysize, zsize);
    smooth3(data3d, 'gaussian');
    p = patch(isosurface(data3d));
    isonormals(data3d, p);
    p.FaceColor='blue';
    p.EdgeColor='none';
end

%daspect([1,1,1]);
view(3);
axis([0 wsize 0 wsize 0 wsize]);
camlight;
lighting gouraud;
