function [g,h] = ghu8_halpha_theta(AV,AVB,A_1,A_2,EV,TV,TVB,T_1,T_2,T_1b,T_2b,UV,alpha1,bobs,np,sig,siga,wobs)
%GHU8_HALPHA_THETA
%    [G,H] = GHU8_HALPHA_THETA(AV,AVB,A_1,A_2,EV,TV,TVB,T_1,T_2,T_1B,T_2B,UV,ALPHA1,BOBS,NP,SIG,SIGA,WOBS)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    30-Jun-2020 18:11:23

t2 = T_1.*T_2;
t3 = T_1b.*T_2b;
t4 = A_1.^2;
t5 = A_2.^2;
t6 = T_1.^2;
t7 = T_2.^2;
t8 = T_1b.^2;
t9 = T_2b.^2;
t10 = AV.*T_1;
t11 = AV.*T_2;
t12 = AVB.*T_1b;
t13 = AVB.*T_2b;
t14 = 1.0./EV;
t16 = 1.0./pi;
t17 = -TVB;
t18 = -T_1b;
t19 = -T_2b;
t20 = 1.0./alpha1;
t22 = bobs-1.0;
t23 = 1.0./sig.^2;
t24 = 1.0./siga;
t27 = -wobs;
t29 = sqrt(2.0);
t39 = 1.0./sqrt(pi);
t15 = t14.^2;
t21 = t20.^2;
t25 = t24.^2;
t26 = t24.^3;
t28 = -t3;
t30 = -t12;
t31 = -t13;
t32 = -t8;
t33 = -t9;
t34 = TV+t17;
t35 = T_1+t18;
t36 = T_2+t19;
t37 = AV+t27;
t38 = UV+t27;
t40 = A_1.*A_2.*t23;
t41 = A_1.*T_1.*t23;
t42 = A_1.*T_2.*t23;
t43 = A_2.*T_1.*t23;
t44 = A_2.*T_2.*t23;
t45 = t2.*t23;
t46 = t34.^2;
t47 = t38.^2;
t48 = t10+t30;
t49 = t11+t31;
t50 = t2+t28;
t51 = -t40;
t52 = t6+t32;
t53 = t7+t33;
t62 = (t24.*t29.*t38)./2.0;
t54 = t48.^2;
t55 = t49.^2;
t56 = t25.*t47;
t63 = erf(t62);
t57 = -t56;
t58 = t56./2.0;
t64 = t63+1.0;
t59 = exp(t57);
t60 = -t58;
t65 = 1.0./t64;
t61 = exp(t60);
g = [np.*(A_1.*t23.*t37+(A_1.*bobs.*t14.*t20.*t24.*t29.*t34.*t39.*t61)./2.0+A_1.*t20.*t22.*t24.*t29.*t34.*t39.*t61.*t65),np.*(A_2.*t23.*t37+(A_2.*bobs.*t14.*t20.*t24.*t29.*t34.*t39.*t61)./2.0+A_2.*t20.*t22.*t24.*t29.*t34.*t39.*t61.*t65),np.*(T_1.*t23.*t37+(bobs.*t14.*t20.*t24.*t29.*t39.*t48.*t61)./2.0+t20.*t22.*t24.*t29.*t39.*t48.*t61.*t65),np.*(T_2.*t23.*t37+(bobs.*t14.*t20.*t24.*t29.*t39.*t49.*t61)./2.0+t20.*t22.*t24.*t29.*t39.*t49.*t61.*t65)];
if nargout > 1
    t66 = t65.^2;
    t67 = (A_1.*A_2.*bobs.*t15.*t16.*t21.*t25.*t46.*t59)./2.0;
    t69 = (A_1.*bobs.*t15.*t16.*t21.*t25.*t34.*t48.*t59)./2.0;
    t70 = (A_2.*bobs.*t15.*t16.*t21.*t25.*t34.*t48.*t59)./2.0;
    t71 = (A_1.*bobs.*t15.*t16.*t21.*t25.*t34.*t49.*t59)./2.0;
    t72 = (A_2.*bobs.*t15.*t16.*t21.*t25.*t34.*t49.*t59)./2.0;
    t77 = (bobs.*t15.*t16.*t21.*t25.*t48.*t49.*t59)./2.0;
    t68 = -t67;
    t73 = (A_1.*bobs.*t14.*t20.*t24.*t29.*t35.*t39.*t61)./2.0;
    t74 = (A_2.*bobs.*t14.*t20.*t24.*t29.*t35.*t39.*t61)./2.0;
    t75 = (A_1.*bobs.*t14.*t20.*t24.*t29.*t36.*t39.*t61)./2.0;
    t76 = (A_2.*bobs.*t14.*t20.*t24.*t29.*t36.*t39.*t61)./2.0;
    t78 = (bobs.*t14.*t20.*t24.*t29.*t39.*t50.*t61)./2.0;
    t79 = (A_1.*A_2.*bobs.*t14.*t21.*t26.*t29.*t38.*t39.*t46.*t61)./2.0;
    t80 = (A_1.*bobs.*t14.*t21.*t26.*t29.*t34.*t38.*t39.*t48.*t61)./2.0;
    t81 = (A_2.*bobs.*t14.*t21.*t26.*t29.*t34.*t38.*t39.*t48.*t61)./2.0;
    t82 = (A_1.*bobs.*t14.*t21.*t26.*t29.*t34.*t38.*t39.*t49.*t61)./2.0;
    t83 = (A_2.*bobs.*t14.*t21.*t26.*t29.*t34.*t38.*t39.*t49.*t61)./2.0;
    t88 = A_1.*A_2.*t16.*t21.*t22.*t25.*t46.*t59.*t66.*2.0;
    t89 = (bobs.*t14.*t21.*t26.*t29.*t38.*t39.*t48.*t49.*t61)./2.0;
    t91 = A_1.*t20.*t22.*t24.*t29.*t35.*t39.*t61.*t65;
    t92 = A_2.*t20.*t22.*t24.*t29.*t35.*t39.*t61.*t65;
    t93 = A_1.*t20.*t22.*t24.*t29.*t36.*t39.*t61.*t65;
    t94 = A_2.*t20.*t22.*t24.*t29.*t36.*t39.*t61.*t65;
    t95 = A_1.*t16.*t21.*t22.*t25.*t34.*t48.*t59.*t66.*2.0;
    t96 = A_2.*t16.*t21.*t22.*t25.*t34.*t48.*t59.*t66.*2.0;
    t97 = A_1.*t16.*t21.*t22.*t25.*t34.*t49.*t59.*t66.*2.0;
    t98 = A_2.*t16.*t21.*t22.*t25.*t34.*t49.*t59.*t66.*2.0;
    t103 = t20.*t22.*t24.*t29.*t39.*t50.*t61.*t65;
    t104 = t16.*t21.*t22.*t25.*t48.*t49.*t59.*t66.*2.0;
    t106 = A_1.*A_2.*t21.*t22.*t26.*t29.*t38.*t39.*t46.*t61.*t65;
    t107 = A_1.*t21.*t22.*t26.*t29.*t34.*t38.*t39.*t48.*t61.*t65;
    t108 = A_2.*t21.*t22.*t26.*t29.*t34.*t38.*t39.*t48.*t61.*t65;
    t109 = A_1.*t21.*t22.*t26.*t29.*t34.*t38.*t39.*t49.*t61.*t65;
    t110 = A_2.*t21.*t22.*t26.*t29.*t34.*t38.*t39.*t49.*t61.*t65;
    t115 = t21.*t22.*t26.*t29.*t38.*t39.*t48.*t49.*t61.*t65;
    t84 = -t80;
    t85 = -t81;
    t86 = -t82;
    t87 = -t83;
    t90 = -t89;
    t99 = -t95;
    t100 = -t96;
    t101 = -t97;
    t102 = -t98;
    t105 = -t104;
    t111 = -t107;
    t112 = -t108;
    t113 = -t109;
    t114 = -t110;
    t116 = -t115;
    t117 = t51+t68+t79+t88+t106;
    t118 = np.*t117;
    t120 = t41+t69+t73+t84+t91+t99+t111;
    t121 = t43+t70+t74+t85+t92+t100+t112;
    t122 = t42+t71+t75+t86+t93+t101+t113;
    t123 = t44+t72+t76+t87+t94+t102+t114;
    t128 = t45+t77+t78+t90+t103+t105+t116;
    t119 = -t118;
    t124 = np.*t120;
    t125 = np.*t121;
    t126 = np.*t122;
    t127 = np.*t123;
    t129 = np.*t128;
    h = [-np.*(-t4.*t23-(bobs.*t4.*t15.*t16.*t21.*t25.*t46.*t59)./2.0+t4.*t16.*t21.*t22.*t25.*t46.*t59.*t66.*2.0+(bobs.*t4.*t14.*t21.*t26.*t29.*t38.*t39.*t46.*t61)./2.0+t4.*t21.*t22.*t26.*t29.*t38.*t39.*t46.*t61.*t65),t119,t124,t126,t119,-np.*(-t5.*t23-(bobs.*t5.*t15.*t16.*t21.*t25.*t46.*t59)./2.0+t5.*t16.*t21.*t22.*t25.*t46.*t59.*t66.*2.0+(bobs.*t5.*t14.*t21.*t26.*t29.*t38.*t39.*t46.*t61)./2.0+t5.*t21.*t22.*t26.*t29.*t38.*t39.*t46.*t61.*t65),t125,t127,t124,t125,np.*(t6.*t23+(bobs.*t15.*t16.*t21.*t25.*t54.*t59)./2.0-t16.*t21.*t22.*t25.*t54.*t59.*t66.*2.0+(bobs.*t14.*t20.*t24.*t29.*t39.*t52.*t61)./2.0+t20.*t22.*t24.*t29.*t39.*t52.*t61.*t65-(bobs.*t14.*t21.*t26.*t29.*t38.*t39.*t54.*t61)./2.0-t21.*t22.*t26.*t29.*t38.*t39.*t54.*t61.*t65),t129,t126,t127,t129,np.*(t7.*t23+(bobs.*t15.*t16.*t21.*t25.*t55.*t59)./2.0-t16.*t21.*t22.*t25.*t55.*t59.*t66.*2.0+(bobs.*t14.*t20.*t24.*t29.*t39.*t53.*t61)./2.0+t20.*t22.*t24.*t29.*t39.*t53.*t61.*t65-(bobs.*t14.*t21.*t26.*t29.*t38.*t39.*t55.*t61)./2.0-t21.*t22.*t26.*t29.*t38.*t39.*t55.*t61.*t65)];
end
