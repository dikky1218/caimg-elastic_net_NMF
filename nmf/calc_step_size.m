function [step] = calc_step_size(P, Q)


step = -sum(sum(P.*Q))/sum(sum(P.^2));
