


clear

sim=0;


if sim==1
    alpha0m = 60;
    alpha1 = -.2;
    theta = .2;
    ns = 50;  % sample size
    nt = 8;   % time periods
    nm = 5;   % mrus

    nmt = nt*nm; % mru by time
    nmts = nt*nm*ns; % mru by time by sample
    rng(1);

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
else
    
    cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/conacct_sample.csv');
        mru_c   = cs(:,2);
        p       = cs(:,3);
        alpha0  = cs(:,4);
        alpha1  = -1.*cs(:,5);
        theta   = cs(:,6);
    ms = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/mru_sample.csv');
        mru_m   = ms(:,1);
        year    = ms(:,2);
        post    = ms(:,3);
        ba      = ms(:,4);
        baD     = dummyvar(ba);
        Nobs    = ms(:,5);
end



c = 600;

sig = 3;
y = 10000;
t = 17.6;

[~,~,iy] = unique( ba );  
N = accumarray(iy,Nobs,[],@mean);
N = N- t.*mean(year);

SC = 200;

given = [c; t; N];

input = [c; t; N]

obj=@(input1)lpressure1_3(input1,Nobs,p,alpha0,alpha1,theta,y,SC,mru_c,year,post,baD,given)

% given
obj(input)

out   = fminunc(obj,input)

obj(out)



% u1s = up(  S ,alpha0 ,alpha1,p,theta,y)./SC + e(:,1);
% u2s = up(  S ,alpha0 ,alpha1,0,theta,y - 2.*c )./SC + e(:,2);
% mean(u2s>u1s)
% [ud,ix,iy]=   unique( mru_year_ind );  
% output    = [ud, accumarray(iy,Bobs,[],@mean)];
