


clear


c = 500;

sig = 3;
alpha0 =  60;
alpha1 = .2;

gamma = .5;

% theta0 = .2;
theta1 = 4;
theta2 = 8;
theta3 = -2;

SC = 100;

y = 10000;

data=1;
if data==1
    cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_1.csv');
        wobs    = cs(:,1);
        Bobs    = cs(:,2);
        post    = cs(:,3);
        p       = cs(:,4);
        year    = cs(:,5);
        cmax    = cs(:,6);
        cmin    = cs(:,7);
        hhsize  = cs(:,8);
else
    n = 1000000;
    rng(1);
    B = 1;
    p = normrnd(50,10,n,1);
    post = rand(n,1)>.5;

    e  = evrnd(0,1,n,2);
    ep = normrnd(0,sig,n,2);

    u1 = up1(  alpha0,alpha1,p,theta1.*(1-B) + post.*theta2 + post.*(1-B).*theta3,y)./SC + e(:,1);
    u2 = up1(  alpha0,alpha1,p,theta1.*B + post.*theta2 + post.*(B).*theta3,y - c)./SC + e(:,2);
    mean(u2>u1)

    u1s = up1(  alpha0 ,alpha1,p,theta1.*(1-B) + post.*theta2 + post.*(1-B).*theta3 ,y)./SC + e(:,1);
    u2s = up1(  alpha0 ,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3,y - 2.*c )./SC + e(:,2);
    mean(u2s>u1s)

    wobs1 = wp1( alpha0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3)  + ep(:,1);
    wobs2 = wp1( alpha0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3)  + ep(:,2);

    Bobs = 1.*(u1>u2) + 2.*(u2>u1);
    mean(Bobs)

    wobs = wobs1.*(u1>u2) + wobs2.*(u2>u1);
    mean(wobs)

    mean(wobs(Bobs==1 & post==0))
    mean(wobs(Bobs==2 & post==0))
    mean(wobs(Bobs==1 & post==1))
    mean(wobs(Bobs==2 & post==1))

    %%% These results match the empirics!!
    disp 'Post-Pre for No Booster'
    mean(wobs(Bobs==1 & post==1)) - mean(wobs(Bobs==1 & post==0))
    disp 'Post-Pre for Booster'
    mean(wobs(Bobs==2 & post==1)) - mean(wobs(Bobs==2 & post==0))

    disp 'booster pre'
    mean(Bobs==2 & post==0)
    disp 'booster post'
    mean(Bobs==2 & post==1)
end

given = [alpha0 alpha1 theta1 theta2 theta3 sig];

obj=@(input1)lbooster1_1(input1,Bobs,wobs,p,y,SC,c,B,post,given);

given
input= .9.*[alpha0 alpha1 theta1 theta2 theta3 sig]

% input= [alpha0 alpha1 1.1.*theta0 theta1 1.1.*ga8mma sig]

out=fminunc(obj,input)



