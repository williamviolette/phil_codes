


clear



% to do:
% (1) identify c? (understand identification in general) [ NO ASSUME IT! ]
    % * FROM FUNCTIONAL FORM see whether the estimates are reasonable
% (2) robust to SC?   [ ESTIMATED! ]
% (3) get the right solutions?   maybe dig deeper here...
% (4) DO EXPECTED UTILITY! DO NON-LINEAR PRICING! (think about rental of booster pump)
     % no expected utility!  rental market each period! ! 
     
% (5) run counterfactuals?? COMPARE welfare with and without   [ yes! ]

% order:  do counterfactuals with current model
     %    then test assumptions of model
            % model assumes that large users are more likeily
     %    then think about adding proper utility and price 

% 1 HP engine uses 0.786 Kw/Hour , meaning a .5 HP engine uses .786/2=.3930
% price .2 USD * 44 PhP/USD = 8.8 PhP per KwH
% 30days*2.6hrs*8.8 per KwH * .393 Kwh = 269.8
% btw .25 and 1 hp engines used in Manila
%  .5*270/2 + .5*270*2 = 338 PhP
     
data=0;
if data==1
      cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_2nl.csv');
        wobs    = cs(:,1);
        Bobs    = cs(:,2);
        post    = cs(:,3);
        p_i      = cs(:,4);
        pr      = cs(:,5);
        year    = cs(:,6);
        cmax    = cs(:,7);
        cmin    = cs(:,8);
        hhsize  = cs(:,9);
        hhemp   = cs(:,10); 
        good_job= cs(:,11);
        sho     = cs(:,12);
else
    rng(3)
    n = 80000;
%     A = 50 + rand(n,1);
    p_i = 5 + 30.*rand(n,1);
%     p_r = .3;

end

% alpha0 =  [28;   .1;  3;   -1.7;   2.5]  ;
% A  = [ ones(size(wobs,1),1)  year cmax cmin hhsize];

alpha0 = .1.*[5 4 6 7 ]';

A  = [   (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1)) ];

T  = [   (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1))   ];
Tb = [   (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1))   ];
sig    = 10;
alpha1 = .8;
theta1 =  .1.*[4 2 3]';
siga = 400;

y = 10000;
c = 100;

ep  = normrnd(0,sig,n,1);
epa = normrnd(0,siga,n,1);

ub = upnl(A*alpha0,0,0,Tb*theta1,0,0,alpha1,0,0,p_i,0,0,y-c);
un = upnl(A*alpha0,0,0,T*theta1,0,0,alpha1,0,0,p_i,0,0,y);

bobs=ub-un>epa;
mean(bobs)

wobs = wpnl(A*alpha0,0,0,T*theta1,0,0,alpha1,0,0,p_i,0,0) + ep;

given  = [siga];

obj=@(input1)lbooster_gh6(input1,A,T,Tb,wobs,bobs,p_i,y,c,given);
% obj_old=@(input1)lbooster_gh4(input1,A,T,wobs,p_i,p_r,given);

input = .9.*[alpha0; theta1; alpha1; sig];

[t1,t2,t3]=obj(input)


options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');
% tic
% input
% out=fminunc(obj_old,input,options)
% obj(out)
% toc

tic
input
out=fminunc(obj,input,options)
obj(out)
toc
