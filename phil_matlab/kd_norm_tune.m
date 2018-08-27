function h = kd_norm_tune(beta_1,alpha_1,sigma_1,pL,pH,k,TUNE)

R=sqrt(2);

h = ((R.*k.*(pH-pL).*TUNE-2.*sigma_1.*(pH+pL)).*alpha_1+4.*beta_1.*sigma_1)...
    ./(R.*TUNE.*(pH-pL).*alpha_1+4.*sigma_1);
