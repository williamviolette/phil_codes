
clear

y = 1000;
F = 500;

sig = 3;
g = 50;
a = .4;
n = 7000;


rng(1);

p1=normrnd(50,10,n,1);
p2=p1 + 2.*(rand(n,1)>.5);
p3=p1 + 3.*(rand(n,1)>.5);


e  = evrnd(0,1,n,10);
ep = normrnd(0,sig,n,20);

u_ind = u(a,g,p1,y)./y   +   u(a,g,p2,y )./y      + u(a,g,p3,y )./y + e(:,1); % IND
    w_p1_ind   = w(a,g,p1)                + ep(:,1);
    w_p2_ind   = w(a,g,p2)                + ep(:,2);
    w_p3_ind   = w(a,g,p3)                + ep(:,3);
    
u_12 = u(a,g,p1,y - F )./y + u(a,g,p1,y - F )./y + u(a,g,p3,y )./y + e(:,2); % 1+2 SHR 
    w_s_12  = w(a,g,p1) + w(a,g,p1)      + ep(:,4);
    w_i_12  = w(a,g,p3)                  + ep(:,5);
u_21 = u(a,g,p2,y - F )./y + u(a,g,p2,y - F )./y + u(a,g,p3,y )./y + e(:,3); % 2+1 SHR 
    w_s_21  = w(a,g,p2) + w(a,g,p2)      + ep(:,6);
    w_i_21  = w(a,g,p3)                  + ep(:,7);
    
u_13 = u(a,g,p1,y - F )./y + u(a,g,p1,y - F )./y + u(a,g,p2,y )./y + e(:,4); % 1+3 SHR 
    w_s_13  = w(a,g,p1) + w(a,g,p1)      + ep(:,8);
    w_i_13  = w(a,g,p2)                  + ep(:,9);
u_31 = u(a,g,p3,y - F )./y + u(a,g,p3,y - F )./y + u(a,g,p2,y )./y + e(:,5); % 3+1 SHR 
    w_s_31  = w(a,g,p3) + w(a,g,p3)      + ep(:,10);
    w_i_31  = w(a,g,p2)                  + ep(:,11);

u_23 = u(a,g,p2,y - F )./y + u(a,g,p2,y - F )./y + u(a,g,p1,y )./y + e(:,6); % 2+3 SHR 
    w_s_23  = w(a,g,p2) + w(a,g,p2)      + ep(:,12);
    w_i_23  = w(a,g,p1)                  + ep(:,13);
u_32 = u(a,g,p3,y - F )./y + u(a,g,p3,y - F )./y + u(a,g,p1,y )./y + e(:,7); % 3+2 SHR 
    w_s_32  = w(a,g,p3) + w(a,g,p3)      + ep(:,14);
    w_i_32  = w(a,g,p1)                  + ep(:,15);

u_1_3 = u(a,g,p1,y - F )./y + u(a,g,p1,y - F )./y + u(a,g,p1,y - F )./y + e(:,8);  % 1w3 SHR 
    w_s_1_3  = w(a,g,p1) + w(a,g,p1) + w(a,g,p1)      + ep(:,16);
u_2_3 = u(a,g,p2,y - F )./y + u(a,g,p2,y - F )./y + u(a,g,p2,y - F )./y + e(:,9);  % 2w3 SHR 
    w_s_2_3  = w(a,g,p2) + w(a,g,p2) + w(a,g,p2)      + ep(:,17);
u_3_3 = u(a,g,p3,y - F )./y + u(a,g,p3,y - F )./y + u(a,g,p3,y - F )./y + e(:,10); % 3w3 SHR 
    w_s_3_3  = w(a,g,p3) + w(a,g,p3) + w(a,g,p3)      + ep(:,18);

U = [u_ind u_12 u_21 u_13 u_31 u_23 u_32 u_1_3 u_2_3 u_3_3];

[~,mU]=max(U,[],2);
mUr = 3.*(mU==1) + 2.*(mU>=2 & mU<=7) + 1.*(mU>7);
id = (1:n)';
idr = repelem(id,mUr);
idn=(1:size(idr,1))';
[ud,ix,iy]=unique( idr );  
output = [ud, accumarray(iy,idn,[],@min)];
og = repelem(output(:,2),mUr);
indc = idn-og;


MU=repelem(mU,mUr);
cobs = MU;

wobs = (MU==1).*(indc==0).*repelem(w_p1_ind,mUr) + ...
       (MU==1).*(indc==1).*repelem(w_p2_ind,mUr) + ...
       (MU==1).*(indc==2).*repelem(w_p3_ind,mUr) + ...
        (MU==2).*(indc==0).*repelem(w_s_12,mUr) + ...
        (MU==2).*(indc==1).*repelem(w_i_12,mUr) + ...
       (MU==3).*(indc==0).*repelem(w_s_21,mUr) + ...
       (MU==3).*(indc==1).*repelem(w_i_21,mUr) + ...
        (MU==4).*(indc==0).*repelem(w_s_13,mUr) + ...
        (MU==4).*(indc==1).*repelem(w_i_13,mUr) + ...
       (MU==5).*(indc==0).*repelem(w_s_31,mUr) + ...
       (MU==5).*(indc==1).*repelem(w_i_31,mUr) + ...
        (MU==6).*(indc==0).*repelem(w_s_23,mUr) + ...
        (MU==6).*(indc==1).*repelem(w_i_23,mUr) + ...
       (MU==7).*(indc==0).*repelem(w_s_32,mUr) + ...
       (MU==7).*(indc==1).*repelem(w_i_32,mUr) + ...
           (MU==8).*(indc==0).*repelem(w_s_1_3,mUr) + ...
           (MU==9).*(indc==0).*repelem(w_s_2_3,mUr) + ...
           (MU==10).*(indc==0).*repelem(w_s_3_3,mUr);

p1obs = repelem(p1,mUr);
p2obs = repelem(p2,mUr);
p3obs = repelem(p3,mUr);


obj=@(input1)ltest3_post_3g(input1,cobs,wobs,p1obs,p2obs,p3obs,y);

input= .9.*[a g sig 250]

out=fminunc(obj,input)


% obj=@(input1)ltest3(input1,cobs,wobs,p1obs,p2obs,y,sig,F);
% 
% input= .9.*[a g ]
% 
% out=fminunc(obj,input)
