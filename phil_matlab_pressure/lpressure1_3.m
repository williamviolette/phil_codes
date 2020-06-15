function  h = lpressure1_3(input,Nobs,p,alpha0,alpha1,theta,y,SC,mru_c,year,post,baD,given)

c   = input(1);
t   = input(2);
N   = input(3:end);

Nb = baD*N;
%c = 200
% N_nt       = repelem(  N      ,nt,1) ;

%%% YES IT DOES, BUT THE DECISION IS ONLY RELEVANT BEFORE FIXING
u1 = up( 0  ,alpha0,alpha1,p,theta,y)./SC ;
u2 = up( 0  ,alpha0,alpha1,0,theta,y-c)./SC ;
% mean(u1>u2)
v1 = exp(u1);
v2 = exp(u2);

Bprob2=(v2./(v1 + v2));
[~,~,iy] = unique( mru_c );  
share = accumarray(iy,Bprob2,[],@mean);
% mean(share)
share = repelem(share,size(unique(year),1)).*(post==0);

Npred = (Nb + year.*t).*(1-share);

h =sum( (Nobs-Npred).^2 );

end