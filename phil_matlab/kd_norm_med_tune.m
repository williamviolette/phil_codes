function h = kd_norm_med_tune(beta_1,alpha_1,sigma_1,pL,pM,pH,kL,kH,TUNE)

R = sqrt(2);

h=((pH.*kH-pL.*kL-pM.*(kH-kL)).*alpha_1.*TUNE.*R-(2.*((pH+pL).*alpha_1-2.*beta_1)).*sigma_1)...
    ./(R.*TUNE.*(pH-pL).*alpha_1+4.*sigma_1);