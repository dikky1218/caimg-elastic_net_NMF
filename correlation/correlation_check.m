function [] = correlation_check(artf_data_matname, result_data_matname, rsummary_fname)

load(artf_data_matname, '-mat', 'w', 'h');
w0 = w;
h0 = h;
clear w;
clear h;

%when parameter is int.
%load([result_data_matname, '.mat'], '-mat', 'W', 'H');
%when parameter is float.
load(result_data_matname, '-mat', 'W', 'H');
w=W;
h=H;
clear W;
clear H;

mvframe_size = sqrt(size(w,1));

KK = size(w, 2);

if KK ~= size(w0, 2)
    return;
end

cc_result_array = zeros(4,KK);

for i = 1:KK
    vec_wi = w(:, i);

    corr_coef_array = [];

    for j = 1:KK
        vec_w0j = w0(:, j);
        ccmat = corrcoef(vec_wi, vec_w0j);
        coef_ij = ccmat(2,1);
        corr_coef_array = [corr_coef_array, coef_ij];
    end

    [max_corrcoef, mcorrelated_k] = max(corr_coef_array);
    corr_coef_array(mcorrelated_k) = 0;
    [secndmax_corrcoef, secndmcorrelated_k] = max(corr_coef_array);

    cc_result_array(:,i) = [max_corrcoef; mcorrelated_k; secndmax_corrcoef; secndmcorrelated_k];

end

%output result.
ncolumn=4;
nrow = 4;
KK_on_f=ncolumn;
figures = ceil(KK / KK_on_f);

valid_corrcoef_k_vec=[];
valid_corrcoef_btm = 0.7;
invalid_corrcoef_upper = 0.5;

valid_ccval1_vec = [];
valid_ccval2_vec = [];

valid_hccval_vec = [];
all_hccval_vec = [];


for f=1:figures
    n_drawnROI = (f-1)*KK_on_f;
    n_not_drawnROI = KK-n_drawnROI;
    n_ROI_on_f = KK_on_f;
    if n_not_drawnROI < KK_on_f
        n_ROI_on_f = n_not_drawnROI;
    end;

    fig_corrcoef = figure('visible', 'off');

    for k=1:n_ROI_on_f
        total_k = n_drawnROI + k;
        corrcoef_k1 = cc_result_array(2, total_k);
        corrcoef_val1 = cc_result_array(1, total_k);
        corrcoef_k2 = cc_result_array(4, total_k);
        corrcoef_val2 = cc_result_array(3, total_k);

        ccmat = corrcoef(h(total_k,:), h0(corrcoef_k1,:));
        hccoef = ccmat(2,1);
        all_hccval_vec = [all_hccval_vec, hccoef];

        if (valid_corrcoef_btm < corrcoef_val1) && (invalid_corrcoef_upper > corrcoef_val2)
            valid_corrcoef_k_vec = [valid_corrcoef_k_vec, corrcoef_k1];
            valid_ccval1_vec = [valid_ccval1_vec, corrcoef_val1];
            valid_ccval2_vec = [valid_ccval2_vec, corrcoef_val2];
            valid_hccval_vec = [valid_hccval_vec, hccoef];
        end

        %wk
        subplot(nrow, ncolumn, k);
        imagesc(reshape(w(:,total_k),  mvframe_size, mvframe_size));
        title(['w', num2str(total_k)]);

        %hk
        subplot(nrow, ncolumn, k+ncolumn);
        plot(h(total_k,:));
        title(['h', num2str(total_k)]);

        %w0k
        subplot(nrow, ncolumn, k+2*ncolumn);
        imagesc(reshape(w0(:,corrcoef_k1),  mvframe_size, mvframe_size));
        title({['1: k=', num2str(corrcoef_k1), ' ,', num2str(corrcoef_val1)];['2: k=', num2str(corrcoef_k2), ' ,', num2str(corrcoef_val2)]});

        %h0k
        subplot(nrow, ncolumn, k+3*ncolumn);
        plot(h0(corrcoef_k1,:));
        title(['h0 k=', num2str(corrcoef_k1), ' ,', num2str(hccoef)]);
    end;


    cc_fname = [result_data_matname,'_corrcoef_', num2str(f)];
    save_img(fig_corrcoef, cc_fname);
end;

[uniq_vcc_kvec, uniq_idx, orign_idx] = unique(valid_corrcoef_k_vec);
n_duplicated = size(valid_corrcoef_k_vec, 2)-size(uniq_vcc_kvec, 2);
n_valid_cell = size(uniq_vcc_kvec, 2);
valid_ccval1_vec = valid_ccval1_vec(uniq_idx);
valid_ccval2_vec = valid_ccval2_vec(uniq_idx);
valid_hccval_vec = valid_hccval_vec(uniq_idx);

%output result text
addlog(rsummary_fname, sprintf('Number of the cells'), 'add');
addlog(rsummary_fname, sprintf('%d', KK), 'add');

addlog(rsummary_fname, sprintf('Number of the detected cells'), 'add');
addlog(rsummary_fname, sprintf('%d', n_valid_cell), 'add');

addlog(rsummary_fname, sprintf('accuracy'), 'add');
addlog(rsummary_fname, sprintf('%f', n_valid_cell/KK*100), 'add');

addlog(rsummary_fname, sprintf('%d duplicated cells are detected.', n_duplicated), 'add');

%correlation coefficient of valid cells.
addlog(rsummary_fname, sprintf('Average correlation coefficient of valid cells'), 'add');
addlog(rsummary_fname, sprintf('%f', mean(valid_ccval1_vec)), 'add');

addlog(rsummary_fname, sprintf('Average 2nd correlation coefficient of valid cells.'), 'add');
addlog(rsummary_fname, sprintf('%f', mean(valid_ccval2_vec)), 'add');

addlog(rsummary_fname, sprintf('Average h correlation coefficient of valid cells.'), 'add');
addlog(rsummary_fname, sprintf('%f', mean(valid_hccval_vec)), 'add');

%correlation coefficient of all cells.
addlog(rsummary_fname, sprintf('Average correlation coefficient of all cells'), 'add');
addlog(rsummary_fname, sprintf('%f', mean(cc_result_array(1,:))), 'add');

addlog(rsummary_fname, sprintf('Average 2nd correlation coefficient of all cells.'), 'add');
addlog(rsummary_fname, sprintf('%f', mean(cc_result_array(3,:))), 'add');

addlog(rsummary_fname, sprintf('Average h correlation coefficient of all cells.'), 'add');
addlog(rsummary_fname, sprintf('%f', mean(all_hccval_vec)), 'add');
