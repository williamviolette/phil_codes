function  h = lpressure1_2(input,Nobs,p,alpha0,alpha1,theta,S,y,SC,ns,nt,mru_year_ind,year,post,given)

c   = input(1);
t   = input(2);
N   = input(3:end);

N_nt       = repelem(  N      ,nt,1) ;

v1 = exp( up(  S  ,alpha0,alpha1,p,theta,y)./SC                );
v2 = exp( up(  S  ,alpha0,alpha1,0,theta,y - c)./SC  );

Bprob2=(v2./(v1 + v2)).*(repelem(post,ns,1)==0);

[~,~,iy] = unique( mru_year_ind );  
share    = accumarray(iy,Bprob2,[],@mean);

Npred = (N_nt + year.*t).*(1-share);

h =sum( (Nobs-Npred).^2 );

end