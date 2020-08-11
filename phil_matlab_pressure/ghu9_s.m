function [val,g,h] = ghu9_s(AC,AVB,AVN,A_1,A_2,TCb,TCn,TVB,TVN,T_1b,T_2b,T_1n,T_2n,UV,alpha1,alpha0_1,alpha0_2,bobs,np,p_i,siga,theta0_1,theta0_2,y,yb)
%GHU9_S
%    [VAL,G,H] = GHU9_S(AC,AVB,AVN,A_1,A_2,TCB,TCN,TVB,TVN,T_1B,T_2B,T_1N,T_2N,UV,ALPHA1,ALPHA0_1,ALPHA0_2,BOBS,NP,P_I,SIGA,THETA0_1,THETA0_2,Y,YB)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    04-Jul-2020 12:51:56

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
t22 = UV.^3;
t23 = bobs.*2.0;
t24 = siga.^2;
t25 = AVB.*T_1b;
t26 = AVB.*T_2b;
t27 = AVN.*T_1n;
t28 = AVN.*T_2n;
t29 = UV.*siga.*2.0;
t38 = 1.0./pi;
t39 = -TVN;
t40 = -T_1n;
t41 = -T_2n;
t42 = 1.0./alpha1;
t47 = bobs-1.0;
t48 = 1.0./siga;
t53 = -yb;
t54 = AVB.*TVB.*2.0;
t55 = AVN.*TVN.*2.0;
t59 = sqrt(2.0);
t62 = sqrt(pi);
t30 = T_1b.*t12;
t31 = T_2b.*t12;
t32 = T_1n.*t12;
t33 = T_2n.*t12;
t34 = p_i.*t8;
t35 = p_i.*t9;
t36 = p_i.*t10;
t37 = p_i.*t11;
t43 = t42.^2;
t44 = t42.^3;
t46 = -t23;
t49 = 1.0./t24;
t50 = t48.^3;
t52 = t48.^5;
t56 = -t5;
t57 = -t7;
t58 = -t12;
t60 = TVB.*t12.*2.0;
t61 = TVN.*t12.*2.0;
t63 = -t54;
t64 = -t27;
t65 = -t28;
t66 = -t16;
t67 = -t19;
t68 = -t20;
t69 = TVB+t39;
t70 = T_1b+t40;
t71 = T_2b+t41;
t77 = 1.0./t62;
t78 = TCb+t8+t9;
t79 = TCn+t10+t11;
t97 = (UV.*t48.*t59)./2.0;
t45 = t43.^2;
t51 = t49.^2;
t72 = -t60;
t73 = -t32;
t74 = -t33;
t75 = -t36;
t76 = -t37;
t80 = t69.^2;
t81 = t21.*t49;
t82 = t25+t64;
t83 = t26+t65;
t84 = t4+t56;
t85 = t17+t67;
t86 = t18+t68;
t94 = t58+t78;
t95 = t58+t79;
t98 = erf(t97);
t87 = -t81;
t89 = t82.^2;
t90 = t83.^2;
t91 = t81./2.0;
t99 = t94.^2;
t100 = t95.^2;
t101 = t98+1.0;
t102 = t98.^2;
t103 = t98.^3;
t104 = t98-1.0;
t105 = t30+t73+t82;
t106 = t31+t74+t83;
t107 = UV.*siga.*t98.*4.0;
t113 = AC+t2+t3+t94;
t114 = AC+t2+t3+t95;
t119 = UV.*bobs.*siga.*t98.*8.0;
t131 = t15+t55+t61+t63+t66+t72;
t88 = exp(t87);
t92 = exp(t91);
t93 = -t91;
t108 = t99./2.0;
t109 = t100./2.0;
t110 = 1.0./t101;
t111 = t102-1.0;
t115 = 1.0./t104;
t117 = t46+t101;
t118 = t29.*t102;
t120 = -t119;
t128 = t78.*t113;
t129 = t79.*t114;
t134 = t131.^2;
t96 = 1.0./t92;
t112 = t110.^2;
t116 = t115.^2;
t121 = 1.0./t111;
t123 = t21.*t59.*t62.*t92;
t124 = t24.*t59.*t62.*t92;
t132 = -t128;
t133 = -t129;
t122 = t121.^2;
t125 = -t123;
t126 = t23.*t123;
t127 = t23.*t124;
t130 = bobs.*t124.*-2.0;
t135 = t98.*t123;
t136 = t98.*t124;
t137 = t102.*t123;
t138 = t103.*t123;
t139 = t102.*t124;
t140 = t103.*t124;
t147 = t108+t132;
t148 = t109+t133;
t149 = A_1.*UV.*t23.*t38.*t42.*t50.*t69.*t88.*t112;
t150 = A_2.*UV.*t23.*t38.*t42.*t50.*t69.*t88.*t112;
t153 = A_1.*A_2.*t23.*t38.*t43.*t49.*t80.*t88.*t112;
t154 = A_1.*A_2.*bobs.*t38.*t43.*t49.*t80.*t88.*t112.*-2.0;
t156 = A_1.*UV.*t38.*t42.*t47.*t50.*t69.*t88.*t116.*2.0;
t157 = A_2.*UV.*t38.*t42.*t47.*t50.*t69.*t88.*t116.*2.0;
t160 = A_1.*A_2.*t38.*t43.*t47.*t49.*t80.*t88.*t116.*2.0;
t161 = A_1.*bobs.*t42.*t49.*t59.*t69.*t77.*t96.*t110;
t162 = A_1.*bobs.*t43.*t48.*t59.*t69.*t77.*t96.*t110;
t163 = A_2.*bobs.*t42.*t49.*t59.*t69.*t77.*t96.*t110;
t164 = A_2.*bobs.*t43.*t48.*t59.*t69.*t77.*t96.*t110;
t165 = A_1.*bobs.*t42.*t48.*t59.*t70.*t77.*t96.*t110;
t166 = A_2.*bobs.*t42.*t48.*t59.*t70.*t77.*t96.*t110;
t167 = A_1.*bobs.*t42.*t48.*t59.*t71.*t77.*t96.*t110;
t168 = A_2.*bobs.*t42.*t48.*t59.*t71.*t77.*t96.*t110;
t169 = A_1.*t23.*t38.*t43.*t49.*t69.*t82.*t88.*t112;
t170 = A_2.*t23.*t38.*t43.*t49.*t69.*t82.*t88.*t112;
t171 = A_1.*t23.*t38.*t43.*t49.*t69.*t83.*t88.*t112;
t172 = A_2.*t23.*t38.*t43.*t49.*t69.*t83.*t88.*t112;
t173 = bobs.*t42.*t48.*t59.*t77.*t84.*t96.*t110;
t180 = A_1.*bobs.*t21.*t42.*t51.*t59.*t69.*t77.*t96.*t110;
t181 = A_2.*bobs.*t21.*t42.*t51.*t59.*t69.*t77.*t96.*t110;
t182 = t23.*t38.*t43.*t49.*t82.*t83.*t88.*t112;
t183 = A_1.*A_2.*UV.*bobs.*t43.*t50.*t59.*t77.*t80.*t96.*t110;
t184 = A_1.*t42.*t47.*t49.*t59.*t69.*t77.*t96.*t115;
t185 = A_1.*t43.*t47.*t48.*t59.*t69.*t77.*t96.*t115;
t186 = A_2.*t42.*t47.*t49.*t59.*t69.*t77.*t96.*t115;
t187 = A_2.*t43.*t47.*t48.*t59.*t69.*t77.*t96.*t115;
t188 = A_1.*t42.*t47.*t48.*t59.*t70.*t77.*t96.*t115;
t189 = A_2.*t42.*t47.*t48.*t59.*t70.*t77.*t96.*t115;
t190 = A_1.*t42.*t47.*t48.*t59.*t71.*t77.*t96.*t115;
t191 = A_2.*t42.*t47.*t48.*t59.*t71.*t77.*t96.*t115;
t192 = bobs.*t38.*t43.*t49.*t82.*t83.*t88.*t112.*-2.0;
t193 = A_1.*t38.*t43.*t47.*t49.*t69.*t82.*t88.*t116.*2.0;
t194 = A_2.*t38.*t43.*t47.*t49.*t69.*t82.*t88.*t116.*2.0;
t195 = A_1.*t38.*t43.*t47.*t49.*t69.*t83.*t88.*t116.*2.0;
t196 = A_2.*t38.*t43.*t47.*t49.*t69.*t83.*t88.*t116.*2.0;
t198 = t42.*t47.*t48.*t59.*t77.*t84.*t96.*t115;
t205 = t38.*t43.*t47.*t49.*t82.*t83.*t88.*t116.*2.0;
t206 = A_1.*t21.*t42.*t47.*t51.*t59.*t69.*t77.*t96.*t115;
t207 = A_2.*t21.*t42.*t47.*t51.*t59.*t69.*t77.*t96.*t115;
t209 = A_1.*A_2.*UV.*t43.*t47.*t50.*t59.*t77.*t80.*t96.*t115;
t212 = A_1.*UV.*bobs.*t43.*t50.*t59.*t69.*t77.*t82.*t96.*t110;
t213 = A_2.*UV.*bobs.*t43.*t50.*t59.*t69.*t77.*t82.*t96.*t110;
t214 = A_1.*UV.*bobs.*t43.*t50.*t59.*t69.*t77.*t83.*t96.*t110;
t215 = A_2.*UV.*bobs.*t43.*t50.*t59.*t69.*t77.*t83.*t96.*t110;
t216 = bobs.*t43.*t48.*t59.*t77.*t96.*t105.*t110;
t217 = bobs.*t43.*t48.*t59.*t77.*t96.*t106.*t110;
t218 = UV.*bobs.*t43.*t50.*t59.*t77.*t82.*t83.*t96.*t110;
t219 = A_1.*UV.*t43.*t47.*t50.*t59.*t69.*t77.*t82.*t96.*t115;
t220 = A_2.*UV.*t43.*t47.*t50.*t59.*t69.*t77.*t82.*t96.*t115;
t221 = A_1.*UV.*t43.*t47.*t50.*t59.*t69.*t77.*t83.*t96.*t115;
t222 = A_2.*UV.*t43.*t47.*t50.*t59.*t69.*t77.*t83.*t96.*t115;
t224 = UV.*t43.*t47.*t50.*t59.*t77.*t82.*t83.*t96.*t115;
t229 = t43.*t47.*t48.*t59.*t77.*t96.*t105.*t115;
t230 = t43.*t47.*t48.*t59.*t77.*t96.*t106.*t115;
t233 = A_1.*bobs.*t38.*t44.*t49.*t69.*t88.*t112.*t131;
t234 = A_2.*bobs.*t38.*t44.*t49.*t69.*t88.*t112.*t131;
t235 = bobs.*t38.*t44.*t49.*t82.*t88.*t112.*t131;
t236 = bobs.*t38.*t44.*t49.*t83.*t88.*t112.*t131;
t237 = A_1.*t38.*t44.*t47.*t49.*t69.*t88.*t116.*t131;
t238 = A_2.*t38.*t44.*t47.*t49.*t69.*t88.*t116.*t131;
t239 = t38.*t44.*t47.*t49.*t82.*t88.*t116.*t131;
t240 = t38.*t44.*t47.*t49.*t83.*t88.*t116.*t131;
t245 = (A_1.*UV.*bobs.*t44.*t50.*t59.*t69.*t77.*t96.*t110.*t131)./2.0;
t246 = (A_2.*UV.*bobs.*t44.*t50.*t59.*t69.*t77.*t96.*t110.*t131)./2.0;
t247 = (UV.*bobs.*t44.*t50.*t59.*t77.*t82.*t96.*t110.*t131)./2.0;
t248 = (UV.*bobs.*t44.*t50.*t59.*t77.*t83.*t96.*t110.*t131)./2.0;
t249 = (A_1.*UV.*t44.*t47.*t50.*t59.*t69.*t77.*t96.*t115.*t131)./2.0;
t250 = (A_2.*UV.*t44.*t47.*t50.*t59.*t69.*t77.*t96.*t115.*t131)./2.0;
t253 = (UV.*t44.*t47.*t50.*t59.*t77.*t82.*t96.*t115.*t131)./2.0;
t254 = (UV.*t44.*t47.*t50.*t59.*t77.*t83.*t96.*t115.*t131)./2.0;
t141 = t98.*t125;
t142 = -t139;
t143 = -t140;
t144 = t102.*t126;
t145 = t102.*t127;
t146 = bobs.*t137.*-2.0;
t151 = t42.*t147;
t152 = t42.*t148;
t158 = -t156;
t159 = -t157;
t174 = -t161;
t175 = -t163;
t176 = -t165;
t177 = -t166;
t178 = -t167;
t179 = -t168;
t197 = -t183;
t199 = -t193;
t200 = -t194;
t201 = -t195;
t202 = -t196;
t203 = -t185;
t204 = -t187;
t208 = -t198;
t210 = -t206;
t211 = -t207;
t223 = -t218;
t225 = -t219;
t226 = -t220;
t227 = -t221;
t228 = -t222;
t231 = -t229;
t232 = -t230;
t241 = -t237;
t242 = -t238;
t243 = -t239;
t244 = -t240;
t251 = -t249;
t252 = -t250;
t255 = -t253;
t256 = -t254;
t262 = -np.*(t153-t160+t183-t209);
t263 = np.*(t153-t160+t183-t209);
t274 = -np.*(t165-t188+t193-t212+t219+A_1.*t38.*t43.*t46.*t49.*t69.*t82.*t88.*t112);
t275 = -np.*(t166-t189+t194-t213+t220+A_2.*t38.*t43.*t46.*t49.*t69.*t82.*t88.*t112);
t276 = -np.*(t167-t190+t195-t214+t221+A_1.*t38.*t43.*t46.*t49.*t69.*t83.*t88.*t112);
t277 = -np.*(t168-t191+t196-t215+t222+A_2.*t38.*t43.*t46.*t49.*t69.*t83.*t88.*t112);
t155 = -t152;
t261 = t154+t160+t197+t209;
t264 = t149+t158+t174+t180+t184+t210;
t265 = t150+t159+t175+t181+t186+t211;
t270 = t169+t176+t188+t199+t212+t225;
t271 = t170+t177+t189+t200+t213+t226;
t272 = t171+t178+t190+t201+t214+t227;
t273 = t172+t179+t191+t202+t215+t228;
t278 = t173+t192+t205+t208+t223+t224;
t281 = t162+t203+t233+t241+t245+t251;
t282 = t164+t204+t234+t242+t246+t252;
t285 = t216+t231+t235+t243+t247+t255;
t286 = t217+t232+t236+t244+t248+t256;
t289 = t29+t107+t118+t120+t124+t125+t126+t130+t136+t137+t138+t141+t142+t143+t145+t146;
t257 = t6+t34+t35+t53+t57+t75+t76+t151+t155+y;
t266 = np.*t264;
t267 = np.*t265;
t279 = np.*t278;
t283 = np.*t281;
t284 = np.*t282;
t287 = np.*t285;
t288 = np.*t286;
t290 = np.*t38.*t42.*t51.*t82.*t88.*t122.*t289;
t291 = np.*t38.*t42.*t51.*t83.*t88.*t122.*t289;
t294 = (np.*t38.*t43.*t51.*t88.*t122.*t131.*t289)./2.0;
t258 = (t48.*t59.*t257)./2.0;
t268 = -t266;
t269 = -t267;
t280 = -t279;
t292 = -t290;
t293 = -t291;
t295 = -t294;
t259 = erf(t258);
t260 = t259./2.0;
val = t47.*log(t260+1.0./2.0)-bobs.*log(-t260+1.0./2.0);
if nargout > 1
    g = [-A_1.*np.*t42.*t48.*t59.*t69.*t77.*t96.*t117.*t121,-A_2.*np.*t42.*t48.*t59.*t69.*t77.*t96.*t117.*t121,-np.*t42.*t48.*t59.*t77.*t82.*t96.*t117.*t121,-np.*t42.*t48.*t59.*t77.*t83.*t96.*t117.*t121,np.*t43.*t48.*t59.*t77.*t96.*t117.*t121.*t131.*(-1.0./2.0),UV.*np.*t49.*t59.*t77.*t96.*t117.*t121];
