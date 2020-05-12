function  h = ltest(input,c,p1,p2)

a = input(1);

v1=exp(a.*p1);
v2=exp(a.*p2);

p1=v1./(v1 + v2);
p2=v2./(v1 + v2);

h = -1.*sum( (c==1).*log(p1) + (c==2).*log(p2) );

end