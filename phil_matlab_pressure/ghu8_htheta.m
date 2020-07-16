function [g,h] = ghu8_htheta(AV,AVB,EV,KV,OV,TV,TVB,T_1,T_2,T_1b,T_2b,UV,alpha1,bobs,es,nc,np,p_i,sig,siga,wobs)
%GHU8_HTHETA
%    [G,H] = GHU8_HTHETA(AV,AVB,EV,KV,OV,TV,TVB,T_1,T_2,T_1B,T_2B,UV,ALPHA1,BOBS,ES,NC,NP,P_I,SIG,SIGA,WOBS)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    30-Jun-2020 18:10:56

t2 = T_1.*T_2;
t3 = T_1b.*T_2b;
t4 = es.*np;
t5 = TV.^2;
t6 = TVB.^2;
t7 = T_1.^2;
t8 = T_2.^2;
t9 = T_1b.^2;
t10 = T_2b.^2;
t11 = AV.*T_1;
t12 = AV.*T_2;
t13 = AVB.*T_1b;
t14 = AVB.*T_2b;
t15 = T_1.*alpha1.*p_i;
t16 = T_2.*alpha1.*p_i;
t17 = T_1b.*alpha1.*p_i;
t18 = T_2b.*alpha1.*p_i;
t19 = 1.0./EV;
t21 = 1.0./pi;
t22 = 1.0./alpha1;
t26 = bobs-1.0;
t27 = 1.0./sig.^2;
t28 = 1.0./siga;
t33 = -wobs;
t34 = AV.*TV.*2.0;
t35 = AVB.*TVB.*2.0;
t37 = sqrt(2.0);
t38 = TV.*alpha1.*p_i.*2.0;
t39 = TVB.*alpha1.*p_i.*2.0;
t40 = KV./2.0;
t53 = 1.0./sqrt(pi);
t20 = t19.^2;
t23 = t22.^2;
t24 = t22.^3;
t29 = t28.^2;
t30 = t28.^3;
t32 = t28.^5;
t36 = -t3;
t41 = -t34;
t42 = -t13;
t43 = -t14;
t44 = exp(t40);
t45 = -t6;
t46 = -t9;
t47 = -t10;
t48 = AV+t33;
t49 = -t38;
t50 = -t17;
t51 = -t18;
t52 = UV+t33;
t54 = t2.*t27;
t55 = T_1.*p_i.*t27;
t56 = T_2.*p_i.*t27;
t25 = t23.^2;
t31 = t29.^2;
t57 = t52.^2;
t58 = t52.^3;
t59 = t11+t42;
t60 = t12+t43;
t61 = t2+t36;
t62 = t7+t46;
t63 = t8+t47;
t72 = (t28.*t37.*t52)./2.0;
t76 = OV.*T_1.*nc.*np.*t27.*t44.*t48.*2.0;
t77 = OV.*T_2.*nc.*np.*t27.*t44.*t48.*2.0;
t78 = OV.*nc.*np.*p_i.*t27.*t44.*t48.*2.0;
t84 = t5+t35+t39+t41+t45+t49;
t64 = t59.^2;
t65 = t60.^2;
t66 = t29.*t57;
t73 = t15+t50+t59;
t74 = t16+t51+t60;
t75 = erf(t72);
t80 = -t76;
t81 = -t77;
t85 = t84.^2;
t67 = -t66;
t68 = t66./2.0;
t79 = t75+1.0;
t69 = exp(t67);
t70 = -t68;
t82 = 1.0./t79;
t71 = exp(t70);
g = [np.*(T_1.*t27.*t48+(bobs.*t19.*t22.*t28.*t37.*t53.*t59.*t71)./2.0+t22.*t26.*t28.*t37.*t53.*t59.*t71.*t82),np.*(T_2.*t27.*t48+(bobs.*t19.*t22.*t28.*t37.*t53.*t60.*t71)./2.0+t22.*t26.*t28.*t37.*t53.*t60.*t71.*t82),np.*(-p_i.*t27.*t48+(bobs.*t19.*t23.*t28.*t37.*t53.*t71.*t84)./4.0+(t23.*t26.*t28.*t37.*t53.*t71.*t82.*t84)./2.0),-OV.*nc.*np.*t44.*(KV-1.0),-np.*((bobs.*t19.*t29.*t37.*t52.*t53.*t71)./2.0+(t26.*t29.*t37.*t52.*t53.*t71)./(t75+1.0))];
if nargout > 1
    t83 = t82.^2;
    t86 = (bobs.*t20.*t21.*t22.*t30.*t52.*t59.*t69)./2.0;
    t87 = (bobs.*t20.*t21.*t22.*t30.*t52.*t60.*t69)./2.0;
    t88 = (bobs.*t20.*t21.*t23.*t29.*t59.*t60.*t69)./2.0;
    t100 = (bobs.*t20.*t21.*t23.*t30.*t52.*t69.*t84)./4.0;
    t105 = (bobs.*t20.*t21.*t24.*t29.*t59.*t69.*t84)./4.0;
    t106 = (bobs.*t20.*t21.*t24.*t29.*t60.*t69.*t84)./4.0;
    t89 = (bobs.*t19.*t22.*t29.*t37.*t53.*t59.*t71)./2.0;
    t90 = (bobs.*t19.*t22.*t29.*t37.*t53.*t60.*t71)./2.0;
    t91 = (bobs.*t19.*t22.*t28.*t37.*t53.*t61.*t71)./2.0;
    t92 = (bobs.*t19.*t22.*t31.*t37.*t53.*t57.*t59.*t71)./2.0;
    t93 = (bobs.*t19.*t22.*t31.*t37.*t53.*t57.*t60.*t71)./2.0;
    t96 = (bobs.*t19.*t23.*t28.*t37.*t53.*t71.*t73)./2.0;
    t97 = (bobs.*t19.*t23.*t28.*t37.*t53.*t71.*t74)./2.0;
    t98 = (bobs.*t19.*t23.*t30.*t37.*t52.*t53.*t59.*t60.*t71)./2.0;
    t101 = t21.*t22.*t26.*t30.*t52.*t59.*t69.*t83.*2.0;
    t102 = t21.*t22.*t26.*t30.*t52.*t60.*t69.*t83.*2.0;
    t107 = (bobs.*t19.*t23.*t29.*t37.*t53.*t71.*t84)./4.0;
    t108 = t22.*t26.*t29.*t37.*t53.*t59.*t71.*t82;
    t109 = t22.*t26.*t29.*t37.*t53.*t60.*t71.*t82;
    t110 = t22.*t26.*t28.*t37.*t53.*t61.*t71.*t82;
    t111 = -t105;
    t112 = -t106;
    t113 = t21.*t23.*t26.*t29.*t59.*t60.*t69.*t83.*2.0;
    t115 = (bobs.*t19.*t23.*t31.*t37.*t53.*t57.*t71.*t84)./4.0;
    t116 = t22.*t26.*t31.*t37.*t53.*t57.*t59.*t71.*t82;
    t117 = t22.*t26.*t31.*t37.*t53.*t57.*t60.*t71.*t82;
    t121 = t23.*t26.*t28.*t37.*t53.*t71.*t73.*t82;
    t122 = t23.*t26.*t28.*t37.*t53.*t71.*t74.*t82;
    t123 = (bobs.*t19.*t24.*t30.*t37.*t52.*t53.*t59.*t71.*t84)./4.0;
    t124 = (bobs.*t19.*t24.*t30.*t37.*t52.*t53.*t60.*t71.*t84)./4.0;
    t125 = t23.*t26.*t30.*t37.*t52.*t53.*t59.*t60.*t71.*t82;
    t127 = t21.*t23.*t26.*t30.*t52.*t69.*t83.*t84;
    t129 = t21.*t24.*t26.*t29.*t59.*t69.*t83.*t84;
    t130 = t21.*t24.*t26.*t29.*t60.*t69.*t83.*t84;
    t131 = (t23.*t26.*t29.*t37.*t53.*t71.*t82.*t84)./2.0;
    t132 = (t23.*t26.*t31.*t37.*t53.*t57.*t71.*t82.*t84)./2.0;
    t134 = (t24.*t26.*t30.*t37.*t52.*t53.*t59.*t71.*t82.*t84)./2.0;
    t135 = (t24.*t26.*t30.*t37.*t52.*t53.*t60.*t71.*t82.*t84)./2.0;
    t94 = -t92;
    t95 = -t93;
    t99 = -t98;
    t103 = -t101;
    t104 = -t102;
    t114 = -t113;
    t118 = -t115;
    t119 = -t116;
    t120 = -t117;
    t126 = -t125;
    t128 = -t127;
    t133 = -t132;
    t144 = t55+t96+t111+t121+t123+t129+t134;
    t145 = t56+t97+t112+t122+t124+t130+t135;
    t136 = t86+t89+t94+t103+t108+t119;
    t137 = t87+t90+t95+t104+t109+t120;
    t142 = t54+t88+t91+t99+t110+t114+t126;
    t146 = t100+t107+t118+t128+t131+t133;
    t147 = np.*t144;
    t148 = np.*t145;
    t138 = np.*t136;
    t139 = np.*t137;
    t143 = np.*t142;
    t149 = np.*t146;
    t150 = -t147;
    t151 = -t148;
    t140 = -t138;
    t141 = -t139;
    t152 = -t149;
    h = [np.*(t7.*t27+(bobs.*t20.*t21.*t23.*t29.*t64.*t69)./2.0-t21.*t23.*t26.*t29.*t64.*t69.*t83.*2.0+(bobs.*t19.*t22.*t28.*t37.*t53.*t62.*t71)./2.0+t22.*t26.*t28.*t37.*t53.*t62.*t71.*t82-(bobs.*t19.*t23.*t30.*t37.*t52.*t53.*t64.*t71)./2.0-t23.*t26.*t30.*t37.*t52.*t53.*t64.*t71.*t82),t143,t150,t80,t140,t143,np.*(t8.*t27+(bobs.*t20.*t21.*t23.*t29.*t65.*t69)./2.0-t21.*t23.*t26.*t29.*t65.*t69.*t83.*2.0+(bobs.*t19.*t22.*t28.*t37.*t53.*t63.*t71)./2.0+t22.*t26.*t28.*t37.*t53.*t63.*t71.*t82-(bobs.*t19.*t23.*t30.*t37.*t52.*t53.*t65.*t71)./2.0-t23.*t26.*t30.*t37.*t52.*t53.*t65.*t71.*t82),t151,t81,t141,t150,t151,-np.*(-p_i.^2.*t27-(bobs.*t20.*t21.*t25.*t29.*t69.*t85)./8.0+(t21.*t25.*t26.*t29.*t69.*t83.*t85)./2.0+(bobs.*t19.*t24.*t28.*t37.*t53.*t71.*t84)./2.0+t24.*t26.*t28.*t37.*t53.*t71.*t82.*t84+(bobs.*t19.*t25.*t30.*t37.*t52.*t53.*t71.*t85)./8.0+(t25.*t26.*t30.*t37.*t52.*t53.*t71.*t82.*t85)./4.0),t78,t152,t80,t81,t78,(OV.*nc.*np.*t44.*(KV.*3.0-1.0))./sig,t4,t140,t141,t152,t4,np.*((bobs.*t20.*t21.*t31.*t57.*t69)./2.0-t21.*t26.*t31.*t57.*t69.*t83.*2.0+bobs.*t19.*t30.*t37.*t52.*t53.*t71-(bobs.*t19.*t32.*t37.*t53.*t58.*t71)./2.0+t26.*t30.*t37.*t52.*t53.*t71.*t82.*2.0-t26.*t32.*t37.*t53.*t58.*t71.*t82)];
end
