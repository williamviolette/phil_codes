


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
     
c = 338;

% y = 21907;
y = 1000;

data=1;
if data==1
%     cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_1.csv');
%     cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_1ch.csv');
      cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_2.csv');
        wobs    = cs(:,1);
        Bobs    = cs(:,2);
        post    = cs(:,3);
        p       = cs(:,4);
        year    = cs(:,5);
        cmax    = cs(:,6);
        cmin    = cs(:,7);
        hhsize  = cs(:,8);
        hhemp   = cs(:,9); 
        good_job= cs(:,10);
        sho     = cs(:,11);
        
end

% alpha0 =  [28;   .1;  3;   -1.7;   2.5]  ;
% A  = [ ones(size(wobs,1),1)  year cmax cmin hhsize];

sig    = 14;
alpha1 = .3;
theta1 =  3.5;

theta3 =  -1.5;

% alpha0 =  [18;                1.3;     .5;  3.3;   -3;  -.04; 2.4   ];
% A  = [ ones(size(wobs,1),1)  hhsize hhemp good_job sho year cmax  ];

%%% non- parametric for HHsize?!

alpha0 =  [14;                1.5 ;  3.3 ;     3 ; .5   ];
A  = [ ones(size(wobs,1),1)  hhsize  good_job  cmax hhemp ];

T = [ ones(size(wobs,1),1)  good_job ];
theta2 = [ 2.5 ;  .5 ];

given  = [alpha0; sig; alpha1; theta1; theta3; 120; theta2];

obj=@(input1)lbooster1_6(input1,Bobs,wobs,p,y,c,post,A,T,given);

input = [alpha0; sig; alpha1; theta1; theta3; 120; theta2];
obj(input)
tic
out=fminunc(obj,input)
obj(out)
toc
tic
out1=fminunc(obj,out)
obj(out1)
toc
tic
out2=fminunc(obj,out1)
obj(out2)
toc

out=out2;



b = regress(wobs,[A p Bobs post (post.*good_job)])



b = regress(wobs,[p post A])

alpha0 = A*b(3:end);
theta1 = b(2);
alpha1 = -1.*b(1);
alpha1 = .32;
pi=p;

t2 = 1.0./alpha1;
u1 = y-alpha0.*pi-pi.*theta1+(alpha1.*pi.^2)./2.0+(t2.*theta1.^2)./2.0+alpha0.*t2.*theta1;
theta1=0;
u1_pre =  y-alpha0.*pi-pi.*theta1+(alpha1.*pi.^2)./2.0+(t2.*theta1.^2)./2.0+alpha0.*t2.*theta1;
mean(u1-u1_pre)

% [~,um_pre,bm_pre]   = lbooster1_6(out,Bobs,wobs,p,y,c,post,A,T,given)
% [~,um_pre,bm_pre]   = lbooster1_6(out,Bobs,wobs,p,y,2.*c,post,A,T,given)

%%% 1) appreciate the error term: SOME PEOPLE CAN GET BOOSTER PUMPS FOR WAYY CHEAP!
%%% 2) booster pumps DAMPEN the impact of pipe fixing
%%% 3) how do booster pumps affect welfare across the spectrum?

% what's the point of the paper?! it's here...

% NO BOOSTER 


[~,um_pre,bm_pre]   = lbooster1_6(out,Bobs,wobs,p,y,c,0,A,T,given)
[~,um_post,bm_post] = lbooster1_6(out,Bobs,wobs,p,y,c,1,A,T,given)
disp 'change'
(um_post-um_pre)

[~,um_pre1,bm_pre]=lbooster1_6(out,Bobs,wobs,p,y,10.*c,0,A,T,given)
[~,um_post1,bm_post]=lbooster1_6(out,Bobs,wobs,p,y,10.*c,1,A,T,given)
disp 'change'
(um_post1-um_pre1)

[~,um_pre1, bm_pre]=lbooster1_6(out,Bobs,wobs,p,y,.5.*c,0,A,T,given)
[~,um_post1, bm_post]=lbooster1_6(out,Bobs,wobs,p,y,.5.*c,1,A,T,given)
disp 'change'
(um_post1-um_pre1)
