function [r_V, r_W, r_H, r_wb, r_hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = enNMF(gpu, loopN, init_V, KK, sps_params, artf_data, artf_data_matname, initW, initH, initWb)

%init variables used when artificial data experiment
cc1_w = [];
cc2_w = [];
cc_h = [];
accuracies = [];
tcosts = [];
if artf_data
    load(artf_data_matname, '-mat', 'w', 'h');
    w0 = w;
    h0 = h;
    clear w;
    clear h;
end

%init sparseness parameters
h_sps_a = sps_params(1);
h_sps_b = sps_params(2);
w_sps_a = sps_params(3);
w_sps_b = sps_params(4);


FF = size(init_V, 1);
TT = size(init_V, 2);

initNMF_loopN = 10;

V = init_V;
if gpu 
    V = gpuArray(V);
end




%%%%%%%%%%%%%%%
%init variables
%%%%%%%%%%%%%%%
hb_t = ones(1,TT);

%set random initial values in W, H.
%hyper parameters for initialization of W, H
hyp_alpha = ones(KK,1);
hyp_beta = ones(KK,1);
hyp_nu = 2.0.*ones(1,KK);
hyp_mu = ones(1,KK);

w_t = gamrnd(ones(FF,1)*hyp_nu,(ones(FF,1)*hyp_mu)./(ones(FF,1)*hyp_nu));
h_t = gamrnd(hyp_alpha*ones(1,TT),(hyp_beta*ones(1,TT))./(hyp_alpha*ones(1,TT)));
aveIMG = mean(V,2);
wb_t = aveIMG;

if ~isempty(initW) && ~isempty(initH) && ~isempty(initWb)
    initNMF_loopN = 0;
    w_t = w_t + initW;
    h_t = h_t + initH;
    wb_t = initWb;
end

if gpu
    hb_t = gpuArray(hb_t);
    w_t = gpuArray(w_t);
    h_t = gpuArray(h_t);
end

w_t = w_t./(ones(FF,1)*sqrt(sum(w_t.^2,1)));  %regularization 
obj_t = sum(sum((V-w_t*h_t-wb_t*hb_t).^2));
r_W = w_t;
r_H = h_t;
objs = zeros(1, loopN);


fbs_loop_limit = 100;


%%%%%%%%%
%ALS loop
%%%%%%%%%
tic;
for i=1:loopN
    if rem(i,5)==0 
    %    fbs_loop_limit = fbs_loop_limit + 1;
    end

    objs(i) = get_val(gpu, obj_t);

    %update wb
    tmp_VV = (V - w_t*h_t);
    wb_t1 = fbs(gpu, wb_t, hb_t, tmp_VV, 0, 0, false, fbs_loop_limit);
    if ~is_matrix_valid(gpu, wb_t1, 'wb', i)
        break;
    end

    %update W
    tmp_V = (V - wb_t1*hb_t);
    if i <= initNMF_loopN
        w_t1 = fbs(gpu, w_t, h_t, tmp_V, 0, 0, true, fbs_loop_limit);
    else
        w_t1 = fbs(gpu, w_t, h_t, tmp_V, w_sps_a, w_sps_b, true, fbs_loop_limit);
    end
    w_t1 = w_t1./(ones(FF,1)*sqrt(sum(w_t1.^2,1)));
    if ~is_matrix_valid(gpu, w_t1, 'W', i)
        break;
    end

    %update H
    if i <= initNMF_loopN
        h_t1 = (fbs(gpu, h_t', w_t1', tmp_V', 0, 0, true, fbs_loop_limit))';
    else
        h_t1 = (fbs(gpu, h_t', w_t1', tmp_V', h_sps_a, h_sps_b, true, fbs_loop_limit))';
    end
    if ~is_matrix_valid(gpu, h_t1, 'H', i)
        break;
    end

    %update matrixes for next step.
    wb_t = wb_t1;
    w_t = w_t1;
    h_t = h_t1;

    obj_t1 = sum(sum((V-w_t*h_t-wb_t*hb_t).^2)) + w_sps_a.*sum(sum(abs(w_t))) + w_sps_b/2.*sum(sum(w_t.^2)) + h_sps_a.*sum(sum(abs(h_t))) + h_sps_b/2.*sum(sum(h_t.^2));

    if(obj_t1 >= obj_t)
        fprintf('ALS step %d : error increased.\n', i);
    elseif(obj_t1 < obj_t)
        fprintf('ALS step %d : error decreased.\n', i);
    end
    obj_t = obj_t1;


    %add correlation data.
    if artf_data
        [ta, tcc1w, tcc2w, tcch] = correlation_fun(get_val(gpu, w_t), get_val(gpu, h_t), w0, h0);
        accuracies = [accuracies, ta];
        cc1_w = [cc1_w, tcc1w];
        cc2_w = [cc2_w, tcc2w];
        cc_h = [cc_h, tcch];
        tcosts = [tcosts, toc];
    end

end;

r_V = get_val(gpu, V);
r_wb = get_val(gpu, wb_t);
r_hb = get_val(gpu, hb_t);
r_H = get_val(gpu, h_t);
r_W = get_val(gpu, w_t);

