function [val,g,h] = gh2(alpha0,alpha1,es,nc,np,p_i,p_r,sig,theta1,wobs)
%GH2
%    [VAL,G,H] = GH2(ALPHA0,ALPHA1,ES,NC,NP,P_I,P_R,SIG,THETA1,WOBS)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    29-Jun-2020 12:01:35

t2 = alpha1.*p_i;
t3 = es.*np;
t4 = alpha0.^2;
t5 = alpha1.^2;
t6 = p_i.^2;
t7 = p_r.^2;
t8 = sig.^2;
t9 = theta1.^2;
t10 = wobs.^2;
t11 = alpha0.*p_r.*2.0;
t12 = alpha1.*p_r.*2.0;
t13 = alpha0.*p_r.*4.0;
t14 = p_r.*theta1.*2.0;
t15 = p_r.*theta1.*4.0;
t16 = p_r.*wobs.*2.0;
t17 = -alpha0;
t19 = 1.0./sig.^3;
t20 = -theta1;
t18 = 1.0./t8;
t21 = -t2;
t22 = -t16;
t23 = p_r.*t2.*2.0;
t24 = t12.*wobs;
t25 = -t8;
t26 = t12+1.0;
t28 = alpha1.*p_r.*t8.*4.0;
t29 = alpha1.*t7.*wobs.*4.0;
t36 = p_i+t11+t14;
t37 = t5.*t7.*t8.*4.0;
t27 = -t23;
t30 = -t28;
t31 = -t29;
t32 = alpha0+t21+theta1;
t33 = 1.0./t26;
t38 = -t37;
t39 = t2+t17+t20+t24+wobs;
t34 = t33.^2;
t35 = t33.^3;
t40 = t32.*t33;
val = -log(exp(t18.*(t40-wobs).^2.*(-1.0./2.0))./(nc.*sig));
if nargout > 1
    g = [np.*t18.*t33.*(t40-wobs),np.*t18.*t35.*t36.*t39,-np.*t19.*t34.*(t4+t9+t10+t25+t30+t38-alpha0.*t2.*2.0+alpha0.*theta1.*2.0-alpha0.*wobs.*2.0-t2.*theta1.*2.0+t2.*wobs.*2.0-theta1.*wobs.*2.0+t2.^2+alpha1.*p_r.*t10.*4.0+t5.*t7.*t10.*4.0-alpha0.*alpha1.*p_r.*wobs.*4.0+alpha1.*p_r.*t2.*wobs.*4.0-alpha1.*p_r.*theta1.*wobs.*4.0),t3];
end
if nargout > 2
    t43 = p_i+t13+t15+t22+t27+t31;
    t41 = -t40;
    t44 = np.*t19.*t34.*t39.*2.0;
    t45 = np.*t19.*t35.*t36.*t39.*2.0;
    t46 = np.*t18.*t35.*t43;
    t42 = t41+wobs;
    t47 = -t45;
    t48 = -t46;
    h = [np.*t18.*t34,t48,t44,t3,t48,np.*t18.*t34.^2.*t36.*(p_i+alpha0.*p_r.*6.0-p_r.*t2.*4.0+p_r.*theta1.*6.0-p_r.*wobs.*4.0-alpha1.*t7.*wobs.*8.0),t47,t3,t44,t47,np.*t18.^2.*t34.*(t4.*3.0+t9.*3.0+t10.*3.0+t25+t30+t38-alpha0.*t2.*6.0+alpha0.*theta1.*6.0-alpha0.*wobs.*6.0-t2.*theta1.*6.0+t2.*wobs.*6.0-theta1.*wobs.*6.0+t2.^2.*3.0+alpha1.*p_r.*t10.*1.2e+1+t5.*t7.*t10.*1.2e+1-alpha0.*alpha1.*p_r.*wobs.*1.2e+1+alpha1.*p_r.*t2.*wobs.*1.2e+1-alpha1.*p_r.*theta1.*wobs.*1.2e+1),t3,t3,t3,t3,t3];
end
