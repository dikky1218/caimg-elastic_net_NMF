function [gf] = gauss_fn(XX,YY,mux,muy,sigm1,sigm2,theta,Amp,th)

[x y]=meshgrid(1:1:XX,1:1:YY);

x1 = x - mux;
y1 = y - muy;
RM = [cos(theta), -sin(theta);sin(theta), cos(theta)];
MM = inv(RM'*diag([sigm1^2, sigm2^2])*RM);
  
%tp=exp(-0.5.*(MM(1,1).*x1.*x1+MM(2,2).*y1.*y1+2.0.*MM(1,2).*x1.*y1))./(2.*pi.*sigm1.*sigm2);
tp=exp(-0.5.*(MM(1,1).*x1.*x1+MM(2,2).*y1.*y1+2.0.*MM(1,2).*x1.*y1));
gf = Amp.*tp.*(tp>th);

end

