function ll= est_nmid_bg_tune (a,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,SHR,REG,lambda,PH_C,TUNE)
R=sqrt(2);
PH=PH_C(:,1).*a(1, 1 );
if size(PH_C,2)>= 2 ;
PH=PH+PH_C(:, 2 ).*a(1, 2 );
end;
if size(PH_C,2)>= 3 ;
PH=PH+PH_C(:, 3 ).*a(1, 3 );
end;
if size(PH_C,2)>= 4 ;
PH=PH+PH_C(:, 4 ).*a(1, 4 );
end;
if size(PH_C,2)>= 5 ;
PH=PH+PH_C(:, 5 ).*a(1, 5 );
end;
if size(PH_C,2)>= 6 ;
PH=PH+PH_C(:, 6 ).*a(1, 6 );
end;
if size(PH_C,2)>= 7 ;
PH=PH+PH_C(:, 7 ).*a(1, 7 );
end;
if size(PH_C,2)>= 8 ;
PH=PH+PH_C(:, 8 ).*a(1, 8 );
end;
if size(PH_C,2)>= 9 ;
PH=PH+PH_C(:, 9 ).*a(1, 9 );
end;
if size(PH_C,2)>= 10 ;
PH=PH+PH_C(:, 10 ).*a(1, 10 );
end;
A=SHR(:,1);
sigma_1=SHR(:,2);
alpha_1=SHR(:,3);
beta_1=SHR(:,4)-alpha_1.*PH;
S_sL_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_sL_2 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_sL_2 = (Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
CSA_sL_2 = 1./2+1./2.*erf(1./2.*VSA_sL_2.*2.^(1./2)) ;
PSB_sL_2 = 1./2.*exp(-1./2.*VSB_sL_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sL_2 = 1./S_sL_2.*CSA_sL_2.*PSB_sL_2 ;
clear  CSA_sL_2  CSB_sL_2  CNL_sL_2  CNH_sL_2  PSA_sL_2  PSB_sL_2  PNL_sL_2  PNH_sL_2  VSA_sL_2  VSB_sL_2  VNL_sL_2  VNH_sL_2
S_sL_3 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sL_3 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_3+beta_1)+2.*A).*R./TUNE./sigma_1-sigma_1./(A.^2+sigma_1.^2).*(alpha_1.*p_3+Q_obs-beta_1))./(1-sigma_1.^2./(A.^2+sigma_1.^2)).^(1./2) ;
VSB_sL_3 = (alpha_1.*p_3+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sL_3 = 1./2+1./2.*erf(1./2.*VSA_sL_3.*2.^(1./2)) ;
PSB_sL_3 = 1./2.*exp(-1./2.*VSB_sL_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sL_3 = 1./S_sL_3.*CSA_sL_3.*PSB_sL_3 ;
clear  CSA_sL_3  CSB_sL_3  CNL_sL_3  CNH_sL_3  PSA_sL_3  PSB_sL_3  PNL_sL_3  PNH_sL_3  VSA_sL_3  VSB_sL_3  VNL_sL_3  VNH_sL_3
S_sL_4 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sL_4 = (1./2.*(R.*k_3.*TUNE-R.*TUNE.*(-alpha_1.*p_4+beta_1)+2.*A).*R./TUNE./sigma_1-sigma_1./(A.^2+sigma_1.^2).*(alpha_1.*p_4+Q_obs-beta_1))./(1-sigma_1.^2./(A.^2+sigma_1.^2)).^(1./2) ;
VSB_sL_4 = (alpha_1.*p_4+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sL_4 = 1./2+1./2.*erf(1./2.*VSA_sL_4.*2.^(1./2)) ;
PSB_sL_4 = 1./2.*exp(-1./2.*VSB_sL_4.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sL_4 = 1./S_sL_4.*CSA_sL_4.*PSB_sL_4 ;
clear  CSA_sL_4  CSB_sL_4  CNL_sL_4  CNH_sL_4  PSA_sL_4  PSB_sL_4  PNL_sL_4  PNH_sL_4  VSA_sL_4  VSB_sL_4  VNL_sL_4  VNH_sL_4
S_sH_1 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sH_1 = -((A.^2+sigma_1.^2).*(-1./2.*R.*(alpha_1.*p_1-beta_1+k_1).*TUNE+A).*2.^(1./2)+sigma_1.^2.*(alpha_1.*p_1+Q_obs-beta_1).*TUNE)./(A.^2./(A.^2+sigma_1.^2)).^(1./2)./TUNE./sigma_1./(A.^2+sigma_1.^2) ;
VSB_sH_1 = (alpha_1.*p_1+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sH_1 = 1./2+1./2.*erf(1./2.*VSA_sH_1.*2.^(1./2)) ;
PSB_sH_1 = 1./2.*exp(-1./2.*VSB_sH_1.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_1 = 1./S_sH_1.*CSA_sH_1.*PSB_sH_1 ;
clear  CSA_sH_1  CSB_sH_1  CNL_sH_1  CNH_sH_1  PSA_sH_1  PSB_sH_1  PNL_sH_1  PNH_sH_1  VSA_sH_1  VSB_sH_1  VNL_sH_1  VNH_sH_1
S_sH_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_sH_2 = (1./2.*(R.*k_1.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_sH_2 = (Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
CSA_sH_2 = 1./2+1./2.*erf(1./2.*VSA_sH_2.*2.^(1./2)) ;
PSB_sH_2 = 1./2.*exp(-1./2.*VSB_sH_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_2 = 1./S_sH_2.*CSA_sH_2.*PSB_sH_2 ;
clear  CSA_sH_2  CSB_sH_2  CNL_sH_2  CNH_sH_2  PSA_sH_2  PSB_sH_2  PNL_sH_2  PNH_sH_2  VSA_sH_2  VSB_sH_2  VNL_sH_2  VNH_sH_2
S_sH_3 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sH_3 = -((A.^2+sigma_1.^2).*(-1./2.*R.*(alpha_1.*p_3-beta_1+k_3).*TUNE+A).*2.^(1./2)+sigma_1.^2.*(alpha_1.*p_3+Q_obs-beta_1).*TUNE)./(A.^2./(A.^2+sigma_1.^2)).^(1./2)./TUNE./sigma_1./(A.^2+sigma_1.^2) ;
VSB_sH_3 = (alpha_1.*p_3+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sH_3 = 1./2+1./2.*erf(1./2.*VSA_sH_3.*2.^(1./2)) ;
PSB_sH_3 = 1./2.*exp(-1./2.*VSB_sH_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_3 = 1./S_sH_3.*CSA_sH_3.*PSB_sH_3 ;
clear  CSA_sH_3  CSB_sH_3  CNL_sH_3  CNH_sH_3  PSA_sH_3  PSB_sH_3  PNL_sH_3  PNH_sH_3  VSA_sH_3  VSB_sH_3  VNL_sH_3  VNH_sH_3
S_sH_4 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sH_4 = 0 ;
VSB_sH_4 = (alpha_1.*p_4+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sH_4 = 1 ;
PSB_sH_4 = 1./2.*exp(-1./2.*VSB_sH_4.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_4 = 1./S_sH_4.*CSA_sH_4.*PSB_sH_4 ;
clear  CSA_sH_4  CSB_sH_4  CNL_sH_4  CNH_sH_4  PSA_sH_4  PSB_sH_4  PNL_sH_4  PNH_sH_4  VSA_sH_4  VSB_sH_4  VNL_sH_4  VNH_sH_4
S_kL_1 = (A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kL_1 = (1./2.*(R.*k_1.*TUNE-R.*TUNE.*(-alpha_1.*p_1+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_1.*(p_2-p_1).*TUNE-2.*A.*(p_2+p_1)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kL_1 = 2.*((1./2.*R.*(-p_2+p_1).*(k_1-Q_obs).*TUNE+A.*(p_2+p_1)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_2+p_1).*alpha_1+4.*A) ;
CSA_kL_1 = 1./2+1./2.*erf(1./2.*VSA_kL_1.*2.^(1./2)) ;
PSB_kL_1 = 1./2.*exp(-1./2.*VSB_kL_1.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kL_1 = 1./S_kL_1.*CSA_kL_1.*PSB_kL_1 ;
clear  CSA_kL_1  CSB_kL_1  CNL_kL_1  CNH_kL_1  PSA_kL_1  PSB_kL_1  PNL_kL_1  PNH_kL_1  VSA_kL_1  VSB_kL_1  VNL_kL_1  VNH_kL_1
S_kL_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kL_2 = (1./2.*(R.*k_1.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_2.*(p_3-p_2).*TUNE-2.*A.*(p_3+p_2)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kL_2 = 2.*((1./2.*R.*(-p_3+p_2).*(k_2-Q_obs).*TUNE+A.*(p_3+p_2)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_3+p_2).*alpha_1+4.*A) ;
CSA_kL_2 = 1./2+1./2.*erf(1./2.*VSA_kL_2.*2.^(1./2)) ;
PSB_kL_2 = 1./2.*exp(-1./2.*VSB_kL_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kL_2 = 1./S_kL_2.*CSA_kL_2.*PSB_kL_2 ;
clear  CSA_kL_2  CSB_kL_2  CNL_kL_2  CNH_kL_2  PSA_kL_2  PSB_kL_2  PNL_kL_2  PNH_kL_2  VSA_kL_2  VSB_kL_2  VNL_kL_2  VNH_kL_2
S_kL_3 = (A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kL_3 = (1./2.*(R.*k_3.*TUNE-R.*TUNE.*(-alpha_1.*p_3+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_3.*(p_4-p_3).*TUNE-2.*A.*(p_4+p_3)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kL_3 = 2.*((1./2.*R.*(-p_4+p_3).*(k_3-Q_obs).*TUNE+A.*(p_4+p_3)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_4+p_3).*alpha_1+4.*A) ;
CSA_kL_3 = 1./2+1./2.*erf(1./2.*VSA_kL_3.*2.^(1./2)) ;
PSB_kL_3 = 1./2.*exp(-1./2.*VSB_kL_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kL_3 = 1./S_kL_3.*CSA_kL_3.*PSB_kL_3 ;
clear  CSA_kL_3  CSB_kL_3  CNL_kL_3  CNH_kL_3  PSA_kL_3  PSB_kL_3  PNL_kL_3  PNH_kL_3  VSA_kL_3  VSB_kL_3  VNL_kL_3  VNH_kL_3
S_kH_1 = (A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kH_1 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_1.*(p_2-p_1).*TUNE-2.*A.*(p_2+p_1)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kH_1 = 2.*((1./2.*R.*(-p_2+p_1).*(k_1-Q_obs).*TUNE+A.*(p_2+p_1)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_2+p_1).*alpha_1+4.*A) ;
CSA_kH_1 = 1./2+1./2.*erf(1./2.*VSA_kH_1.*2.^(1./2)) ;
PSB_kH_1 = 1./2.*exp(-1./2.*VSB_kH_1.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kH_1 = 1./S_kH_1.*CSA_kH_1.*PSB_kH_1 ;
clear  CSA_kH_1  CSB_kH_1  CNL_kH_1  CNH_kH_1  PSA_kH_1  PSB_kH_1  PNL_kH_1  PNH_kH_1  VSA_kH_1  VSB_kH_1  VNL_kH_1  VNH_kH_1
S_kH_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kH_2 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_3+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_2.*(p_3-p_2).*TUNE-2.*A.*(p_3+p_2)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kH_2 = 2.*((1./2.*R.*(-p_3+p_2).*(k_2-Q_obs).*TUNE+A.*(p_3+p_2)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_3+p_2).*alpha_1+4.*A) ;
CSA_kH_2 = 1./2+1./2.*erf(1./2.*VSA_kH_2.*2.^(1./2)) ;
PSB_kH_2 = 1./2.*exp(-1./2.*VSB_kH_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kH_2 = 1./S_kH_2.*CSA_kH_2.*PSB_kH_2 ;
clear  CSA_kH_2  CSB_kH_2  CNL_kH_2  CNH_kH_2  PSA_kH_2  PSB_kH_2  PNL_kH_2  PNH_kH_2  VSA_kH_2  VSB_kH_2  VNL_kH_2  VNH_kH_2
S_kH_3 = (A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kH_3 = (1./2.*(R.*k_3.*TUNE-R.*TUNE.*(-alpha_1.*p_4+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_3.*(p_4-p_3).*TUNE-2.*A.*(p_4+p_3)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kH_3 = 2.*((1./2.*R.*(-p_4+p_3).*(k_3-Q_obs).*TUNE+A.*(p_4+p_3)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_4+p_3).*alpha_1+4.*A) ;
CSA_kH_3 = 1./2+1./2.*erf(1./2.*VSA_kH_3.*2.^(1./2)) ;
PSB_kH_3 = 1./2.*exp(-1./2.*VSB_kH_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kH_3 = 1./S_kH_3.*CSA_kH_3.*PSB_kH_3 ;
clear  CSA_kH_3  CSB_kH_3  CNL_kH_3  CNH_kH_3  PSA_kH_3  PSB_kH_3  PNL_kH_3  PNH_kH_3  VSA_kH_3  VSB_kH_3  VNL_kH_3  VNH_kH_3
h_SHR=(   hh_sH_1+(hh_kH_1-hh_kL_1)+(hh_sH_2-hh_sL_2)+(hh_kH_2-hh_kL_2)+  (hh_sH_3-hh_sL_3)+(hh_kH_3-hh_kL_3)+(hh_sH_4-hh_sL_4)   );
A=REG(:,1);
sigma_1=REG(:,2);
alpha_1=REG(:,3);
beta_1=REG(:,4);
S_sL_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_sL_2 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_sL_2 = (Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
CSA_sL_2 = 1./2+1./2.*erf(1./2.*VSA_sL_2.*2.^(1./2)) ;
PSB_sL_2 = 1./2.*exp(-1./2.*VSB_sL_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sL_2 = 1./S_sL_2.*CSA_sL_2.*PSB_sL_2 ;
clear  CSA_sL_2  CSB_sL_2  CNL_sL_2  CNH_sL_2  PSA_sL_2  PSB_sL_2  PNL_sL_2  PNH_sL_2  VSA_sL_2  VSB_sL_2  VNL_sL_2  VNH_sL_2
S_sL_3 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sL_3 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_3+beta_1)+2.*A).*R./TUNE./sigma_1-sigma_1./(A.^2+sigma_1.^2).*(alpha_1.*p_3+Q_obs-beta_1))./(1-sigma_1.^2./(A.^2+sigma_1.^2)).^(1./2) ;
VSB_sL_3 = (alpha_1.*p_3+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sL_3 = 1./2+1./2.*erf(1./2.*VSA_sL_3.*2.^(1./2)) ;
PSB_sL_3 = 1./2.*exp(-1./2.*VSB_sL_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sL_3 = 1./S_sL_3.*CSA_sL_3.*PSB_sL_3 ;
clear  CSA_sL_3  CSB_sL_3  CNL_sL_3  CNH_sL_3  PSA_sL_3  PSB_sL_3  PNL_sL_3  PNH_sL_3  VSA_sL_3  VSB_sL_3  VNL_sL_3  VNH_sL_3
S_sL_4 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sL_4 = (1./2.*(R.*k_3.*TUNE-R.*TUNE.*(-alpha_1.*p_4+beta_1)+2.*A).*R./TUNE./sigma_1-sigma_1./(A.^2+sigma_1.^2).*(alpha_1.*p_4+Q_obs-beta_1))./(1-sigma_1.^2./(A.^2+sigma_1.^2)).^(1./2) ;
VSB_sL_4 = (alpha_1.*p_4+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sL_4 = 1./2+1./2.*erf(1./2.*VSA_sL_4.*2.^(1./2)) ;
PSB_sL_4 = 1./2.*exp(-1./2.*VSB_sL_4.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sL_4 = 1./S_sL_4.*CSA_sL_4.*PSB_sL_4 ;
clear  CSA_sL_4  CSB_sL_4  CNL_sL_4  CNH_sL_4  PSA_sL_4  PSB_sL_4  PNL_sL_4  PNH_sL_4  VSA_sL_4  VSB_sL_4  VNL_sL_4  VNH_sL_4
S_sH_1 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sH_1 = -((A.^2+sigma_1.^2).*(-1./2.*R.*(alpha_1.*p_1-beta_1+k_1).*TUNE+A).*2.^(1./2)+sigma_1.^2.*(alpha_1.*p_1+Q_obs-beta_1).*TUNE)./(A.^2./(A.^2+sigma_1.^2)).^(1./2)./TUNE./sigma_1./(A.^2+sigma_1.^2) ;
VSB_sH_1 = (alpha_1.*p_1+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sH_1 = 1./2+1./2.*erf(1./2.*VSA_sH_1.*2.^(1./2)) ;
PSB_sH_1 = 1./2.*exp(-1./2.*VSB_sH_1.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_1 = 1./S_sH_1.*CSA_sH_1.*PSB_sH_1 ;
clear  CSA_sH_1  CSB_sH_1  CNL_sH_1  CNH_sH_1  PSA_sH_1  PSB_sH_1  PNL_sH_1  PNH_sH_1  VSA_sH_1  VSB_sH_1  VNL_sH_1  VNH_sH_1
S_sH_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_sH_2 = (1./2.*(R.*k_1.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_sH_2 = (Q_obs-((p_3.*k_2-p_1.*k_1-p_2.*(k_2-k_1)).*alpha_1.*TUNE.*R-2.*((p_3+p_1).*alpha_1-2.*beta_1).*A)./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
CSA_sH_2 = 1./2+1./2.*erf(1./2.*VSA_sH_2.*2.^(1./2)) ;
PSB_sH_2 = 1./2.*exp(-1./2.*VSB_sH_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_2 = 1./S_sH_2.*CSA_sH_2.*PSB_sH_2 ;
clear  CSA_sH_2  CSB_sH_2  CNL_sH_2  CNH_sH_2  PSA_sH_2  PSB_sH_2  PNL_sH_2  PNH_sH_2  VSA_sH_2  VSB_sH_2  VNL_sH_2  VNH_sH_2
S_sH_3 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sH_3 = -((A.^2+sigma_1.^2).*(-1./2.*R.*(alpha_1.*p_3-beta_1+k_3).*TUNE+A).*2.^(1./2)+sigma_1.^2.*(alpha_1.*p_3+Q_obs-beta_1).*TUNE)./(A.^2./(A.^2+sigma_1.^2)).^(1./2)./TUNE./sigma_1./(A.^2+sigma_1.^2) ;
VSB_sH_3 = (alpha_1.*p_3+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sH_3 = 1./2+1./2.*erf(1./2.*VSA_sH_3.*2.^(1./2)) ;
PSB_sH_3 = 1./2.*exp(-1./2.*VSB_sH_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_3 = 1./S_sH_3.*CSA_sH_3.*PSB_sH_3 ;
clear  CSA_sH_3  CSB_sH_3  CNL_sH_3  CNH_sH_3  PSA_sH_3  PSB_sH_3  PNL_sH_3  PNH_sH_3  VSA_sH_3  VSB_sH_3  VNL_sH_3  VNH_sH_3
S_sH_4 = (A.^2+sigma_1.^2).^(1./2) ;
VSA_sH_4 = 0 ;
VSB_sH_4 = (alpha_1.*p_4+Q_obs-beta_1)./(A.^2+sigma_1.^2).^(1./2) ;
CSA_sH_4 = 1 ;
PSB_sH_4 = 1./2.*exp(-1./2.*VSB_sH_4.^2).*2.^(1./2)./pi.^(1./2) ;
hh_sH_4 = 1./S_sH_4.*CSA_sH_4.*PSB_sH_4 ;
clear  CSA_sH_4  CSB_sH_4  CNL_sH_4  CNH_sH_4  PSA_sH_4  PSB_sH_4  PNL_sH_4  PNH_sH_4  VSA_sH_4  VSB_sH_4  VNL_sH_4  VNH_sH_4
S_kL_1 = (A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kL_1 = (1./2.*(R.*k_1.*TUNE-R.*TUNE.*(-alpha_1.*p_1+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_1.*(p_2-p_1).*TUNE-2.*A.*(p_2+p_1)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kL_1 = 2.*((1./2.*R.*(-p_2+p_1).*(k_1-Q_obs).*TUNE+A.*(p_2+p_1)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_2+p_1).*alpha_1+4.*A) ;
CSA_kL_1 = 1./2+1./2.*erf(1./2.*VSA_kL_1.*2.^(1./2)) ;
PSB_kL_1 = 1./2.*exp(-1./2.*VSB_kL_1.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kL_1 = 1./S_kL_1.*CSA_kL_1.*PSB_kL_1 ;
clear  CSA_kL_1  CSB_kL_1  CNL_kL_1  CNH_kL_1  PSA_kL_1  PSB_kL_1  PNL_kL_1  PNH_kL_1  VSA_kL_1  VSB_kL_1  VNL_kL_1  VNH_kL_1
S_kL_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kL_2 = (1./2.*(R.*k_1.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_2.*(p_3-p_2).*TUNE-2.*A.*(p_3+p_2)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kL_2 = 2.*((1./2.*R.*(-p_3+p_2).*(k_2-Q_obs).*TUNE+A.*(p_3+p_2)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_3+p_2).*alpha_1+4.*A) ;
CSA_kL_2 = 1./2+1./2.*erf(1./2.*VSA_kL_2.*2.^(1./2)) ;
PSB_kL_2 = 1./2.*exp(-1./2.*VSB_kL_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kL_2 = 1./S_kL_2.*CSA_kL_2.*PSB_kL_2 ;
clear  CSA_kL_2  CSB_kL_2  CNL_kL_2  CNH_kL_2  PSA_kL_2  PSB_kL_2  PNL_kL_2  PNH_kL_2  VSA_kL_2  VSB_kL_2  VNL_kL_2  VNH_kL_2
S_kL_3 = (A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kL_3 = (1./2.*(R.*k_3.*TUNE-R.*TUNE.*(-alpha_1.*p_3+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_3.*(p_4-p_3).*TUNE-2.*A.*(p_4+p_3)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kL_3 = 2.*((1./2.*R.*(-p_4+p_3).*(k_3-Q_obs).*TUNE+A.*(p_4+p_3)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_4+p_3).*alpha_1+4.*A) ;
CSA_kL_3 = 1./2+1./2.*erf(1./2.*VSA_kL_3.*2.^(1./2)) ;
PSB_kL_3 = 1./2.*exp(-1./2.*VSB_kL_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kL_3 = 1./S_kL_3.*CSA_kL_3.*PSB_kL_3 ;
clear  CSA_kL_3  CSB_kL_3  CNL_kL_3  CNH_kL_3  PSA_kL_3  PSB_kL_3  PNL_kL_3  PNH_kL_3  VSA_kL_3  VSB_kL_3  VNL_kL_3  VNH_kL_3
S_kH_1 = (A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kH_1 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_2+beta_1)-2.*A).*2.^(1./2)./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_1.*(p_2-p_1).*TUNE-2.*A.*(p_2+p_1)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kH_1 = 2.*((1./2.*R.*(-p_2+p_1).*(k_1-Q_obs).*TUNE+A.*(p_2+p_1)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_2-p_1).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_2+p_1).*alpha_1+4.*A) ;
CSA_kH_1 = 1./2+1./2.*erf(1./2.*VSA_kH_1.*2.^(1./2)) ;
PSB_kH_1 = 1./2.*exp(-1./2.*VSB_kH_1.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kH_1 = 1./S_kH_1.*CSA_kH_1.*PSB_kH_1 ;
clear  CSA_kH_1  CSB_kH_1  CNL_kH_1  CNH_kH_1  PSA_kH_1  PSB_kH_1  PNL_kH_1  PNH_kH_1  VSA_kH_1  VSB_kH_1  VNL_kH_1  VNH_kH_1
S_kH_2 = (A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kH_2 = (1./2.*(R.*k_2.*TUNE-R.*TUNE.*(-alpha_1.*p_3+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_2.*(p_3-p_2).*TUNE-2.*A.*(p_3+p_2)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kH_2 = 2.*((1./2.*R.*(-p_3+p_2).*(k_2-Q_obs).*TUNE+A.*(p_3+p_2)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_3-p_2).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_3+p_2).*alpha_1+4.*A) ;
CSA_kH_2 = 1./2+1./2.*erf(1./2.*VSA_kH_2.*2.^(1./2)) ;
PSB_kH_2 = 1./2.*exp(-1./2.*VSB_kH_2.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kH_2 = 1./S_kH_2.*CSA_kH_2.*PSB_kH_2 ;
clear  CSA_kH_2  CSB_kH_2  CNL_kH_2  CNH_kH_2  PSA_kH_2  PSB_kH_2  PNL_kH_2  PNH_kH_2  VSA_kH_2  VSB_kH_2  VNL_kH_2  VNH_kH_2
S_kH_3 = (A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2) ;
VSA_kH_3 = (1./2.*(R.*k_3.*TUNE-R.*TUNE.*(-alpha_1.*p_4+beta_1)+2.*A).*R./TUNE./sigma_1-4.*A./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).*sigma_1./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).*(Q_obs-((R.*k_3.*(p_4-p_3).*TUNE-2.*A.*(p_4+p_3)).*alpha_1+4.*beta_1.*A)./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A)))./(1-16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2)).^(1./2) ;
VSB_kH_3 = 2.*((1./2.*R.*(-p_4+p_3).*(k_3-Q_obs).*TUNE+A.*(p_4+p_3)).*alpha_1+2.*A.*(Q_obs-beta_1))./(A.^2+16.*A.^2./(R.*TUNE.*(p_4-p_3).*alpha_1+4.*A).^2.*sigma_1.^2).^(1./2)./(-R.*TUNE.*(-p_4+p_3).*alpha_1+4.*A) ;
CSA_kH_3 = 1./2+1./2.*erf(1./2.*VSA_kH_3.*2.^(1./2)) ;
PSB_kH_3 = 1./2.*exp(-1./2.*VSB_kH_3.^2).*2.^(1./2)./pi.^(1./2) ;
hh_kH_3 = 1./S_kH_3.*CSA_kH_3.*PSB_kH_3 ;
clear  CSA_kH_3  CSB_kH_3  CNL_kH_3  CNH_kH_3  PSA_kH_3  PSB_kH_3  PNL_kH_3  PNH_kH_3  VSA_kH_3  VSB_kH_3  VNL_kH_3  VNH_kH_3
h_REG=(   hh_sH_1+(hh_kH_1-hh_kL_1)+(hh_sH_2-hh_sL_2)+(hh_kH_2-hh_kL_2)+  (hh_sH_3-hh_sL_3)+(hh_kH_3-hh_kL_3)+(hh_sH_4-hh_sL_4)   );
ll=-1.*sum(log(    lambda.*h_SHR + (1-lambda).*h_REG   ));
