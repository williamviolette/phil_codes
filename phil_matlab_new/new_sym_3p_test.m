
clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab_new/';

syms y pi pr a1 a2 a3 g g1 g2 g3 w x F l ws wbar1 wbar2 wbar3 es esq
assume(y>0)
assume(pi>0)
assume(pr>0)
assume(a1>0)
assume(a2>0)
assume(a3>0)
assume(g1>0)
assume(g2>0)
assume(g3>0)
assume(w>0)
assume(x>0)
assume(l>0)
assume(wbar1>0)
assume(wbar2>0)
assume(wbar3>0)
assume(es>0)
assume(esq)

steps=10;

%%% ALONE %%%

p = pr*(w) + pi
BC = ( y -   (p*w+x) ) 

u = x + w - (1/(2*a1))*( w + a1 - (g1+es) )^2
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[wa,xa,la]  =  solve([dw,dx,dl],[w,x,l]);

ua = simplify(subs(u,[w,x],[wa,xa]));


wa_print = simplify(subs(wa,es,0));
ua_print = simplify(subs(subs(collect(ua,es),es^2,esq),es,0));

matlabFunction(simplify(wa_print,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','wa.m')
matlabFunction(simplify(ua_print,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','ua.m')


%%% SHARE 2 %%%



p = pr*(w + wbar2) + pi
BC = ( y -   (p*w+x) ) 

u = x + w - (1/(2*a1))*( w + a1 - (g1+es) )^2
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[w1s2,x1s2,l1s2]  =  solve([dw,dx,dl],[w,x,l]);

w2s2 = subs(w1s2,[a1,g1,wbar2],[a2,g2,wbar1]);

[w1s2d,w2s2d] = solve([w1s2 - wbar1,w2s2 - wbar2],[wbar1,wbar2]); % solve for the wbar that solves  

x1s2d = subs(x1s2,[wbar1,wbar2],[w1s2d,w2s2d]);

u1s2 = simplify(subs(u,[w,x],[w1s2d,x1s2d]));

w1s2_print = simplify(subs(w1s2d,es,0));
u1s2_print = simplify(subs(subs(collect(u1s2,es),es^2,esq),es,0));

matlabFunction(simplify(w1s2_print,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','ws2.m')
matlabFunction(simplify(u1s2_print,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','us2.m')





p = pr*(w+wbar2+wbar3) + pi
BC = ( y -   (p*w+x) ) 

u = x + w - (1/(2*a1))*( w + a1 - (g1+es) )^2
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[ws1,xs1,ls1]  =  solve([dw,dx,dl],[w,x,l]);

ws2 = subs(ws1,[a1,g1,wbar2],[a2,g2,wbar1]); % create 2 demand by swapping
ws3 = subs(ws1,[a1,g1,wbar3],[a3,g3,wbar1]); % create 3 demand by swapping
xs2 = subs(xs1,[a1,g1,wbar2],[a2,g2,wbar1]);
xs3 = subs(xs1,[a1,g1,wbar3],[a3,g3,wbar1]);

[ws1d,ws2d,ws3d] = solve([ws1 - wbar1,ws2 - wbar2,ws3 - wbar3],[wbar1,wbar2,wbar3]); % solve for the wbar that solves  

xs1d = subs(xs1,[wbar1,wbar2,wbar3],[ws1d,ws2d,ws3d]) ;
xs2d = subs(xs2,[wbar1,wbar2,wbar3],[ws1d,ws2d,ws3d]) ;
xs3d = subs(xs3,[wbar1,wbar2,wbar3],[ws1d,ws2d,ws3d]) ;

us1 = simplify(subs(u,[w,x],[ws1d,xs1d])) ;
us2 = simplify(subs(subs(u,[a1,g1],[a2,g2]),[w,x],[ws2d,xs2d])) ;
us3 = simplify(subs(subs(u,[a1,g1],[a3,g3]),[w,x],[ws3d,xs3d])) ;

w1s3_print = simplify(subs(ws1d,es,0));
u1s3_print = simplify(subs(subs(collect(us1,es),es^2,esq),es,0));

matlabFunction(simplify(w1s3_print,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','ws3.m')
matlabFunction(simplify(u1s3_print,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','us3.m')





%{
% has(collect(subs(us1,[g2,g3],[g1,g1]),g1),g1^4)






steps=10;
uts = simplify(us1+us2,'IgnoreAnalyticConstraints',true,'Steps',steps)

wts = simplify(ws1d+ws2d,'IgnoreAnalyticConstraints',true,'Steps',steps)

uta = simplify(ua1 + ua2)



UTS = [];
UAS = [];

N = 30;
for j=1:N
    ustemp = eval(subs(uts,[p1r,p1i,y,g1,a1,g2,a2],[.3, j ,1000,50,.7,50,.1]));
    uatemp = eval(subs(uta,[p1r,p1i,y,g1,a1,g2,a2],[.3, j ,1000,50,.7,50,.1])); 
    UTS = [UTS; ustemp];
    UAS = [UAS; uatemp];
end


plot((1:N)',UTS,(1:N)',UAS)



UTS = [];
UAS = [];
NL = 20;
NH = 50;
for j=NL:NH
    ustemp = eval(subs(uts,[p1r,p1i,y,g1,a1,g2,a2],[.3, 17 ,1000,j,.7,80-j,.1]));
    uatemp = eval(subs(uta,[p1r,p1i,y,g1,a1,g2,a2],[.3, 17 ,1000,j,.7,80-j,.1])); 
    UTS = [UTS; ustemp];
    UAS = [UAS; uatemp];
end


plot((NL:NH)',UTS,(NL:NH)',UAS)



%}

% 
% %%% ASSUME NO EPSILON FOR NOW!
% 
% % UTILITY SHARE
% u_alone1 = collect(simplify(subs(u,[w,x],[ws,xs])),g1)
% u_share1 = subs(u_alone1,p1,p2)
% 
% u_alone2 = subs(u_alone1,g1,g2)
% u_share2 = subs(u_share1,g1,g2)
% 
% 
% 
% solve(subs(simplify(u_share1 + u_share2 - u_alone1 - u_alone2 - F),[g1,g2],[g,g]),g)
% 
% steps=10;




% 
% matlabFunction(simplify(u_alone1,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','u.m')
% matlabFunction(simplify(ws,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w.m')
% 



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
