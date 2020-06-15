function  h = ppressure1_3(input,Nobs,p,alpha0,alpha1,theta,y,mru_c,year,post,baD,given)

c   = input(1);
sig = input(2);
t   = input(3);
N   = input(4:end);
% t = given(3);
% N = given(4:end);

Nb = baD*N;

%%% QUALITY MATTERS, BUT THE DECISION IS ONLY RELEVANT BEFORE FIXING
u1 = up( 0  ,alpha0,alpha1,p,theta,y) ;
u2 = up( 0  ,alpha0,alpha1,0,theta,y-c) ;

Bprob2=normcdf(u2-u1,0,sig);
% mean(Bprob2)

[~,~,iy] = unique( mru_c );  
share = accumarray(iy,Bprob2,[],@mean);
% mean(share)
share = repelem(share,size(unique(year),1)).*(post==0);

Npred = (Nb + year.*t).*(1-share);

h = sum( (Nobs-Npred).^2 );

end