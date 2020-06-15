function  [h,share_out] = ppressure4(input,Nobs,pi,pr,alpha0,alpha1,theta,y,mru_c,year,post,baD,given)

c   = input(1);
sig = input(2);
t   = input(3);
N   = input(4:end);


sig = 2000;

% c   = input(1);
% sig = given(2);
% t   = input(2);
% N   = input(3:end);
% t = given(3);
% N = given(4:end);

Nb = baD*N;

%%% QUALITY MATTERS, BUT THE DECISION IS ONLY RELEVANT BEFORE FIXING
u1 = unl( 0  ,alpha0,alpha1,pi,pr,theta,y) ;
u2 = unl( 0  ,alpha0,alpha1,0 ,0 ,theta,y-c) ;

Bprob2=normcdf(u2-u1,0,sig);
mean(Bprob2)

hist(Bprob2(Bprob2>0))


[~,~,iy] = unique( mru_c );  
share_exp = accumarray(iy,Bprob2,[],@mean);
share_out = mean(share_exp);
% mean(share)
share = repelem(share_exp,size(unique(year),1)).*(post==0);

Npred = (Nb + year.*t).*(1-share);

h = mean( (Nobs-Npred).^2 )./(mean(Nobs).^2) ;
% + ((std(Nobs)-std(Npred)).^2)./(std(Nobs).^2);

end