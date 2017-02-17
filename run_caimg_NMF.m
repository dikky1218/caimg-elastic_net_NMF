function [V,W,H] = run_caimg_NMF(init_V, v4d)
addpath(genpath('util'));
addpath(genpath('outputter'));
addpath(genpath('nmf'));
addpath(genpath('correlation'));


%real_data
%artf_data = false;
%root_fname = '212min_soma2_sine2_2048_091';
%root_fname = '92min_soma21_sine2_019';
%root_fname = '88min_soma20_sine1_018';
%root_fname = '113min_soma29_sine2_025';
%root_fname = '135min_apiden40_32_sine16_039';
%root_fname = '136min_apiden41_2048_sine1_040';
%root_fname = '147min_apiden49_2048_sine16_048';

%artificial data
artf_data = true;
overlap_data = false;
dim3_data = ~isempty(v4d);
%root_fname= 'sz64_f2000_k64_snr0018';
%root_fname= 'c729_image';
%root_fname= 'ov2_sz64_f1000_k2_snr1d_ovcel1';
root_fname= 'sz3d32_f1000_k64_snr10';
artf_data_matname = ['../artificial_data/', root_fname, '.mat'];

gpu_mode = true;
KK = 64;
wsize = 32;



%sps_params = [h_sps_a, h_sps_b, w_sps_a, w_sps_b];
%sps_params = [5*10^1, 0, 0.0050*10^10, 0];
%sps_params = [150, 0, 0.0025, 0];
%real data sparse parameters
%sps_params = [11*1e2, 0, 3000*1e4, 0];
%artificial data sparse parameters
%snr 1
%sps_params = [11, 0, 9000, 0];
%snr 0.5
%sps_params = [20, 0, 12000, 0];
%elastic net
%h sperseness parameters
best_hspsa = 0.1;
best_hspsb = 0;
h_spsness = 1;
h_sps_a = h_spsness.*best_hspsa;
h_sps_b = (1-h_spsness).*best_hspsb;
%w sperseness parameters
best_wspsa = 8000;
best_wspsb = 2000;
w_spsness = 0.5;
w_sps_a = w_spsness.*best_wspsa;
w_sps_b = (1-w_spsness).*best_wspsb;
%sps_params = [h_sps_a, h_sps_b, w_sps_a, w_sps_b];
%sps_params = [h_sps_a, h_sps_b, 30, 0];
%sps_params = [15, 0.3, 8000, 0];
%sps_params = [0, 0, 0, 0];
%for 3d data
sps_params = [0.03, 0.01, 1.2, 0];


loopN  = 100;

initW = [];
initH = [];
initWb = [];
if dim3_data
    %[initW, initH, initWb] = initNMF3d(gpu_mode, loopN, KK, sps_params, v4d);
end

[V, W, H, wb, hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = enNMF(gpu_mode, loopN, init_V, KK, sps_params, artf_data, artf_data_matname, initW, initH, initWb);
%[V, W, H, wb, hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = NMF(gpu_mode, loopN, init_V, KK, sps_params, artf_data, artf_data_matname);

if artf_data
    if dim3_data
        output_corr_result3d(loopN, V, W, H, wb, hb, KK, wsize, root_fname, sps_params, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts);
    else
        output_corr_result(loopN, V, W, H, wb, hb, KK, wsize, root_fname, sps_params, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts);
    end
else
    output_result(loopN, V, W, H, wb, hb, KK, wsize, wsize, root_fname, sps_params, objs);
end
