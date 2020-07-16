function [g,h] =  hs(x,wobs,sig,dh01,dh10,dh11)

% dh01 = FROM hess1
% dh10
% dh11

pdf=1;
[gx,dg,dg2] = ng_normalpdf(x,wobs,sig,pdf);

%%%% log difference!
df   =  1./gx      ;
df2  = -1./(gx.^2) ;

g =-1.*( dh01.*df.*dg);

h = dh01.*dh10.*dg.^2.*df2  + ...
dh01.*dh10.*dg2.*  df  + ...
dh11.*      dg .*  df  ;


