function [] = art_elastic_net_outputter3d(loopN, V, W, H, wb, hb, KK, wsize, root_fname, sps_params, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts)

%prepare file name.
sps_name = ['_', num2str(sps_params(1)), '_', num2str(sps_params(2)), '_', num2str(sps_params(3)), '_', num2str(sps_params(4))];

file_name = [root_fname, '_K', num2str(KK), sps_name, '_', num2str(loopN), 'loop'];
save_dir = ['../result/', file_name, '_', datestr(now, 'yymmddHHMMSS')];
mkdir(save_dir);

file_name = [save_dir, '/', file_name, '_'];

%save matrixes
result_matname = [file_name, 'W_H_wb_hb'];
save(result_matname, 'W', 'H', 'wb', 'hb', 'objs', 'cc1_w', 'cc2_w', 'cc_h', 'accuracies', 'tcosts');

%Save aveIMG.
aveIMG = mean(V,2);
zslice_outputter(0,aveIMG, [], wsize, file_name);

%Plot ROIs.
for k=1:KK
    zslice_outputter(k, W(:,k), H(k,:), wsize, file_name);
end;

%Plot background w, h.
backK=1234;
zslice_outputter(backK, wb, hb, wsize, file_name);

%% plot objective function values of ALS
fig_objs = figure('visible', 'off');
objs = objs(2:end);
plot(objs);
fname = [file_name,'objs'];
save_img(fig_objs, fname);

%% plot 1st correlation coefficient of w
fig_cc1w = figure('visible', 'off');
plot(cc1_w);
ylim([0,1]);
fname = [file_name,'corrcoef1_w'];
save_img(fig_cc1w, fname);
%% plot 2nd correlation coefficient of w
fig_cc2w = figure('visible', 'off');
plot(cc2_w);
ylim([0,1]);
fname = [file_name,'corrcoef2_w'];
save_img(fig_cc2w, fname);

%% plot correlation coefficient of h
fig_cch = figure('visible', 'off');
plot(cc_h);
ylim([0,1]);
fname = [file_name,'corrcoef_h'];
save_img(fig_cch, fname);

%% accuracies of w
fig_accy = figure('visible', 'off');
plot(accuracies);
ylim([0,1]);
fname = [file_name,'accuracy'];
save_img(fig_accy, fname);

%% time cost of calc
fig_tcost = figure('visible', 'off');
plot(tcosts);
fname = [file_name,'timecost'];
save_img(fig_tcost, fname);

%%output correlation and result log file.
rsummary_fname = [result_matname,'_rsummary.txt'];

addlog(rsummary_fname, sprintf('Number of ALS loop'), 'new');
addlog(rsummary_fname, sprintf('%d', loopN), 'add');

addlog(rsummary_fname, sprintf('Frame size'), 'add');
addlog(rsummary_fname, sprintf('%d by %d', wsize, wsize), 'add');

addlog(rsummary_fname, sprintf('sps params [a_h, b_h, a_w, b_w, a_wb, b_wb, a_hb, b_hb]'), 'add');
addlog(rsummary_fname, sprintf('%s', sps_name), 'add');

%correlation_check(['../artificial_data/', root_fname, '.mat'], result_matname, rsummary_fname);



