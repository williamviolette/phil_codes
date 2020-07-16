function [val,g,h] = gh5(AC,A_1,A_2,TC,T_1,T_2,alpha1,alpha0_1,alpha0_2,nc,np,p_i,p_r,sig,theta0_1,theta0_2,wobs)
%GH5
%    [VAL,G,H] = GH5(AC,A_1,A_2,TC,T_1,T_2,ALPHA1,ALPHA0_1,ALPHA0_2,NC,NP,P_I,P_R,SIG,THETA0_1,THETA0_2,WOBS)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    30-Jun-2020 08:45:31

t2 = A_1.*alpha0_1;
t3 = A_2.*alpha0_2;
t4 = T_1.*theta0_1;
t5 = T_2.*theta0_2;
t6 = alpha1.*p_i;
t7 = A_1.^2;
t8 = A_2.^2;
t9 = T_1.^2;
t10 = T_2.^2;
t11 = alpha1.^2;
t12 = p_r.^2;
t13 = sig.^2;
t14 = wobs.^2;
t15 = AC.*p_r.*2.0;
t16 = AC.*p_r.*4.0;
t17 = TC.*p_r.*2.0;
t18 = TC.*p_r.*4.0;
t19 = alpha1.*p_r.*2.0;
t20 = p_r.*wobs.*2.0;
t21 = 1.0./nc;
t23 = 1.0./sig.^3;
t25 = -wobs;
t40 = alpha1.*p_r.*wobs.*-2.0;
t22 = 1.0./t13;
t26 = -t6;
t27 = -t20;
t28 = p_r.*t2.*2.0;
t29 = p_r.*t2.*4.0;
t30 = p_r.*t3.*2.0;
t31 = p_r.*t3.*4.0;
t32 = p_r.*t4.*2.0;
t33 = p_r.*t4.*4.0;
t34 = p_r.*t5.*2.0;
t35 = p_r.*t5.*4.0;
t36 = p_r.*t6.*2.0;
t37 = t19.*wobs;
t38 = t19+1.0;
t41 = alpha1.*t12.*wobs.*4.0;
t24 = t22.^2;
t39 = -t36;
t42 = -t41;
t43 = 1.0./t38;
t52 = AC+TC+t2+t3+t4+t5+t26;
t53 = p_i+t15+t17+t28+t30+t32+t34;
t44 = t43.^2;
t45 = t43.^3;
t54 = t43.*t52;
t55 = t25+t40+t52;
t70 = p_i+t16+t18+t27+t29+t31+t33+t35+t39+t42;
t46 = A_1.*A_2.*np.*t22.*t44;
t47 = A_1.*T_1.*np.*t22.*t44;
t48 = A_1.*T_2.*np.*t22.*t44;
t49 = A_2.*T_1.*np.*t22.*t44;
t50 = A_2.*T_2.*np.*t22.*t44;
t51 = T_1.*T_2.*np.*t22.*t44;
t56 = -t54;
t58 = (t54-wobs).^2;
t62 = A_1.*np.*t23.*t44.*t55.*2.0;
t63 = A_2.*np.*t23.*t44.*t55.*2.0;
t64 = T_1.*np.*t23.*t44.*t55.*2.0;
t65 = T_2.*np.*t23.*t44.*t55.*2.0;
t71 = A_1.*np.*t22.*t45.*t70;
t72 = A_2.*np.*t22.*t45.*t70;
t73 = T_1.*np.*t22.*t45.*t70;
t74 = T_2.*np.*t22.*t45.*t70;
t79 = np.*t23.*t45.*t53.*t55.*2.0;
t57 = t56+wobs;
t59 = (t22.*t58)./2.0;
t66 = -t62;
t67 = -t63;
t68 = -t64;
t69 = -t65;
t75 = -t71;
t76 = -t72;
t77 = -t73;
t78 = -t74;
t60 = -t59;
t61 = exp(t60);
val = -log((t21.*t61)./sig);
if nargout > 1
    g = [A_1.*np.*t22.*t44.*t55,A_2.*np.*t22.*t44.*t55,T_1.*np.*t22.*t44.*t55,T_2.*np.*t22.*t44.*t55,-np.*t22.*t45.*t53.*t55,nc.*np.*sig.*exp(t59).*(t21.*t22.*t61-t21.*t24.*t58.*t61)];
end
if nargout > 2
    h = [np.*t7.*t22.*t44,t46,t47,t48,t75,t66,t46,np.*t8.*t22.*t44,t49,t50,t76,t67,t47,t49,np.*t9.*t22.*t44,t51,t77,t68,t48,t50,t51,np.*t10.*t22.*t44,t78,t69,t75,t76,t77,t78,np.*t22.*t44.^2.*t53.*(p_i+AC.*p_r.*6.0+TC.*p_r.*6.0+p_r.*t2.*6.0+p_r.*t3.*6.0+p_r.*t4.*6.0+p_r.*t5.*6.0-p_r.*t6.*4.0-p_r.*wobs.*4.0-alpha1.*t12.*wobs.*8.0),t79,t66,t67,t68,t69,t79,np.*t24.*t44.*(-t13+t14.*3.0+AC.*t2.*6.0+AC.*t3.*6.0+AC.*t4.*6.0+AC.*t5.*6.0-AC.*t6.*6.0-AC.*wobs.*6.0+TC.*t2.*6.0+TC.*t3.*6.0+TC.*t4.*6.0+TC.*t5.*6.0-TC.*t6.*6.0-TC.*wobs.*6.0+t2.*t3.*6.0+t2.*t4.*6.0+t2.*t5.*6.0+t3.*t4.*6.0-t2.*t6.*6.0+t3.*t5.*6.0-t3.*t6.*6.0+t4.*t5.*6.0-t4.*t6.*6.0-t5.*t6.*6.0-t2.*wobs.*6.0-t3.*wobs.*6.0-t4.*wobs.*6.0-t5.*wobs.*6.0+t6.*wobs.*6.0+AC.^2.*3.0+TC.^2.*3.0+t2.^2.*3.0+t3.^2.*3.0+t4.^2.*3.0+t5.^2.*3.0+t6.^2.*3.0+AC.*TC.*6.0-alpha1.*p_r.*t13.*4.0+alpha1.*p_r.*t14.*1.2e+1-t11.*t12.*t13.*4.0+t11.*t12.*t14.*1.2e+1-alpha1.*p_r.*t2.*wobs.*1.2e+1-alpha1.*p_r.*t3.*wobs.*1.2e+1-alpha1.*p_r.*t4.*wobs.*1.2e+1-alpha1.*p_r.*t5.*wobs.*1.2e+1+alpha1.*p_r.*t6.*wobs.*1.2e+1-AC.*alpha1.*p_r.*wobs.*1.2e+1-TC.*alpha1.*p_r.*wobs.*1.2e+1)];
end