end
if nargout > 2
    h = [np.*(t13.*t23.*t38.*t43.*t49.*t80.*t88.*t112-t13.*t38.*t43.*t47.*t49.*t80.*t88.*t116.*2.0+UV.*bobs.*t13.*t43.*t50.*t59.*t77.*t80.*t96.*t110-UV.*t13.*t43.*t47.*t50.*t59.*t77.*t80.*t96.*t115),t263,t274,t276,t283,t268,t263,np.*(t14.*t23.*t38.*t43.*t49.*t80.*t88.*t112-t14.*t38.*t43.*t47.*t49.*t80.*t88.*t116.*2.0+UV.*bobs.*t14.*t43.*t50.*t59.*t77.*t80.*t96.*t110-UV.*t14.*t43.*t47.*t50.*t59.*t77.*t80.*t96.*t115),t275,t277,t284,t269,t274,t275,np.*(bobs.*t38.*t43.*t49.*t88.*t89.*t112.*2.0-t38.*t43.*t47.*t49.*t88.*t89.*t116.*2.0-bobs.*t42.*t48.*t59.*t77.*t85.*t96.*t110+t42.*t47.*t48.*t59.*t77.*t85.*t96.*t115+UV.*bobs.*t43.*t50.*t59.*t77.*t89.*t96.*t110-UV.*t43.*t47.*t50.*t59.*t77.*t89.*t96.*t115),t280,t287,t292,t276,t277,t280,np.*(bobs.*t38.*t43.*t49.*t88.*t90.*t112.*2.0-t38.*t43.*t47.*t49.*t88.*t90.*t116.*2.0-bobs.*t42.*t48.*t59.*t77.*t86.*t96.*t110+t42.*t47.*t48.*t59.*t77.*t86.*t96.*t115+UV.*bobs.*t43.*t50.*t59.*t77.*t90.*t96.*t110-UV.*t43.*t47.*t50.*t59.*t77.*t90.*t96.*t115),t288,t293,t283,t284,t287,t288,np.*((bobs.*t38.*t45.*t49.*t88.*t112.*t134)./2.0-(t38.*t45.*t47.*t49.*t88.*t116.*t134)./2.0+bobs.*t44.*t48.*t59.*t77.*t96.*t110.*t131-t44.*t47.*t48.*t59.*t77.*t96.*t115.*t131+(UV.*bobs.*t45.*t50.*t59.*t77.*t96.*t110.*t134)./4.0-(UV.*t45.*t47.*t50.*t59.*t77.*t96.*t115.*t134)./4.0),t295,t268,t269,t292,t293,t295,np.*(bobs.*t21.*t38.*t51.*t88.*t112.*2.0-t21.*t38.*t47.*t51.*t88.*t116.*2.0+UV.*t46.*t50.*t59.*t77.*t96.*t110+UV.*t47.*t50.*t59.*t77.*t96.*t115.*2.0+bobs.*t22.*t52.*t59.*t77.*t96.*t110-t22.*t47.*t52.*t59.*t77.*t96.*t115)];
end