function  h = cbooster1_4(input,Bobs,wobs,p,y,SC,c,post,A,given)

B=1;
alen=size(A,2);
alpha0   = input(1:alen);
sig      = input(alen +1);
alpha1   = input(alen +2);
theta1   = input(alen +3);
theta2   = input(alen +4);
theta3   = input(alen +5);


% alpha0   = given(1:alen);
% sig      = given(alen +1);
% alpha1   = given(alen +2);
% theta1   = given(alen +3);
% theta2   = given(alen +4);
% theta3   = given(alen +5);

a0 = A*alpha0;

v1 = exp( up1(  a0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y)./SC                );
v2 = exp( up1(  a0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c)./SC  );

Bprob1=v1./(v1 + v2);
Bprob2=v2./(v1 + v2);

w1 = normpdf( (wobs - wp1( a0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) ),0,sig );
w2 = normpdf( (wobs - wp1( a0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3)  ),0,sig );

h = -1.*sum( (Bobs==0).*(log(Bprob1) + log(w1)) ...
           + (Bobs==1).*(log(Bprob2) + log(w2)) );


end