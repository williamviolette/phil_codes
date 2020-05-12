function  h = ltest3_post(input,cobs,wobs,p1,p2,y)

a   = input(1);
g   = input(2);
sig = input(3);
F   = input(4);


v1 = exp(u(a,g,p1,y    )./y + u(a,g,p2,y    )./y);
v2 = exp(u(a,g,p1,y - F )./y + u(a,g,p1,y - F)./y);
v3 = exp(u(a,g,p2,y - F )./y + u(a,g,p2,y - F)./y);

cprob1_b=v1./(v1 + v2 + v3);
cprob2_b=v2./(v1 + v2 + v3);
cprob3_b=v3./(v1 + v2 + v3);

% 2.*
cprob1 = cprob1_b./(2.*cprob1_b + cprob2_b + cprob3_b);
cprob2 = cprob2_b./(2.*cprob1_b + cprob2_b + cprob3_b);
cprob3 = cprob3_b./(2.*cprob1_b + cprob2_b + cprob3_b);

wprob = normpdf( (wobs - w(a,g,p1)),0,sig ).*cprob1 ...
      + normpdf( (wobs - w(a,g,p2)),0,sig ).*cprob1 ...
      + normpdf( (wobs - w(a,g,p1) - w(a,g,p1)),0,sig ).*cprob2 ... 
      + normpdf( (wobs - w(a,g,p2) - w(a,g,p2)),0,sig ).*cprob3 ;

h = -1.*sum( (cobs==1).*log( 2.*cprob1 ) + (cobs==2).*log(cprob2) ...
     + (cobs==3).*log(cprob3) + log(wprob) );

end