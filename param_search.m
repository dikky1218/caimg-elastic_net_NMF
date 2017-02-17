function [V,W,H] = param_search(init_V)
addpath(genpath('util'));
addpath(genpath('outputter'));
addpath(genpath('nmf'));
addpath(genpath('correlation'));

%artificial data
root_fname = 'sz64_f2000_k16_snr0.001';
file_name = ['../result/prmsearch/', root_fname, '_', datestr(now, 'yymmddHHMMSS')];

bs = 1;
KK = 16;
wsize = 64;
loopN = 50;

n_experiment = 20;

%sps_params = [h_sps_a, h_sps_b, w_sps_a, w_sps_b, wb_sps_a, wb_sps_b];
sps_params = [0, 0, 0, 0, 0, 0, 0, 0];

%parameter search list
%wsps_a_vec = [0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000];
wsps_a_vec = [0:1000:3000, 3500:500:6500, 7000:1000:10000];

cc1_ws = [];
cc2_ws = [];
cc_hs = [];
accry_list = [];

howsparseW = [];

for i=1:size(wsps_a_vec,2)
    sps_params(3) = wsps_a_vec(i);

    tcc1_ws = zeros(n_experiment, loopN);
    tcc2_ws = zeros(n_experiment, loopN);
    tcc_hs = zeros(n_experiment, loopN);
    taccry_list = zeros(n_experiment, loopN);

    t_howsps_w = [];

    for j=1:n_experiment
        fprintf('===============================\n', i);
        fprintf('%d th sperse param searching... %d\n', i,j);
        fprintf('===============================\n', i);
    
        %[V, W, H, wb, hb, avi, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = art_elastic_NMF_gpu(loopN, init_V, wsize, wsize, KK, sps_params, ['../artificial_data/', root_fname, '.mat']);
        [V, W, H, wb, hb, avi, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = art_elastic_NMF3_gpu(loopN, init_V, wsize, wsize, KK, sps_params, ['../artificial_data/', root_fname, '.mat']);
        
        %art_elastic_net_outputter(loopN, V, W, H, wb, hb, KK, wsize, wsize, avi, root_fname, sps_params, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts);

        t_howsps_w = [t_howsps_w, sum(sum(W==0))/numel(W)];
    
        tcc1_ws(j,:) = cc1_w;
        tcc2_ws(j,:) = cc2_w;
        tcc_hs(j,:) = cc_h;
        taccry_list(j,:) = accuracies;
    end


    mcc1_w = mean(tcc1_ws);
    mcc2_w = mean(tcc2_ws);
    mcc_h = mean(tcc_hs);
    maccuracies = mean(taccry_list);

    cc1_ws = [cc1_ws, mcc1_w(end)];
    cc2_ws = [cc2_ws, mcc2_w(end)];
    cc_hs = [cc_hs, mcc_h(end)];
    accry_list = [accry_list, maccuracies(end)];
    howsparseW = [howsparseW, mean(t_howsps_w)];
end

%% plot 1st correlation coefficient of w
fig_cc1w = figure('visible', 'off');
%semilogx(wsps_a_vec, cc1_ws);
plot(wsps_a_vec, cc1_ws);
ylim([0,1]);
fname = [file_name,'prmsearch_cc1w'];
save_img(fig_cc1w, fname);
%% plot 2nd correlation coefficient of w
fig_cc2w = figure('visible', 'off');
%semilogx(wsps_a_vec, cc2_ws);
plot(wsps_a_vec, cc2_ws);
ylim([0,1]);
fname = [file_name,'prmsearch_cc2w'];
save_img(fig_cc2w, fname);

%% plot correlation coefficient of h
fig_cch = figure('visible', 'off');
plot(wsps_a_vec, cc_hs);
%semilogx(wsps_a_vec, cc_hs);
ylim([0,1]);
fname = [file_name,'prmsearch_cch'];
save_img(fig_cch, fname);

%% accuracies of w
fig_accy = figure('visible', 'off');
plot(wsps_a_vec, accry_list);
%semilogx(wsps_a_vec, accry_list);
ylim([0,1]);
fname = [file_name,'prmsearch_accry'];
save_img(fig_accy, fname);

%% sparseness of w
fig_sps = figure('visible', 'off');
plot(wsps_a_vec, howsparseW);
%semilogx(wsps_a_vec, howsparseW);
ylim([0,1]);
fname = [file_name,'prmsearch_spsness'];
save_img(fig_sps, fname);

save([file_name, 'prmsearch_mat.mat'], 'cc1_ws', 'cc2_ws', 'cc_hs', 'accry_list', 'wsps_a_vec', 'n_experiment', 'howsparseW');
