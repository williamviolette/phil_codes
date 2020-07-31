function  [v,g,h] = lbooster_2s(input,alpha0,alpha1,theta1,theta2,theta3,bobs,p_i,post,given)

siga = input(1);
if size(input,1)==2
    c    = input(2);
else
    c    = given(1);
end

np = ones(size(bobs,1),1);

theta  = (post.*theta1);
thetab = (post.*(theta1+theta3))+theta2;

[VAL,G,H]=ghu2s(alpha0,alpha1,bobs,c,np,p_i,siga,thetab,theta);

v= sum(VAL );
g = sum(G );
h = sum(H);
h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));

if size(input,1)==1
     v=v(1);
     g=g(1);
     h=h(1);
end

end