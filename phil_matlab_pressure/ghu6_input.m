function [EV,OV,KV,UV,AV,AVB,TV,TVB] = ghu6_input(AC,A_1,A_2,TC,TCb,T_1,T_2,T_1b,T_2b,alpha1,alpha0_1,alpha0_2,nc,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb)
%GHU6_INPUT
%    [EV,OV,KV,UV,AV,AVB,TV,TVB] = GHU6_INPUT(AC,A_1,A_2,TC,TCB,T_1,T_2,T_1B,T_2B,ALPHA1,ALPHA0_1,ALPHA0_2,NC,P_I,SIG,SIGA,THETA0_1,THETA0_2,WOBS,Y,YB)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    30-Jun-2020 15:12:20

t2 = A_1.*alpha0_1;
t3 = A_2.*alpha0_2;
t4 = TC.*p_i;
t5 = TCb.*p_i;
t6 = T_1.*theta0_1;
t7 = T_2.*theta0_2;
t8 = T_1b.*theta0_1;
t9 = T_2b.*theta0_2;
t10 = alpha1.*p_i;
t15 = 1.0./alpha1;
t16 = 1.0./sig.^2;
t17 = -wobs;
t11 = p_i.*t6;
t12 = p_i.*t7;
t13 = p_i.*t8;
t14 = p_i.*t9;
t18 = -t10;
t19 = TC+t6+t7;
t20 = TCb+t8+t9;
t21 = t18+t19;
t22 = t18+t20;
t23 = t21.^2;
t24 = t22.^2;
t27 = AC+t2+t3+t21;
t28 = AC+t2+t3+t22;
t25 = t23./2.0;
t26 = t24./2.0;
t29 = t17+t27;
t31 = t19.*t27;
t32 = t20.*t28;
t30 = t29.^2;
t33 = -t31;
t34 = -t32;
t35 = t25+t33;
t36 = t26+t34;
t37 = t15.*t35;
t38 = t15.*t36;
EV = erf((sqrt(2.0).*(t4-t5+t11+t12-t13-t14+t37-t38+wobs-y+yb))./(siga.*2.0))./2.0+1.0./2.0;
if nargout > 1
    OV = exp(t16.*t30.*(-1.0./2.0))./(nc.*sig);
end
if nargout > 2
    KV = t16.*t30;
end
if nargout > 3
    UV = -t4+t5-t11-t12+t13+t14-t37+t38+y-yb;
end
if nargout > 4
    AV = t27;
end
if nargout > 5
    AVB = t28;
end
if nargout > 6
    TV = t19;
end
if nargout > 7
    TVB = t20;
end
