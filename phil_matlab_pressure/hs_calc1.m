function [g,h]=hs_calc1(x,wobs,sig,dh01,dh10,dh11)

pdf=1;
[gx,dg,dg2] = ng_normalpdf(x,wobs,sig,pdf);
%%% alpha0
[g,h]=hs(gx,dg,dg2,dh01,dh10,dh11);
