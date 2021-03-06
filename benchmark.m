function [V,W,H] = benchmark(init_V)
addpath(genpath('util'));
addpath(genpath('outputter'));
addpath(genpath('nmf'));
addpath(genpath('correlation'));

%artificial data
artf_data=true;
root_fname = 'sz64_f2000_k64_snr0018';
artf_data_matname = ['../artificial_data/', root_fname, '.mat'];

gpu_mode = true;

KK = 64;
wsize = 64;

loopN = 100;

n_experiment = 10;

file_name = ['../result/benchmark/enNMF_15_04_8000_0/', root_fname, '_NEXP', num2str(n_experiment), '_', datestr(now, 'yymmddHHMMSS')];

%elastic net parameters
best_hspsa = 10;
best_hspsb = 2;
spsness = 1;
h_sps_a = spsness.*best_hspsa;
h_sps_b = (1-spsness).*best_hspsb;
best_wspsa = 8000;
best_wspsb = 1600;
w_spsness = 0.9;
w_sps_a = w_spsness.*best_wspsa;
w_sps_b = (1-w_spsness).*best_wspsb;
%sps_params = [20, 0.2, w_sps_a, w_sps_b];
sps_params = [15, 0.4, 8000, 0];

cc1_ws = zeros(n_experiment, loopN);
cc2_ws = zeros(n_experiment, loopN);
cc_hs = zeros(n_experiment, loopN);
accr_list = zeros(n_experiment, loopN);
objs_list = zeros(n_experiment, loopN);


for i=1:n_experiment

    [V, W, H, wb, hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = enNMF(gpu_mode, loopN, init_V, KK, sps_params, artf_data, artf_data_matname, [], [], []);
    %[V, W, H, wb, hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = NMF(gpu_mode, loopN, init_V, KK, sps_params, artf_data, artf_data_matname);

    cc1_ws(i,:) = cc1_w;
    cc2_ws(i,:) = cc2_w;
    cc_hs(i,:) = cc_h;
    accr_list(i,:) = accuracies;
    objs_list(i,:) = objs;
end

%% plot objs
fig_obj = figure('visible', 'off');
mobjs =mean(objs_list);
vobjs =mean(std(objs_list));
plot(mobjs(2:end));
title(['std: ', num2str(vobjs), ' i>=2 ']);
fname = [file_name,'bnmk_objs'];
save_img(fig_obj, fname);
%% plot 1st correlation coefficient of w
fig_cc1w = figure('visible', 'off');
mcc1_ws=mean(cc1_ws);
vcc1_ws=mean(std(cc1_ws));
plot(mcc1_ws);
ylim([0,1]);
title(['std: ', num2str(vcc1_ws)]);
fname = [file_name,'bnmk_cc1w'];
save_img(fig_cc1w, fname);
%% plot 2nd correlation coefficient of w
fig_cc2w = figure('visible', 'off');
vcc2_ws=mean(std(cc2_ws));
mcc2_ws=mean(cc2_ws);
plot(mcc2_ws);
ylim([0,1]);
title(['std: ', num2str(vcc2_ws)]);
fname = [file_name,'bnmk_cc2w'];
save_img(fig_cc2w, fname);

%% plot correlation coefficient of h
fig_cch = figure('visible', 'off');
mcc_hs=mean(cc_hs);
vcc_hs=mean(std(cc_hs));
plot(mcc_hs);
ylim([0,1]);
title(['std: ', num2str(vcc_hs)]);
fname = [file_name,'bnmk_cch'];
save_img(fig_cch, fname);

%% accuracies of w
fig_acc = figure('visible', 'off');
maccr=mean(accr_list);
vaccr=mean(std(accr_list));
plot(maccr);
ylim([0,1]);
title(['std: ', num2str(vaccr)]);
fname = [file_name,'bnmk_accr'];
save_img(fig_acc, fname);

save([file_name, 'bnmk_mat.mat'], 'mcc1_ws', 'mcc2_ws', 'mcc_hs', 'maccr');

