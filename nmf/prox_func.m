function [w] = prox_func(y, alpha, beta, eta)

%y = max(y,0);
w = sign(y).*max(abs(y)-eta*alpha, 0)./(1+eta*beta);
w = max(w,0);

end
