function [val,g,h] = ghu9_ns(AC,AVB,AVN,A_1,A_2,TCb,TCn,TVB,TVN,T_1b,T_2b,T_1n,T_2n,UV,alpha1,alpha0_1,alpha0_2,bobs,np,p_i,siga,theta0_1,theta0_2,y,yb)
%GHU9_NS
%    [VAL,G,H] = GHU9_NS(AC,AVB,AVN,A_1,A_2,TCB,TCN,TVB,TVN,T_1B,T_2B,T_1N,T_2N,UV,ALPHA1,ALPHA0_1,ALPHA0_2,BOBS,NP,P_I,SIGA,THETA0_1,THETA0_2,Y,YB)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    04-Jul-2020 12:21:13

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
t13 = A_1.^2;
t14 = A_2.^2;
t15 = TVB.^2;
t16 = TVN.^2;
t17 = T_1b.^2;
t18 = T_2b.^2;
t19 = T_1n.^2;
t20 = T_2n.^2;
t21 = UV.^2;
t22 = bobs.*2.0;
t23 = AVB.*T_1b;
t24 = AVB.*T_2b;
t25 = AVN.*T_1n;
t26 = AVN.*T_2n;
t35 = 1.0./pi;
t36 = -TVN;
t37 = -T_1n;
t38 = -T_2n;
t39 = 1.0./alpha1;
t44 = bobs-1.0;
t45 = 1.0./siga;
t48 = -yb;
t49 = AVB.*TVB.*2.0;
t50 = AVN.*TVN.*2.0;
t54 = sqrt(2.0);
t71 = 1.0./sqrt(pi);
t27 = T_1b.*t12;
t28 = T_2b.*t12;
t29 = T_1n.*t12;
t30 = T_2n.*t12;
t31 = p_i.*t8;
t32 = p_i.*t9;
t33 = p_i.*t10;
t34 = p_i.*t11;
t40 = t39.^2;
t41 = t39.^3;
t43 = -t22;
t46 = t45.^2;
t47 = t45.^3;
t51 = -t5;
t52 = -t7;
t53 = -t12;
t55 = TVB.*t12.*2.0;
t56 = TVN.*t12.*2.0;
t57 = -t49;
t58 = -t25;
t59 = -t26;
t60 = -t16;
t61 = -t19;
t62 = -t20;
t63 = TVB+t36;
t64 = T_1b+t37;
t65 = T_2b+t38;
t72 = TCb+t8+t9;
t73 = TCn+t10+t11;
t90 = (UV.*t45.*t54)./2.0;
t42 = t40.^2;
t66 = -t55;
t67 = -t29;
t68 = -t30;
t69 = -t33;
t70 = -t34;
t74 = t63.^2;
t75 = t21.*t46;
t76 = t23+t58;
t77 = t24+t59;
t78 = t4+t51;
t79 = t17+t61;
t80 = t18+t62;
t87 = t53+t72;
t88 = t53+t73;
t91 = erf(t90);
t81 = -t75;
t83 = t76.^2;
t84 = t77.^2;
t85 = t75./2.0;
t92 = t87.^2;
t93 = t88.^2;
t94 = t91+1.0;
t95 = t91.^2;
t96 = t91-1.0;
t97 = t27+t67+t76;
t98 = t28+t68+t77;
t104 = AC+t2+t3+t87;
t105 = AC+t2+t3+t88;
t112 = t15+t50+t56+t57+t60+t66;
t82 = exp(t81);
t86 = -t85;
t99 = t92./2.0;
t100 = t93./2.0;
t101 = 1.0./t94;
t102 = t95-1.0;
t106 = 1.0./t96;
t108 = t43+t94;
t110 = t72.*t104;
t111 = t73.*t105;
t115 = t112.^2;
t89 = exp(t86);
t103 = t101.^2;
t107 = t106.^2;
t109 = 1.0./t102;
t113 = -t110;
t114 = -t111;
t116 = t99+t113;
t117 = t100+t114;
t120 = A_1.*A_2.*t22.*t35.*t40.*t46.*t74.*t82.*t103;
t121 = A_1.*A_2.*bobs.*t35.*t40.*t46.*t74.*t82.*t103.*-2.0;
t123 = A_1.*A_2.*t35.*t40.*t44.*t46.*t74.*t82.*t107.*2.0;
t124 = A_1.*bobs.*t40.*t45.*t54.*t63.*t71.*t89.*t101;
t125 = A_2.*bobs.*t40.*t45.*t54.*t63.*t71.*t89.*t101;
t126 = A_1.*bobs.*t39.*t45.*t54.*t64.*t71.*t89.*t101;
t127 = A_2.*bobs.*t39.*t45.*t54.*t64.*t71.*t89.*t101;
t128 = A_1.*bobs.*t39.*t45.*t54.*t65.*t71.*t89.*t101;
t129 = A_2.*bobs.*t39.*t45.*t54.*t65.*t71.*t89.*t101;
t130 = A_1.*t22.*t35.*t40.*t46.*t63.*t76.*t82.*t103;
t131 = A_2.*t22.*t35.*t40.*t46.*t63.*t76.*t82.*t103;
t132 = A_1.*t22.*t35.*t40.*t46.*t63.*t77.*t82.*t103;
t133 = A_2.*t22.*t35.*t40.*t46.*t63.*t77.*t82.*t103;
t134 = bobs.*t39.*t45.*t54.*t71.*t78.*t89.*t101;
t139 = t22.*t35.*t40.*t46.*t76.*t77.*t82.*t103;
t140 = A_1.*A_2.*UV.*bobs.*t40.*t47.*t54.*t71.*t74.*t89.*t101;
t141 = A_1.*t40.*t44.*t45.*t54.*t63.*t71.*t89.*t106;
t142 = A_2.*t40.*t44.*t45.*t54.*t63.*t71.*t89.*t106;
t143 = A_1.*t39.*t44.*t45.*t54.*t64.*t71.*t89.*t106;
t144 = A_2.*t39.*t44.*t45.*t54.*t64.*t71.*t89.*t106;
t145 = A_1.*t39.*t44.*t45.*t54.*t65.*t71.*t89.*t106;
t146 = A_2.*t39.*t44.*t45.*t54.*t65.*t71.*t89.*t106;
t147 = bobs.*t35.*t40.*t46.*t76.*t77.*t82.*t103.*-2.0;
t148 = A_1.*t35.*t40.*t44.*t46.*t63.*t76.*t82.*t107.*2.0;
t149 = A_2.*t35.*t40.*t44.*t46.*t63.*t76.*t82.*t107.*2.0;
t150 = A_1.*t35.*t40.*t44.*t46.*t63.*t77.*t82.*t107.*2.0;
t151 = A_2.*t35.*t40.*t44.*t46.*t63.*t77.*t82.*t107.*2.0;
t153 = t39.*t44.*t45.*t54.*t71.*t78.*t89.*t106;
t160 = t35.*t40.*t44.*t46.*t76.*t77.*t82.*t107.*2.0;
t162 = A_1.*A_2.*UV.*t40.*t44.*t47.*t54.*t71.*t74.*t89.*t106;
t163 = A_1.*UV.*bobs.*t40.*t47.*t54.*t63.*t71.*t76.*t89.*t101;
t164 = A_2.*UV.*bobs.*t40.*t47.*t54.*t63.*t71.*t76.*t89.*t101;
t165 = A_1.*UV.*bobs.*t40.*t47.*t54.*t63.*t71.*t77.*t89.*t101;
t166 = A_2.*UV.*bobs.*t40.*t47.*t54.*t63.*t71.*t77.*t89.*t101;
t167 = bobs.*t40.*t45.*t54.*t71.*t89.*t97.*t101;
t168 = bobs.*t40.*t45.*t54.*t71.*t89.*t98.*t101;
t169 = UV.*bobs.*t40.*t47.*t54.*t71.*t76.*t77.*t89.*t101;
t170 = A_1.*UV.*t40.*t44.*t47.*t54.*t63.*t71.*t76.*t89.*t106;
t171 = A_2.*UV.*t40.*t44.*t47.*t54.*t63.*t71.*t76.*t89.*t106;
t172 = A_1.*UV.*t40.*t44.*t47.*t54.*t63.*t71.*t77.*t89.*t106;
t173 = A_2.*UV.*t40.*t44.*t47.*t54.*t63.*t71.*t77.*t89.*t106;
t175 = UV.*t40.*t44.*t47.*t54.*t71.*t76.*t77.*t89.*t106;
t180 = t40.*t44.*t45.*t54.*t71.*t89.*t97.*t106;
t181 = t40.*t44.*t45.*t54.*t71.*t89.*t98.*t106;
t184 = A_1.*bobs.*t35.*t41.*t46.*t63.*t82.*t103.*t112;
t185 = A_2.*bobs.*t35.*t41.*t46.*t63.*t82.*t103.*t112;
t186 = bobs.*t35.*t41.*t46.*t76.*t82.*t103.*t112;
t187 = bobs.*t35.*t41.*t46.*t77.*t82.*t103.*t112;
t188 = A_1.*t35.*t41.*t44.*t46.*t63.*t82.*t107.*t112;
t189 = A_2.*t35.*t41.*t44.*t46.*t63.*t82.*t107.*t112;
t190 = t35.*t41.*t44.*t46.*t76.*t82.*t107.*t112;
t191 = t35.*t41.*t44.*t46.*t77.*t82.*t107.*t112;
t196 = (A_1.*UV.*bobs.*t41.*t47.*t54.*t63.*t71.*t89.*t101.*t112)./2.0;
t197 = (A_2.*UV.*bobs.*t41.*t47.*t54.*t63.*t71.*t89.*t101.*t112)./2.0;
t198 = (UV.*bobs.*t41.*t47.*t54.*t71.*t76.*t89.*t101.*t112)./2.0;
t199 = (UV.*bobs.*t41.*t47.*t54.*t71.*t77.*t89.*t101.*t112)./2.0;
t200 = (A_1.*UV.*t41.*t44.*t47.*t54.*t63.*t71.*t89.*t106.*t112)./2.0;
t201 = (A_2.*UV.*t41.*t44.*t47.*t54.*t63.*t71.*t89.*t106.*t112)./2.0;
t204 = (UV.*t41.*t44.*t47.*t54.*t71.*t76.*t89.*t106.*t112)./2.0;
t205 = (UV.*t41.*t44.*t47.*t54.*t71.*t77.*t89.*t106.*t112)./2.0;
t118 = t39.*t116;
t119 = t39.*t117;
t135 = -t126;
t136 = -t127;
t137 = -t128;
t138 = -t129;
t152 = -t140;
t154 = -t148;
t155 = -t149;
t156 = -t150;
t157 = -t151;
t158 = -t141;
t159 = -t142;
t161 = -t153;
t174 = -t169;
t176 = -t170;
t177 = -t171;
t178 = -t172;
t179 = -t173;
t182 = -t180;
t183 = -t181;
t192 = -t188;
t193 = -t189;
t194 = -t190;
t195 = -t191;
t202 = -t200;
t203 = -t201;
t206 = -t204;
t207 = -t205;
t213 = -np.*(t120-t123+t140-t162);
t214 = np.*(t120-t123+t140-t162);
t219 = -np.*(t126-t143+t148-t163+t170+A_1.*t35.*t40.*t43.*t46.*t63.*t76.*t82.*t103);
t220 = -np.*(t127-t144+t149-t164+t171+A_2.*t35.*t40.*t43.*t46.*t63.*t76.*t82.*t103);
t221 = -np.*(t128-t145+t150-t165+t172+A_1.*t35.*t40.*t43.*t46.*t63.*t77.*t82.*t103);
t222 = -np.*(t129-t146+t151-t166+t173+A_2.*t35.*t40.*t43.*t46.*t63.*t77.*t82.*t103);
t122 = -t119;
t212 = t121+t123+t152+t162;
t215 = t130+t135+t143+t154+t163+t176;
t216 = t131+t136+t144+t155+t164+t177;
t217 = t132+t137+t145+t156+t165+t178;
t218 = t133+t138+t146+t157+t166+t179;
t223 = t134+t147+t160+t161+t174+t175;
t226 = t124+t158+t184+t192+t196+t202;
t227 = t125+t159+t185+t193+t197+t203;
t230 = t167+t182+t186+t194+t198+t206;
t231 = t168+t183+t187+t195+t199+t207;
t208 = t6+t31+t32+t48+t52+t69+t70+t118+t122+y;
t224 = np.*t223;
t228 = np.*t226;
t229 = np.*t227;
t232 = np.*t230;
t233 = np.*t231;
t209 = (t45.*t54.*t208)./2.0;
t225 = -t224;
t210 = erf(t209);
t211 = t210./2.0;
val = t44.*log(t211+1.0./2.0)-bobs.*log(-t211+1.0./2.0);
if nargout > 1
    g = [-A_1.*np.*t39.*t45.*t54.*t63.*t71.*t89.*t108.*t109,-A_2.*np.*t39.*t45.*t54.*t63.*t71.*t89.*t108.*t109,-np.*t39.*t45.*t54.*t71.*t76.*t89.*t108.*t109,-np.*t39.*t45.*t54.*t71.*t77.*t89.*t108.*t109,np.*t40.*t45.*t54.*t71.*t89.*t108.*t109.*t112.*(-1.0./2.0)];
