


clear


c = 500;

sig = 3;
alpha0 =  60;
alpha1 = .2;

gamma = .5;

% theta0 = .2;
theta = 1;

n = 50000;

rng(1);

SC = 100;

y = 10000;
S  = 1+1.*rand(n,1);
S=0;
B = 1;
p = normrnd(50,10,n,1);

e  = evrnd(0,1,n,2);
ep = normrnd(0,sig,n,2);

u1 = up(  S  ,alpha0,alpha1,p,theta,y)./SC + e(:,1);
u2 = up(  S +B ,alpha0,alpha1,p ,theta,y - c)./SC + e(:,2);
mean(u2>u1)

u1s = up(  S  , alpha0 ,alpha1,p,theta,y)./SC + e(:,1);
u2s = up(  S + B  , alpha0 ,alpha1,p,theta,y - 2.*c )./SC + e(:,2);
mean(u2s>u1s)

wobs1 = wp(  S ,alpha0,alpha1,p,theta)  + ep(:,1);
wobs2 = wp(  S + B ,alpha0,alpha1,p,theta)  + ep(:,2);

Bobs = 1.*(u1>u2) + 2.*(u2>u1);
mean(Bobs)

wobs = wobs1.*(u1>u2) + wobs2.*(u2>u1);
mean(wobs)

given = [alpha0 alpha1 theta sig];

obj=@(input1)lbooster1(input1,Bobs,wobs,p,S,y,SC,c,B,given);

given
input= .9.*[alpha0 alpha1 theta sig]

% input= [alpha0 alpha1 1.1.*theta0 theta1 1.1.*ga8mma sig]

out=fminunc(obj,input)



