function out1 = pout(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,T_1,T_2,T_3,alpha1,alpha0_1,alpha0_2,alpha0_3,alpha0_4,alpha0_5,alpha0_6,alpha0_7,c,pi,sig,theta1_1,theta1_2,theta1_3,wobs,y)
%POUT
%    OUT1 = POUT(A_1,A_2,A_3,A_4,A_5,A_6,A_7,SC,T_1,T_2,T_3,ALPHA1,ALPHA0_1,ALPHA0_2,ALPHA0_3,ALPHA0_4,ALPHA0_5,ALPHA0_6,ALPHA0_7,C,PI,SIG,THETA1_1,THETA1_2,THETA1_3,WOBS,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    24-Jun-2020 10:54:42

t2 = A_1.*alpha0_1;
t3 = A_2.*alpha0_2;
t4 = A_3.*alpha0_3;
t5 = A_4.*alpha0_4;
t6 = A_5.*alpha0_5;
t7 = A_6.*alpha0_6;
t8 = A_7.*alpha0_7;
t9 = T_1.*theta1_1;
t10 = T_2.*theta1_2;
t11 = T_3.*theta1_3;
t12 = alpha1.^2;
t13 = pi.^2;
t14 = 1.0./SC;
t15 = 1.0./alpha1;
t16 = -y;
t17 = c+t16;
t18 = t12.*t13;
t21 = t9+t10+t11;
t25 = t2+t3+t4+t5+t6+t7+t8;
t19 = alpha1.*t17.*2.0;
t22 = t21.^2;
t23 = alpha1.*pi.*t21.*2.0;
t26 = alpha1.*pi.*t25.*2.0;
t28 = t21.*t25.*2.0;
t20 = -t19;
t24 = -t23;
t27 = -t26;
t29 = t18+t20+t22+t24+t27+t28;
t30 = (t14.*t15.*t29)./2.0;
out1 = t30-log(exp(t30)+exp((t14.*t15.*(t18+t27+alpha1.*y.*2.0+t10.*t25.*2.0+t10.^2-alpha1.*pi.*t10.*2.0))./2.0))+log(3.989422804014327e-1./sig)-(1.0./sig.^2.*(t21+t25-wobs-alpha1.*pi).^2)./2.0;
