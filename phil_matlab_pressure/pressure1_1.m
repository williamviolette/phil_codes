


clear


c = 1500;

sig = 3;
alpha0 =  60;
alpha1 = -.2;

gamma = .5;

theta = .2;

n = 30000;

Nt = 

rng(1);

SC = 100;

y = 10000;
S  = 1+1.*rand(n,1);
p = normrnd(50,10,n,1);

e  = evrnd(0,1,n,2);
ep = normrnd(0,sig,n,2);

u1 = up(  S  ,alpha0,alpha1,p,theta,y)./SC + e(:,1);
u2 = up(  S  ,alpha0,alpha1,0 ,theta,y - c)./SC + e(:,2);
mean(u2>u1)

u1s = up(  S  , alpha0 ,alpha1,p,theta,y)./SC + e(:,1);
u2s = up(  S  , alpha0 ,alpha1,0,theta,y - 2.*c )./SC + e(:,2);
mean(u2s>u1s)

w1 = wp(  S ,alpha0,alpha1,p,theta)  + ep(:,1);
w2 = wp(  S ,alpha0,alpha1,0,theta)  + ep(:,2);

Bobs = 1.*(u1>u2) + 2.*(u2>u1);
mean(Bobs)

wobs = w1.*(u1>u2) + w2.*(u2>u1);
mean(wobs)

given = [alpha0 alpha1 theta c sig];

obj=@(input1)lpressure1(input1,Bobs,wobs,p,S,y,SC,given);

given
input = .9.*[alpha0 alpha1 theta c sig]

% input= [alpha0 alpha1 1.1.*theta0 theta1 1.1.*gamma sig]

out   = fminunc(obj,input)
 


