function [accuracy, all_avecc1_w, all_avecc2_w, all_avecc_h] = correlation_fun(w, h, w0, h0)

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

valid_corrcoef_k_vec=[];
valid_corrcoef_btm = 0.7;
invalid_corrcoef_upper = 0.5;

valid_ccval1_vec = [];
valid_ccval2_vec = [];

valid_hccval_vec = [];
all_hccval_vec = [];

for k=1:KK
    corrcoef_k1 = cc_result_array(2, k);
    corrcoef_val1 = cc_result_array(1, k);
    corrcoef_k2 = cc_result_array(4, k);
    corrcoef_val2 = cc_result_array(3, k);

    ccmat = corrcoef(h(k,:), h0(corrcoef_k1,:));
    hccoef = ccmat(2,1);
    all_hccval_vec = [all_hccval_vec, hccoef];

    if (valid_corrcoef_btm < corrcoef_val1) && (invalid_corrcoef_upper > corrcoef_val2)
        valid_corrcoef_k_vec = [valid_corrcoef_k_vec, corrcoef_k1];
        valid_ccval1_vec = [valid_ccval1_vec, corrcoef_val1];
        valid_ccval2_vec = [valid_ccval2_vec, corrcoef_val2];
        valid_hccval_vec = [valid_hccval_vec, hccoef];
    end
end;

[uniq_vcc_kvec, uniq_idx, orign_idx] = unique(valid_corrcoef_k_vec);
n_duplicated = size(valid_corrcoef_k_vec, 2)-size(uniq_vcc_kvec, 2);

n_valid_cell = size(uniq_vcc_kvec, 2);

valid_ccval1_vec = valid_ccval1_vec(uniq_idx);
valid_ccval2_vec = valid_ccval2_vec(uniq_idx);
valid_hccval_vec = valid_hccval_vec(uniq_idx);


valid_avecc1_w = mean(valid_ccval1_vec);
valid_avecc2_w = mean(valid_ccval2_vec);
valid_avecc_h = mean(valid_hccval_vec);
accuracy = n_valid_cell/KK;

all_avecc1_w = mean(cc_result_array(1,:));
all_avecc2_w = mean(cc_result_array(3,:));
all_avecc_h = mean(all_hccval_vec);
