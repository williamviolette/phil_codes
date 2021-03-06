function [val,g,h] = ghu2s(alpha0,alpha1,bobs,c,np,p_i,siga,thetab,theta)
%GHU2S
%    [VAL,G,H] = GHU2S(ALPHA0,ALPHA1,BOBS,C,NP,P_I,SIGA,THETAB,THETA)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    29-Jul-2020 10:59:12

t2 = bobs.*2.0;
t3 = thetab.^2;
t4 = theta.^2;
t5 = alpha1.*c.*2.0;
t6 = alpha0.*thetab.*2.0;
t7 = alpha0.*theta.*2.0;
t8 = 1.0./pi;
t9 = 1.0./alpha1;
t12 = bobs-1.0;
t13 = 1.0./siga;
t19 = sqrt(2.0);
t20 = alpha1.*p_i.*thetab.*2.0;
t21 = alpha1.*p_i.*theta.*2.0;
t24 = 1.0./sqrt(pi);
t10 = t9.^2;
t11 = t9.^3;
t14 = t13.^2;
t15 = t13.^3;
t17 = t13.^5;
t18 = -t6;
t22 = -t3;
t23 = -t21;
t16 = t14.^2;
t25 = t4+t5+t7+t18+t20+t22+t23;
t26 = t25.^2;
t27 = t25.^3;
t33 = (t9.*t13.*t19.*t25)./4.0;
t28 = (t10.*t14.*t26)./4.0;
t30 = (t10.*t14.*t26)./8.0;
t35 = erf(t33);
t29 = -t28;
t31 = -t30;
t36 = t35+1.0;
t37 = t35.^2;
t38 = t35-1.0;
t39 = t35./2.0;
val = t12.*log(t39+1.0./2.0)-bobs.*log(-t39+1.0./2.0);
if nargout > 1
    t32 = exp(t29);
    t34 = exp(t31);
    t40 = 1.0./t36;
    t41 = t37-1.0;
    t43 = t2+t38;
    t44 = 1.0./t38;
    t42 = t40.^2;
    t45 = t44.^2;
    t46 = 1.0./t41;
    g = [(np.*t9.*t14.*t19.*t24.*t25.*t34.*t43.*t46)./2.0,-np.*t13.*t19.*t24.*t34.*t43.*t46];
end
if nargout > 2
    t47 = bobs.*t14.*t19.*t24.*t34.*t44;
    t48 = t12.*t14.*t19.*t24.*t34.*t40;
    t53 = (bobs.*t10.*t16.*t19.*t24.*t26.*t34.*t44)./4.0;
    t55 = (t10.*t12.*t16.*t19.*t24.*t26.*t34.*t40)./4.0;
    t49 = -t48;
    t50 = bobs.*t8.*t9.*t15.*t25.*t32.*t45;
    t51 = t8.*t9.*t12.*t15.*t25.*t32.*t42;
    t54 = -t53;
    t52 = -t50;
    t56 = t47+t49+t51+t52+t54+t55;
    t57 = np.*t56;
    h = [np.*((bobs.*t8.*t10.*t16.*t26.*t32.*t45)./2.0-(t8.*t10.*t12.*t16.*t26.*t32.*t42)./2.0-bobs.*t9.*t15.*t19.*t24.*t25.*t34.*t44+(bobs.*t11.*t17.*t19.*t24.*t27.*t34.*t44)./8.0+t9.*t12.*t15.*t19.*t24.*t25.*t34.*t40-(t11.*t12.*t17.*t19.*t24.*t27.*t34.*t40)./8.0),t57,t57,np.*(bobs.*t8.*t14.*t32.*t45.*2.0-t8.*t12.*t14.*t32.*t42.*2.0+(bobs.*t9.*t15.*t19.*t24.*t25.*t34.*t44)./2.0-(t9.*t12.*t15.*t19.*t24.*t25.*t34.*t40)./2.0)];
end
