


clear


c = 500;
B=1;




% theta1 =  0;
% theta2 =  0;
% theta3 =  0;

SC = 100;

y = 10000;

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

alpha0 =  [18;                1.5  ];
A  = [ ones(size(wobs,1),1)  hhsize   ];


% alpha0 =  [16     ]  ;
% A  = [ ones(size(wobs,1),1) year cmax cmin hhsize ];
% Nb = A*alpha0;

given = [alpha0; sig; alpha1; theta1; theta2; theta3];

% obj1=@(input1_1)lbooster1_3gh(input1_1,Bobs,wobs,pi,y,SC,c,post,A,given);
obj=@(input1)lbooster1_3(input1,Bobs,wobs,p,y,SC,c,B,post,A,given);


input= [alpha0; sig; alpha1; theta1; theta2; theta3]

% obj1(input)
obj(input)

%     'HessianFcn', 'objective', ...
%     'Algorithm','trust-region', ...
% options1 = optimoptions('fminunc', ...
%     'SpecifyObjectiveGradient', true, ...
%     'Display','final');
tic
out=fminunc(obj,input)
toc

% tic
% [xfinal,fval,exitflag,output] = fminunc(obj1,input)
% toc

b = regress(wobs,[A p Bobs post])


% input= [alpha0; sig; alpha1; theta1; theta2]
% input= [alpha0; sig; alpha1]

% plug in the T_1 and T_3



