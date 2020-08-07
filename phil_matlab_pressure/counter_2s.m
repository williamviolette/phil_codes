function  [ut,bobs] = counter_2s(input,alpha0,alpha1,theta1,theta2,theta3,p_i,post,given)

siga = input(1);
if size(input,2)==2
    c    = input(2);
else
    c    = given(1);
end

    epa  = normrnd(0,siga,size(alpha0,1),1);
    
    theta  = (post.*theta1);
    thetab = (post.*(theta1+theta3))+theta2;
           u_nb = up2s(alpha0,alpha1,p_i,theta,10000);
           u_b  = up2s(alpha0,alpha1,p_i,thetab,10000-c);

    bobs=((u_b-u_nb)>epa);

    
    ut    = (bobs==1).*(u_b-epa) + (bobs==0).*(u_nb);