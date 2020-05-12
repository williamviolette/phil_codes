function  h = logit_test(a)


global Y X0 X1 X2 X3 z div2 div3

if length(a)==2
    K=a(1,1);
    F=a(1,2);
end
if length(a)==1
    K=ones(z,1);
    F=a(1,1);
end

v0=exp(K.*X0);
v1=exp(K.*X1+F.*ones(z,1));
v2=exp(K.*X2+(F./div2).*ones(z,1));
v3=exp(K.*X3+(F./div3).*ones(z,1));

p0=v0./(v1 + v2 + v3 + v0);
p1=v1./(v1 + v2 + v3 + v0);
p2=v2./(v1 + v2 + v3 + v0);
p3=v3./(v1 + v2 + v3 + v0);

h = -1.*sum((Y==0).*log(p0) + (Y==1).*log(p1) ...
          + (Y==2).*log(p2) + (Y==3).*log(p3));

end