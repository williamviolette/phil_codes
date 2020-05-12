
clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab_new/';

syms y p1 p2 a g g1 g2 w x F l
assume(y>0)
assume(p1>0)
assume(p2>0)
assume(a>0)
assume(g>0)
assume(g1>0)
assume(g2>0)
assume(w>0)
assume(x>0)
assume(l>0)

BC = ( y -   (p1*w+x) ) 

u = x + w - (1/(2*a))*( w + a - g1 )^2
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls]  =  solve([dw,dx,dl],[w,x,l])

%%% ASSUME NO EPSILON FOR NOW!

% UTILITY SHARE
u_alone1 = collect(simplify(subs(u,[w,x],[ws,xs])),g1)
u_share1 = subs(u_alone1,p1,p2)

u_alone2 = subs(u_alone1,g1,g2)
u_share2 = subs(u_share1,g1,g2)


simplify(u_share1 + u_share2 - u_alone1 - u_alone2 - F)



solve(subs(simplify(u_share1 + u_share2 - u_alone1 - u_alone2 - F),[g1,g2],[g,g]),g)

steps=10;



matlabFunction(simplify(u_alone1,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','u.m')
matlabFunction(simplify(ws,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w.m')




% matlabFunction(simplify(weq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w_b_dkc.m')




% 
% %[ws,xs,ls,pt,st]  =  solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)
% 
% %s1=eval(subs(st,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,-100,-100,.1]))
% 
% simplify(ws)
% wt=eval(subs(ws,[p1,p2,y,alpha,A,Ap,L,k],[15,.2,30000,.02,100,100,100,0]))
% xt=eval(subs(xs,[p1,p2,y,alpha,A,Ap,L,k],[15,.2,30000,.02,100,100,100,0]))
% 
% %wt=eval(subs(ws,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,200,100,0]))
% %xt=eval(subs(xs,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
% % eval(subs(xs,[p1,p2,y,alpha,A,Ap,r],[1,1,30000,.02,100,100,.1]))
% % vs = eval(subs((1-alpha)*log(wt) + (alpha)*log(xt),alpha,.02))
% % % vs(2,1)
% % % eval(subs(vs,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
% %eval(subs(ws,[p1,p2,y,alpha,rh,A,Ap],[1,1,30000,.02,.1,100,100]))
% 
% 
% steps=10
% wse = simplify(ws(2,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 
% xse = simplify(xs(2,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 
% 
% % fileID = fopen(strcat(cd_dir,'wse.tex'),'w');
% % fprintf(fileID,'%500s\n',latex(wse));
% % fclose(fileID);
% 
% 
% vse =  ( (xse).^(1-alpha) ).*( (wse+k).^(alpha) )  
% 
% % eval(subs(wse,[p1,p2,y,alpha,A,Ap,L,k],[15,.2,30000,.02,100,100,100,0]))
% % eval(subs(wse,[p1,p2,y,alpha,A,Ap,L,k],[16,.2,30000,.02,100,100,100,0]))
% % eval(subs(wse,[p1,p2,y,alpha,A,Ap,L,k],[15,.3,30000,.02,100,100,100,0]))
% % eval(subs(wse,[p1,p2,y,alpha,A,Ap,L,k],[15,.3,30000,.02,100,100,1000,0]))
% 
% % fileID = fopen(strcat(cd_dir,'vse.tex'),'w');
% % fprintf(fileID,'%500s\n',latex(vse));
% % fclose(fileID);
% 
% %eval(subs(vse,[p1,p2,y,alpha,A,Ap,r,k,L],[1,1,30000,.02,100,100,.1,0,-300]))
% 
% % matlabFunction(wse,'File','w_reg_dkc.m')
% % matlabFunction(vse,'File','v_reg_dkc.m')
% 
% 
% %%% cut point?
% % [cut_point,pc,sc] = solve(-wse*(p1+p2*wse) - Ap, Ap,'ReturnConditions',true)
% % %s1=eval(subs(st,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,-100,-100,.1]))
% % matlabFunction(simplify(cut_point,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut_con.m')
% 
% %%% borrow 3x consumption! per period
% %cut_point3 = solve(-m*wse*p - Ap, Ap)
% 
% wsr0=simplify(subs(wse,r,0));
% 
% wst=simplify(wsr0*(p1+p2*wsr0));
% 
% cut_point3 = simplify(solve(-wst-L,L));
% 
% t1=eval(subs(cut_point3,[p1,p2,y,alpha,k],[15,.1,30000,.02,0]))
% 
% % [cut_point3,pc,sc] = solve(-m*wsr0*(p1+p2*wsr0) - Ap, Ap,'ReturnConditions',true)
% 
% % matlabFunction(simplify(cut_point3(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps),'File','cut_dkc.m')
% 
% % fileID = fopen(strcat(cd_dir,'cut_point3.tex'),'w');
% % fprintf(fileID,'%500s\n',latex(simplify(cut_point3(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps)));
% % fclose(fileID);
% 
% 
% %%%%% NEED TO SOLVE FOR EXACT FUNDING
% 
% syms wt
% 
% weq = solve( -wt*(p1+p2*wt) - L,wt)
% 
% 
% 
% eval(subs(weq,[L,p1,p2],[-1000,15,.2]))
% 
% weq_opt = simplify(weq(1,1));
% xeq_opt = simplify(y - L - weq_opt*(p1 + p2*weq_opt));
% 
% eval(subs(xeq_opt,[L,p1,p2,y],[-1000,15,.2,10000]))
% 
% veq_opt = simplify(  ( (xeq_opt).^(1-alpha) ).*( (weq_opt+k).^(alpha) ) );
% 
% % fileID = fopen(strcat(cd_dir,'weq_opt.tex'),'w');
% % fprintf(fileID,'%500s\n',latex(simplify(weq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps)));
% % fclose(fileID);
% 
% % fileID = fopen(strcat(cd_dir,'veq_opt.tex'),'w');
% % fprintf(fileID,'%500s\n',latex(simplify(veq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps)));
% % fclose(fileID);
% 
% % matlabFunction(simplify(weq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w_b_dkc.m')
% % matlabFunction(simplify(veq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_b_dkc.m')
% 
% 
% 
% 
% %}
% 
