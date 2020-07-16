function  h = lbooster1_3ptest(input,Bobs,wobs,p,y,SC,c,B,post,A,given)

alen=size(A,2);
alpha0   = input(1:alen);
sig      = input(alen +1);
alpha1   = input(alen +2);
% theta1   = input(alen +3);
% theta2   = input(alen +4);
% theta3   = input(alen +5);


% alpha0   = given(1:alen);
% sig      = given(alen +1);
theta1   = given(alen +3);
theta2   = given(alen +4);
theta3   = given(alen +5);
% alpha1   = given(alen +5);


a0 = A*alpha0;

w1 = normpdf( (wobs - wp1( a0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) ),0,sig );
% w1=1;
% w2=1;

h = -1.*sum( (Bobs==1).*( log(w1)) ...
           + (Bobs==2).*( log(w2)) );

% h = -1.*sum( (Bobs==1).*(log(Bprob1) + log(w1)) ...
%            + (Bobs==2).*(log(Bprob2) + log(w2)) );

% h = -1.*sum( (Bobs==1).*(log(Bprob1) + 100000.*log(w1)) ...
%            + (Bobs==2).*(log(Bprob2) + 100000.*log(w2)) );

end