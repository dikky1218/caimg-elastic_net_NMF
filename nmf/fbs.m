function [rw] = fbs(gpu, W, H, V, inialpha, beta, debug, i_limit)

W_t = W;
x_t_1 = W;
a_t = 1;

eps = 1e-6;

grad_f = (W_t*H-V)*H';
f_t = sum(sum(0.5.*(V-W_t*H).^2));

history_len = 5;
f_history = [f_t];

n_r_0 = 0;

i=0;
alpha = 0;

while i < i_limit

    if i~=0
        alpha = inialpha;
        %calculates step size by the spectral method.
        dF_t = grad_f - prev_grad_f;
        dW_t = W_t - W_t_1;
        t_dFdW = sum(sum(dF_t.*dW_t));
        step_m = t_dFdW/sum(sum(dF_t.*dF_t));
        step_s = sum(sum(dW_t.*dW_t))/t_dFdW;

        if (step_m/step_s > 0.5)
            step = step_m;
        else
            step = step_s - 0.5*step_m;
        end

        if (step_m <= 0) || (step_s <= 0)
            step = last_step;
        end

    else % if i==0
        difV = V-W*H;
        step = calc_step_size(-difV*H'*H, difV);
    end

    %FBS
    W_t_half = W_t-step.*grad_f;
    W_t1 = prox_func(W_t_half, alpha, beta, step);

    %FISTA
    %x_t = prox_func(W_t_half, alpha, beta, step);
    %a_t1 = (1+sqrt(1+4*a_t^2))/2;
    %W_t1 = x_t + (a_t - 1)/a_t1.*(x_t - x_t_1);


    %back tracking for the step size to ensure the convergence.
    f_history_max = max(f_history([max(end-history_len+1,1),end]));
    t_difV = V-W_t1*H;
    f_t1 = 0.5.*sum(sum(t_difV.^2));
    tdw = W_t1-W_t;
    f_aprx = f_history_max + sum(sum(tdw.*grad_f));
    dw_square = 0.5.*sum(sum(tdw.^2));

    %loop until the convergence condition is satisfied.
    bi=0;
    n_bktr_max = 9;
    while (f_t1 >= (f_aprx + 1/step*dw_square)) && (bi < n_bktr_max)
        step = step/2;

        W_t_half = W_t-step.*grad_f;
        W_t1 = prox_func(W_t_half, alpha, beta, step);

        t_difV = V-W_t1*H;
        f_t1 = 0.5.*sum(sum(t_difV.^2));
        tdw = W_t1-W_t;
        f_aprx = f_history_max + sum(sum(tdw.*grad_f));
        dw_square = 0.5.*sum(sum(tdw.^2));

        bi = bi+1;

        if debug
            fprintf('back tracking %d. step:%e, (f_t:%f)\n', bi, step, f_t1);
        end
    end

    %convergence judgement
    new_grad_f = -t_difV*H';
    new_grad_g = (W_t1-W_t_half)./step;
    r_t1 = -new_grad_f + new_grad_g;
    n_grad_f = sum(sum(new_grad_f.^2));
    n_grad_g = sum(sum(new_grad_g.^2));

    n_r_t1 = sum(sum(r_t1.^2));
    rr_t1 = n_r_t1/(max(n_grad_f, n_grad_g)+eps);

    if i == 0
        n_r_0 = n_r_t1;
    end
    rn_t1 = n_r_t1/(n_r_0+eps);

    if (rr_t1 < 1e-4) || (bi >=n_bktr_max) || (rn_t1 < 1e-4) 
        if debug
            fprintf('============================================\n');
            fprintf('FBS update %d : Converged. step: %e, f_t: %f, bi: %d\n', i, step, f_t1, bi);
            fprintf('============================================\n');
        end
        break;
    end

    if debug
        fprintf('[%d FBS update] step: %e, rn_t %e, rr_t %e, f_t: %f\n', i, step, rn_t1, rr_t1, f_t1);
    end

    %update
    i=i+1;
    prev_grad_f = grad_f;
    grad_f = new_grad_f;
    W_t_1 = W_t;
    W_t = W_t1;
   % a_t = a_t1;
   % x_t_1 = x_t;
    f_history = [f_history, f_t1];
    f_t = f_t1;
    last_step = step;
end

rw=W_t1;
