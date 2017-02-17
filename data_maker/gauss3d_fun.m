function [gf] = gauss3d_fun(XX,YY,ZZ,mux,muy,muz,sigm1,sigm2,sigm3,t1,t2,t3,Amp,th)

[x y z]=meshgrid(1:XX,1:YY,1:ZZ);

x1 = x - mux;
y1 = y - muy;
z1 = z - muz;

Rx = [1 0 0; 0 cos(t1) -sin(t1); 0 sin(t1) cos(t1)];
Ry = [cos(t2) 0 sin(t2); 0 1 0; -sin(t2) 0 cos(t2)];
Rz = [cos(t3) -sin(t3) 0; sin(t3) cos(t3) 0; 0 0 1];

RM = Rx*Ry*Rz;

MM = inv(RM'*diag([sigm1^2, sigm2^2, sigm3^2])*RM);
  
%tp=exp(-0.5.*(MM(1,1).*x1.*x1+MM(2,2).*y1.*y1+2.0.*MM(1,2).*x1.*y1))./(2.*pi.*sigm1.*sigm2);
tp=exp(-0.5.*(MM(1,1).*x1.*x1 +MM(2,2).*y1.*y1 +MM(3,3).*z1.*z1 + 2.0.*MM(1,2).*x1.*y1 + 2.0.*MM(1,3).*x1.*z1 + 2.0.*MM(2,3).*y1.*z1));
gf = Amp.*tp.*(tp>th);

end

