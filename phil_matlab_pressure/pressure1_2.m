


clear

c = 3000;

sig = 3;
alpha0m = 60;
alpha1 = -.2;
gamma = .5;
theta = .2;
y = 10000;

t = 1;

ns = 50;  % sample size
nt = 8;   % time periods
nm = 5;   % mrus

nmt = nt*nm; % mru by time
nmts = nt*nm*ns; % mru by time by sample

rng(1);

SC = 100;

N = (20:20+nm-1)';
N_nt       = repelem(  N      ,nt,1) ;
year    = repmat(   (8:8+nt-1)'  ,nm,1) ;
mru     = repelem((1:nm)',nt,1);
mru_year  = mru*10000+year;
mru_year_ind = repelem(mru_year,ns,1);

post = (year>=2012 | mru<=2);

S  = 1;
p = normrnd(50,10,nmts,1);

e  = evrnd(0,1,nmts,2);
ep = normrnd(0,5,nmts,1);
alpha0 = alpha0m+ep;

u1 = up(  S ,alpha0,alpha1,p ,theta,y)./SC + e(:,1);
u2 = up(  S ,alpha0,alpha1,0 ,theta,y - c)./SC + e(:,2);
mean(u2>u1)

Bobs =  (u2>u1).*(repelem(post,ns,1)==0);

[~,~,iy] = unique( mru_year_ind );  
share    = accumarray(iy,Bobs,[],@mean);

Nobs = (N_nt + year.*t).*(1-share);

given = [c; t; N];

obj=@(input1)lpressure1_2(input1,Nobs,p,alpha0,alpha1,theta,S,y,SC,ns,nt,mru_year_ind,year,post,given)

% given
input = .9.*[c; t; N];

out   = fminunc(obj,input)
 
tbl=table(Nobs,share);
lme =fitlme(tbl,'Nobs~share');
[beta,betanames] = fixedEffects(lme);



[given(1) input(1) out(1)]

[given(2:end) input(2:end) out(2:end)]


% u1s = up(  S ,alpha0 ,alpha1,p,theta,y)./SC + e(:,1);
% u2s = up(  S ,alpha0 ,alpha1,0,theta,y - 2.*c )./SC + e(:,2);
% mean(u2s>u1s)
% [ud,ix,iy]=   unique( mru_year_ind );  
% output    = [ud, accumarray(iy,Bobs,[],@mean)];
