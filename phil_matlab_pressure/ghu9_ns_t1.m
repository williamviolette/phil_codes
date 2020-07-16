function [val,g,h] = ghu9_ns_t1(AC,AVB,AVN,A_1,A_2,TCb,TCn,TVB,TVN,T_1b,T_2b,T_1n,T_2n,UV,alpha1,alpha0_1,alpha0_2,bobs,np,p_i,siga,theta0_1,theta0_2,y,yb)
%GHU9_NS_T1
%    [VAL,G,H] = GHU9_NS_T1(AC,AVB,AVN,A_1,A_2,TCB,TCN,TVB,TVN,T_1B,T_2B,T_1N,T_2N,UV,ALPHA1,ALPHA0_1,ALPHA0_2,BOBS,NP,P_I,SIGA,THETA0_1,THETA0_2,Y,YB)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    04-Jul-2020 12:22:48

t2 = A_1.*alpha0_1;
t3 = A_2.*alpha0_2;
t4 = T_1b.*T_2b;
t5 = T_1n.*T_2n;
t6 = TCb.*p_i;
t7 = TCn.*p_i;
t8 = T_1b.*theta0_1;
t9 = T_2b.*theta0_2;
t10 = T_1n.*theta0_1;
t11 = T_2n.*theta0_2;
t12 = alpha1.*p_i;
t13 = TVB.^2;
t14 = TVN.^2;
t15 = T_1b.^2;
t16 = T_2b.^2;
t17 = T_1n.^2;
t18 = T_2n.^2;
t19 = UV.^2;
t20 = UV.^3;
t21 = bobs.*2.0;
t22 = siga.^2;
t23 = AVB.*T_1b;
t24 = AVB.*T_2b;
t25 = AVN.*T_1n;
t26 = AVN.*T_2n;
t27 = UV.*siga.*2.0;
t36 = 1.0./pi;
t37 = 1.0./alpha1;
t42 = bobs-1.0;
t43 = 1.0./siga;
t48 = -yb;
t49 = AVB.*TVB.*2.0;
t50 = AVN.*TVN.*2.0;
t54 = sqrt(2.0);
t57 = sqrt(pi);
t28 = T_1b.*t12;
t29 = T_2b.*t12;
t30 = T_1n.*t12;
t31 = T_2n.*t12;
t32 = p_i.*t8;
t33 = p_i.*t9;
t34 = p_i.*t10;
t35 = p_i.*t11;
t38 = t37.^2;
t39 = t37.^3;
t41 = -t21;
t44 = 1.0./t22;
t45 = t43.^3;
t47 = t43.^5;
t51 = -t5;
t52 = -t7;
t53 = -t12;
t55 = TVB.*t12.*2.0;
t56 = TVN.*t12.*2.0;
t58 = -t49;
t59 = -t25;
t60 = -t26;
t61 = -t14;
t62 = -t17;
t63 = -t18;
t69 = 1.0./t57;
t70 = TCb+t8+t9;
t71 = TCn+t10+t11;
t88 = (UV.*t43.*t54)./2.0;
t40 = t38.^2;
t46 = t44.^2;
t64 = -t55;
t65 = -t30;
t66 = -t31;
t67 = -t34;
t68 = -t35;
t72 = t19.*t44;
t73 = t23+t59;
t74 = t24+t60;
t75 = t4+t51;
t76 = t15+t62;
t77 = t16+t63;
t85 = t53+t70;
t86 = t53+t71;
t89 = erf(t88);
t78 = -t72;
t80 = t73.^2;
t81 = t74.^2;
t82 = t72./2.0;
t90 = t85.^2;
t91 = t86.^2;
t92 = t89+1.0;
t93 = t89.^2;
t94 = t89.^3;
t95 = t89-1.0;
t96 = t28+t65+t73;
t97 = t29+t66+t74;
t98 = UV.*siga.*t89.*4.0;
t104 = AC+t2+t3+t85;
t105 = AC+t2+t3+t86;
t110 = UV.*bobs.*siga.*t89.*8.0;
t122 = t13+t50+t56+t58+t61+t64;
t79 = exp(t78);
t83 = exp(t82);
t84 = -t82;
t99 = t90./2.0;
t100 = t91./2.0;
t101 = 1.0./t92;
t102 = t93-1.0;
t106 = 1.0./t95;
t108 = t41+t92;
t109 = t27.*t93;
t111 = -t110;
t119 = t70.*t104;
t120 = t71.*t105;
t125 = t122.^2;
t87 = 1.0./t83;
t103 = t101.^2;
t107 = t106.^2;
t112 = 1.0./t102;
t114 = t19.*t54.*t57.*t83;
t115 = t22.*t54.*t57.*t83;
t123 = -t119;
t124 = -t120;
t113 = t112.^2;
t116 = -t114;
t117 = t21.*t114;
t118 = t21.*t115;
t121 = bobs.*t115.*-2.0;
t126 = t89.*t114;
t127 = t89.*t115;
t128 = t93.*t114;
t129 = t94.*t114;
t130 = t93.*t115;
t131 = t94.*t115;
t138 = t99+t123;
t139 = t100+t124;
t143 = bobs.*t37.*t43.*t54.*t69.*t75.*t87.*t101;
t144 = t21.*t36.*t38.*t44.*t73.*t74.*t79.*t103;
t145 = bobs.*t36.*t38.*t44.*t73.*t74.*t79.*t103.*-2.0;
t146 = t37.*t42.*t43.*t54.*t69.*t75.*t87.*t106;
t147 = t36.*t38.*t42.*t44.*t73.*t74.*t79.*t107.*2.0;
t149 = bobs.*t38.*t43.*t54.*t69.*t87.*t96.*t101;
t150 = bobs.*t38.*t43.*t54.*t69.*t87.*t97.*t101;
t151 = UV.*bobs.*t38.*t45.*t54.*t69.*t73.*t74.*t87.*t101;
t153 = UV.*t38.*t42.*t45.*t54.*t69.*t73.*t74.*t87.*t106;
t154 = t38.*t42.*t43.*t54.*t69.*t87.*t96.*t106;
t155 = t38.*t42.*t43.*t54.*t69.*t87.*t97.*t106;
t158 = bobs.*t36.*t39.*t44.*t73.*t79.*t103.*t122;
t159 = bobs.*t36.*t39.*t44.*t74.*t79.*t103.*t122;
t160 = t36.*t39.*t42.*t44.*t73.*t79.*t107.*t122;
t161 = t36.*t39.*t42.*t44.*t74.*t79.*t107.*t122;
t164 = (UV.*bobs.*t39.*t45.*t54.*t69.*t73.*t87.*t101.*t122)./2.0;
t165 = (UV.*bobs.*t39.*t45.*t54.*t69.*t74.*t87.*t101.*t122)./2.0;
t166 = (UV.*t39.*t42.*t45.*t54.*t69.*t73.*t87.*t106.*t122)./2.0;
t167 = (UV.*t39.*t42.*t45.*t54.*t69.*t74.*t87.*t106.*t122)./2.0;
t132 = t89.*t116;
t133 = -t130;
t134 = -t131;
t135 = t93.*t117;
t136 = t93.*t118;
t137 = bobs.*t128.*-2.0;
t140 = t37.*t138;
t141 = t37.*t139;
t148 = -t146;
t152 = -t151;
t156 = -t154;
t157 = -t155;
t162 = -t160;
t163 = -t161;
t168 = -t166;
t169 = -t167;
t142 = -t141;
t174 = t143+t145+t147+t148+t152+t153;
t177 = t149+t156+t158+t162+t164+t168;
t178 = t150+t157+t159+t163+t165+t169;
t181 = t27+t98+t109+t111+t115+t116+t117+t121+t127+t128+t129+t132+t133+t134+t136+t137;
t170 = t6+t32+t33+t48+t52+t67+t68+t140+t142+y;
t175 = np.*t174;
t179 = np.*t177;
t180 = np.*t178;
t182 = np.*t36.*t37.*t46.*t73.*t79.*t113.*t181;
t183 = np.*t36.*t37.*t46.*t74.*t79.*t113.*t181;
t186 = (np.*t36.*t38.*t46.*t79.*t113.*t122.*t181)./2.0;
t171 = (t43.*t54.*t170)./2.0;
t176 = -t175;
t184 = -t182;
t185 = -t183;
t187 = -t186;
t172 = erf(t171);
t173 = t172./2.0;
val = t42.*log(t173+1.0./2.0)-bobs.*log(-t173+1.0./2.0);
if nargout > 1
    g = [-np.*t37.*t43.*t54.*t69.*t73.*t87.*t108.*t112,-np.*t37.*t43.*t54.*t69.*t74.*t87.*t108.*t112,np.*t38.*t43.*t54.*t69.*t87.*t108.*t112.*t122.*(-1.0./2.0),UV.*np.*t44.*t54.*t69.*t87.*t108.*t112];
