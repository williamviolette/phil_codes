function  [h] = lbooster1_3gh(input,Bobs,wobs,pi,y,SC,c,post,...
    A,given)

 A_1=A(:,1);
 A_2=A(:,2);
 A_3=A(:,3);
 A_4=A(:,4);
 A_5=A(:,5);
 A_6=A(:,6);
 A_7=A(:,7);

alpha0_1   = input(1);
alpha0_2   = input(2);
alpha0_3   = input(3);
alpha0_4   = input(4);
alpha0_5   = input(5);
alpha0_6   = input(6);
alpha0_7   = input(7);

alen=7;
sig      = input(alen +1);
alpha1   = input(alen +2);
theta1_1   = input(alen +3);
theta1_2   = input(alen +4);
theta1_3   = input(alen +5);


T_2 = post;

% w1 = wbp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,0,T_2,0,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7,pi,sig,theta1_1,theta1_2,theta1_3,wobs);
% mean(w1)

noboost = pout(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC, 0 ,T_2,0, alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, 0 ,pi,sig,theta1_1,theta1_2,theta1_3,wobs,y);
boost = pout(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,   1,T_2,1, alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, c ,pi,sig,theta1_1,theta1_2,theta1_3,wobs,y);

% noboost = p(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC, zeros(size(A,1),1) ,T_2,zeros(size(A,1),1), alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, zeros(size(A,1),1) ,pi,sig,theta1_1,theta1_2,theta1_3,wobs,y);
% boost = p(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,   ones(size(A,1),1),T_2,ones(size(A,1),1), alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, c ,pi,sig,theta1_1,theta1_2,theta1_3,wobs,y);

h = -1.*sum( (Bobs==0).*noboost ...
           + (Bobs==1).*boost );

       
% gwp_noboost = gwp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,  0,T_2,0,  alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7,pi,sig,theta1_1,theta1_2,theta1_3,wobs);        
% gwp_boost = gwp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,  1,T_2,1  ,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7,pi,sig,theta1_1,theta1_2,theta1_3,wobs);

% hwp_noboost =  hwp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,  zeros(size(A,1),1),T_2,zeros(size(A,1),1),  alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7,pi,sig,theta1_1,theta1_2,theta1_3,wobs);
% hwp_boost =  hwp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,  ones(size(A,1),1),T_2,ones(size(A,1),1)  ,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7,pi,sig,theta1_1,theta1_2,theta1_3,wobs); 


% gp_noboost = gp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC, zeros(size(A,1),1),T_2,zeros(size(A,1),1)  ,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7 ,0 ,pi,theta1_1,theta1_2,theta1_3,y);
% gp_boost = gp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,1,T_2,1,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, c ,pi,theta1_1,theta1_2,theta1_3,y);

% hp_noboost = hp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,  zeros(size(A,1),1),T_2,zeros(size(A,1),1)  ,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, zeros(size(A,1),1) ,pi,theta1_1,theta1_2,theta1_3,y);
% hp_boost = hp(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,ones(size(A,1),1),T_2,ones(size(A,1),1),alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7, c ,pi,theta1_1,theta1_2,theta1_3,y);

% grad = -1.*sum( (Bobs==0).*(gwp_noboost + gp_noboost) ...
%            + (Bobs==1).*(gwp_boost + gp_boost) );

% hess = -1.*sum( (Bobs==0).*(hwp_noboost + hp_noboost) ...
%            + (Bobs==1).*(hwp_boost + hp_boost) );

end