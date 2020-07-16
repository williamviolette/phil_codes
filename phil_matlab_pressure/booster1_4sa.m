


clear


c = 500;
B=1;

% to do:
% (1) identify c? (understand identification in general) 
    % * FROM FUNCTIONAL FORM see whether the estimates are reasonable
% (2) robust to SC?
% (3) get the right solutions?
% (4) DO EXPECTED UTILITY! DO NON-LINEAR PRICING! (think about rental of booster pump)
     % no expected utility!  rental market each period!
     
% (5) run counterfactuals?? COMPARE welfare with and without 

% order:  do counterfactuals with current model
     %    then test assumptions of model
            % model assumes that large users are more likeily
     %    then think about adding proper utility and price 


SC = 100;

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
theta2 =  2.5;
theta3 =  -1.5;

alpha0 =  [18;                1.3;     .5;  3.3;   -3;  -.04; 2.4   ];
A  = [ ones(size(wobs,1),1)  hhsize hhemp good_job sho year cmax  ];

alpha0 =  [18;                1.5   ];
A  = [ ones(size(wobs,1),1)  hhsize ];

given = [alpha0; sig; alpha1; theta1; theta2; theta3];

obj=@(input1)lbooster1_4sa(input1,Bobs,wobs,p,y,c,post,A,given);

% obj1=@(input1)lbooster1_4sa(input1,Bobs,wobs,p,y,c,post,A,given);


input= [alpha0; sig; alpha1; theta1; theta2; theta3; 120 ]
obj(input)
tic
out=fminunc(obj,input)
toc


% II = (50:200)';
% JJ = II;
% 
% for i=1:size(II,1)
%    ip = out;
%    ip(8)=II(i);
%    oo = obj1(ip);
%    JJ(i)=oo;
% end
% 
% plot(II,JJ)



input= [alpha0; sig; alpha1; theta1; theta2; theta3]
obj(input)
tic
out=fminunc(obj,input)
toc






b = regress(wobs,[A p Bobs post])


[~,um_pre,bm_pre]   = lbooster1_4(out,Bobs,wobs,p,y,SC,c,post,A,given)
[~,um_pre,bm_pre]   = lbooster1_4(out,Bobs,wobs,p,y,SC,2.*c,post,A,given)


%%% 1) appreciate the error term: SOME PEOPLE CAN GET BOOSTER PUMPS FOR WAYY CHEAP!
%%% 2) booster pumps DAMPEN the impact of pipe fixing
%%% 3) how do booster pumps affect welfare across the spectrum?

% what's the point of the paper?! it's here...




[~,um_pre,bm_pre]   = lbooster1_4(out,Bobs,wobs,p,y,SC,c,0,A,given)
[~,um_post,bm_post] = lbooster1_4(out,Bobs,wobs,p,y,SC,c,1,A,given)
disp 'change'
(um_post-um_pre).*100

[~,um_pre1,bm_pre]=lbooster1_4(out,Bobs,wobs,p,y,SC,10.*c,0,A,given)
[~,um_post1,bm_post]=lbooster1_4(out,Bobs,wobs,p,y,SC,10.*c,1,A,given)
disp 'change'
(um_post1-um_pre1).*100

[~,um_pre1, bm_pre]=lbooster1_4(out,Bobs,wobs,p,y,SC,.5.*c,0,A,given)
[~,um_post1, bm_post]=lbooster1_4(out,Bobs,wobs,p,y,SC,.5.*c,1,A,given)
disp 'change'
(um_post1-um_pre1).*100
