function  [h,share_out] = lpressure6(input,Nobs,pi,pr,alpha0,alpha1,theta,y,mru_c,year,post,baD,cD,cDN,SC,given)


c   = input(1:size(cD,2));
% sig = input(2);
t   = input(size(cD,2)+1);
cN  = input(size(cD,2)+2:size(cD,2)+size(cDN,2)+1);
N   = input(size(cD,2)+size(cDN,2)+2:end);

% SC  = 1000;
% sig = 2000;
% c   = input(1);
% sig = given(2);
% t   = input(2);
% N   = input(3:end);
% t   = given(3);
% N   = given(4:end);

cb = cD*c  ;
cn = cDN*cN  ;
Nb = baD*N ;


%%% QUALITY MATTERS, BUT THE DECISION IS ONLY RELEVANT BEFORE FIXING
u1 = unl( 0 ,alpha0,alpha1,pi,pr,theta,y)./SC    ;
u2 = unl( 0 ,alpha0,alpha1,0 ,0 ,theta,y-cb)./SC ;

Bprob2=exp(u2)./(exp(u1)+exp(u2));

% mean(Bprob2)
% hist(Bprob2(Bprob2>0))

[~,~,iy] = unique( mru_c );  
share_exp = accumarray(iy,Bprob2,[],@mean);
share_out = mean(share_exp);
% mean(share)
share = repelem(share_exp,size(unique(year),1)).*(post==0);

cnn = repelem(accumarray(iy,cn,[],@mean),size(unique(year),1)).*(post==0);

Npred = (Nb + cnn + year.*t).*(1-share);

h = mean( (Nobs-Npred).^2 )./(mean(Nobs).^2) ;
% + ((std(Nobs)-std(Npred)).^2)./(std(Nobs).^2);

end