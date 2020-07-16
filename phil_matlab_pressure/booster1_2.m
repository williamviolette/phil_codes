


clear


c = 1000;
B=1;


sig = 18;

alpha1 = 1;

theta1 =  2;
theta2 =  2;
theta3 = -1;

theta1 =  0;
theta2 =  0;
theta3 =  0;

SC = 100;

y = 10000;

data=1;
if data==1
%     cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_1.csv');
    cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample1_1ch.csv');
        wobs    = cs(:,1);
        Bobs    = cs(:,2);
        post    = cs(:,3);
        p       = cs(:,4);
        year    = cs(:,5);
        cmax    = cs(:,6);
        cmin    = cs(:,7);
        hhsize  = cs(:,8);
end

        %  int year cmax cmin hhsize 
alpha0 =  [28;   .1;  3;   -1.7;   2.5]  ;
A  = [ ones(size(wobs,1),1)  year cmax cmin hhsize];


alpha0 =  [16     ]  ;
A  = [ ones(size(wobs,1),1)  ];

alen = size(alpha0,1);

% Nb = A*alpha0;

given = [alpha0; alpha1; theta1; theta2; theta3; sig];

obj=@(input1)lbooster1_2(input1,Bobs,wobs,p,y,SC,c,B,post,A,alen,given);


input= [alpha0; alpha1; theta1; theta2; theta3; sig]

input= [alpha0; alpha1]

out=fminunc(obj,input)



