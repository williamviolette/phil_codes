
clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab';

syms y p a g1 g2 w x F Q
assume(y>0)
assume(p>0)
assume(a>0)
assume(g1>0)
assume(g2>0)
assume(w>0)
assume(x>0)
assume(Q>0)

BC = ( y -   (p*w+x) ) 

u = (1/a)*(q*w - (1/2)*(w-g1)^2) + x

lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls]  =  solve([dw,dx,dl],[w,x,l])