end
if nargout > 2
    h = [np.*(bobs.*t36.*t38.*t44.*t79.*t80.*t103.*2.0-t36.*t38.*t42.*t44.*t79.*t80.*t107.*2.0-bobs.*t37.*t43.*t54.*t69.*t76.*t87.*t101+t37.*t42.*t43.*t54.*t69.*t76.*t87.*t106+UV.*bobs.*t38.*t45.*t54.*t69.*t80.*t87.*t101-UV.*t38.*t42.*t45.*t54.*t69.*t80.*t87.*t106),t176,t179,t184,t176,np.*(bobs.*t36.*t38.*t44.*t79.*t81.*t103.*2.0-t36.*t38.*t42.*t44.*t79.*t81.*t107.*2.0-bobs.*t37.*t43.*t54.*t69.*t77.*t87.*t101+t37.*t42.*t43.*t54.*t69.*t77.*t87.*t106+UV.*bobs.*t38.*t45.*t54.*t69.*t81.*t87.*t101-UV.*t38.*t42.*t45.*t54.*t69.*t81.*t87.*t106),t180,t185,t179,t180,np.*((bobs.*t36.*t40.*t44.*t79.*t103.*t125)./2.0-(t36.*t40.*t42.*t44.*t79.*t107.*t125)./2.0+bobs.*t39.*t43.*t54.*t69.*t87.*t101.*t122-t39.*t42.*t43.*t54.*t69.*t87.*t106.*t122+(UV.*bobs.*t40.*t45.*t54.*t69.*t87.*t101.*t125)./4.0-(UV.*t40.*t42.*t45.*t54.*t69.*t87.*t106.*t125)./4.0),t187,t184,t185,t187,np.*(bobs.*t19.*t36.*t46.*t79.*t103.*2.0-t19.*t36.*t42.*t46.*t79.*t107.*2.0+UV.*t41.*t45.*t54.*t69.*t87.*t101+UV.*t42.*t45.*t54.*t69.*t87.*t106.*2.0+bobs.*t20.*t47.*t54.*t69.*t87.*t101-t20.*t42.*t47.*t54.*t69.*t87.*t106)];
end