end
if nargout > 2
    h = [np.*(t13.*t22.*t35.*t40.*t46.*t74.*t82.*t103-t13.*t35.*t40.*t44.*t46.*t74.*t82.*t107.*2.0+UV.*bobs.*t13.*t40.*t47.*t54.*t71.*t74.*t89.*t101-UV.*t13.*t40.*t44.*t47.*t54.*t71.*t74.*t89.*t106),t214,t219,t221,t228,t214,np.*(t14.*t22.*t35.*t40.*t46.*t74.*t82.*t103-t14.*t35.*t40.*t44.*t46.*t74.*t82.*t107.*2.0+UV.*bobs.*t14.*t40.*t47.*t54.*t71.*t74.*t89.*t101-UV.*t14.*t40.*t44.*t47.*t54.*t71.*t74.*t89.*t106),t220,t222,t229,t219,t220,np.*(bobs.*t35.*t40.*t46.*t82.*t83.*t103.*2.0-t35.*t40.*t44.*t46.*t82.*t83.*t107.*2.0-bobs.*t39.*t45.*t54.*t71.*t79.*t89.*t101+t39.*t44.*t45.*t54.*t71.*t79.*t89.*t106+UV.*bobs.*t40.*t47.*t54.*t71.*t83.*t89.*t101-UV.*t40.*t44.*t47.*t54.*t71.*t83.*t89.*t106),t225,t232,t221,t222,t225,np.*(bobs.*t35.*t40.*t46.*t82.*t84.*t103.*2.0-t35.*t40.*t44.*t46.*t82.*t84.*t107.*2.0-bobs.*t39.*t45.*t54.*t71.*t80.*t89.*t101+t39.*t44.*t45.*t54.*t71.*t80.*t89.*t106+UV.*bobs.*t40.*t47.*t54.*t71.*t84.*t89.*t101-UV.*t40.*t44.*t47.*t54.*t71.*t84.*t89.*t106),t233,t228,t229,t232,t233,np.*((bobs.*t35.*t42.*t46.*t82.*t103.*t115)./2.0-(t35.*t42.*t44.*t46.*t82.*t107.*t115)./2.0+bobs.*t41.*t45.*t54.*t71.*t89.*t101.*t112-t41.*t44.*t45.*t54.*t71.*t89.*t106.*t112+(UV.*bobs.*t42.*t47.*t54.*t71.*t89.*t101.*t115)./4.0-(UV.*t42.*t44.*t47.*t54.*t71.*t89.*t106.*t115)./4.0)];
end
