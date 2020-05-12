function  h = ltest2(input,cobs,wobs,p1,p2,y)

a   = input(1);
g   = input(2);
sig = input(3);

v1 = exp(u(a,g,p1,y)./y);
v2 = exp(u(a,g,p2,y)./y);

cprob1=v1./(v1 + v2);
cprob2=v2./(v1 + v2);

wprob = normpdf( (wobs - w(a,g,p1)),0,sig ).*cprob1 ...
      + normpdf( (wobs - w(a,g,p2)),0,sig ).*cprob2 ;

h = -1.*sum( (cobs==1).*log(cprob1) + (cobs==2).*log(cprob2) + log(wprob) );

end