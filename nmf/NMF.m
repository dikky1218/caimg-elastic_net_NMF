function [r_V, r_W, r_H, r_wb, r_hb, objs, cc1_w, cc2_w, cc_h, accuracies, tcosts] = NMF(gpu, loopN, init_V, KK, sps_params, artf_data, artf_data_matname)

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

%sparseness parameter
h_sps_a = sps_params(1);
h_sps_b = sps_params(2);
w_sps_a = sps_params(3);
w_sps_b = sps_params(4);

FF = size(init_V,1);
TT = size(init_V,2);

V = init_V;
if gpu
    V = gpuArray(init_V);
end

%hyper parameter
hyp_alpha = ones(KK,1);
hyp_beta = ones(KK,1);
hyp_nu = 2.0.*ones(1,KK);
hyp_mu = ones(1,KK);

ones_kt=ones(KK, TT);
ones_nk=ones(FF, KK);
ones_1t=ones(1,TT);
I_k=eye(KK);

%set random initial values in W, H.
aveIMG = mean(V,2);
wb_t = aveIMG;
%wb_t = ones(FF,1);
hb_t = ones(1,TT);
w_t = gamrnd(ones(FF,1)*hyp_nu,(ones(FF,1)*hyp_mu)./(ones(FF,1)*hyp_nu));
h_t = gamrnd(hyp_alpha*ones(1,TT),(hyp_beta*ones(1,TT))./(hyp_alpha*ones(1,TT)));
if gpu
    w_t = gpuArray(w_t);
    h_t = gpuArray(h_t);
end


begobj = sum(sum((V-w_t*h_t-wb_t*hb_t).^2));
objs = zeros(1, loopN);

%ALS calculation
t=0;
tic;
while t<loopN

    tmp_V = (V - wb_t*hb_t);
    %h_t1 = inv(w_t'*w_t + h_sps_b.*I_k) * (w_t'*tmp_V - h_sps_a.*ones_kt);
    h_t1 = (w_t'*w_t + h_sps_b.*I_k)\(w_t'*tmp_V - h_sps_a.*ones_kt);
    h_t1 = max(h_t1,0);
    r_H = h_t1;
    
    
    %w_t1 = (tmp_V*h_t1' - w_sps_a.*ones_nk) * inv(h_t1*h_t1' + w_sps_b.*I_k);
    tmpA=(h_t1*h_t1' + w_sps_b.*I_k);
    w_t1=(tmpA'\(tmp_V*h_t1' - w_sps_a.*ones_nk)')';
    w_t1 = max(w_t1,0);
    w_t1 = w_t1./(ones(FF,1)*sqrt(sum(w_t1.^2,1)));  %regularization 
    r_W = w_t1;
    
    tmp_VV = (V - w_t1*h_t1);
    wb_t1 = ((hb_t*hb_t')'\(tmp_VV*hb_t')')';
    wb_t1 = max(wb_t1,0);

    newobj = sum(sum((V-w_t*h_t-wb_t*hb_t).^2));
    
    w_t = w_t1;
    wb_t = wb_t1;
    h_t = h_t1;

    objs(t+1) = get_val(gpu, newobj);
    t = t+1; 
    begobj = newobj;

    fprintf('%d: obj %f\n', t, newobj);

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
r_W = get_val(gpu, w_t);
r_H = get_val(gpu, h_t);
r_wb = get_val(gpu, wb_t);
r_hb = get_val(gpu, hb_t);
