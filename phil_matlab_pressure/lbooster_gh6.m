function  [VAL,G,H] = lbooster_gh6(input,A,T,Tb,wobs,bobs,p_i,y,c,given)


sa = size(A,2);
st = size(T,2);
a0       = input(1:sa);
t0       = input(sa+1:sa+st);
alpha1   = input(sa+st+1);
sig      = input(sa+st+2);
% siga     = input(sa+st+3);
siga   = given(1);


yb=y-c;

nc = sqrt(pi*2);
np = ones(size(wobs,1),1);
es = zeros(size(wobs,1),1);



G = zeros(1,size(input,1));
H = zeros(size(input,1),size(input,1));


for i=1:size(A,2)
    for k=1:size(A,2)
        if k>i
%             k=2
%             i=1
            A_1 = A(:,i);
            A_2 = A(:,k);
            alpha0_1 = a0(i);
            alpha0_2 = a0(k);
            AC  = A*a0 - A_1.*alpha0_1 - A_2.*alpha0_2;
            
            T_1 = 0;
            T_2 = 0;
            theta0_1 = 0;
            theta0_2 = 0;
            TC  = T*t0 ;
            T_1b = 0;
            T_2b = 0;
            TCb = Tb*t0;
            
            [EV,OV,KV,UV,AV,AVB,TV,TVB] = ghu6_input(AC,A_1,A_2,TC,TCb,T_1,T_2,T_1b,T_2b,alpha1,alpha0_1,alpha0_2,nc,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb);
            [valw,gw,hw] =  ghu6(AC,AV,AVB,A_1,A_2,EV,KV,OV,TC,TCb,TV,TVB,T_1,T_2,T_1b,T_2b,UV,alpha1,alpha0_1,alpha0_2,bobs,nc,np,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb);
           
            if i==1
                VAL= sum(valw );
            end
            gwt = sum(gw );
            G([i k (sa+st+1):end]) = [gwt(1:2) gwt(end-(size(input,1)-(sa+st+1)):end)] ;
            h = sum(hw);
            h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));
            
            H(i,i) = h(1,1);
            H(k,k) = h(2,2);
            H(i,k) = h(1,2);
            H(i,(sa+st+1):end)=h(1,end-(size(input,1)-(sa+st+1)):end);
            H(k,(sa+st+1):end)=h(2,end-(size(input,1)-(sa+st+1)):end);
            H((sa+st+1):end,(sa+st+1):end)=h(end-(size(input,1)-(sa+st+1)):end,end-(size(input,1)-(sa+st+1)):end);
        end
    end
end

for i=1:st
    for k=1:st
        if k>i
%             k=2
%             i=1
            A_1 = 0;
            A_2 = 0;
            alpha0_1 = 0;
            alpha0_2 = 0;
            AC  = A*a0 ;
            
            T_1 = T(:,i);
            T_2 = T(:,k);
            theta0_1 = t0(i);
            theta0_2 = t0(k);
            TC  = T*t0 - T_1.*theta0_1 - T_2.*theta0_2;
            
            T_1b = Tb(:,i);
            T_2b = Tb(:,k);
            TCb  = Tb*t0 - T_1b.*theta0_1 - T_2b.*theta0_2;

            [EV,OV,KV,UV,AV,AVB,TV,TVB] = ghu6_input(AC,A_1,A_2,TC,TCb,T_1,T_2,T_1b,T_2b,alpha1,alpha0_1,alpha0_2,nc,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb);
            [~,gw,hw] =  ghu6(AC,AV,AVB,A_1,A_2,EV,KV,OV,TC,TCb,TV,TVB,T_1,T_2,T_1b,T_2b,UV,alpha1,alpha0_1,alpha0_2,bobs,nc,np,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb);

            gwt = sum(gw );
            G([(i+sa) (k+sa) (sa+st+1):end]) = [gwt(3:4) gwt(end-(size(input,1)-(sa+st+1)):end)] ;
            h = sum(hw);
            h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));
            
            H(i+sa,i+sa) = h(1+2,1+2);
            H(k+sa,k+sa) = h(2+2,2+2);
            H(i+sa,k+sa) = h(1+2,2+2);
            H(i+sa,(sa+st+1):end)=h(1+2,end-(size(input,1)-(sa+st+1)):end);
            H(k+sa,(sa+st+1):end)=h(2+2,end-(size(input,1)-(sa+st+1)):end);
%             H((sa+st+1):end,(sa+st+1):end)=h(end-(size(input,1)-(sa+st+1)):end,end-(size(input,1)-(sa+st+1)):end);
        end
    end
end




for i=1:sa
    for k=1:st
%         if k>=i
%             k=1;
%             i=1;
            A_1 =  A(:,i);
            A_2 = 0;
            alpha0_1 = a0(k);
            alpha0_2 = 0;
            AC  = A*a0 - A_1.*alpha0_1  ;
            
            T_1 =T(:,k);
            T_2 =0;
            theta0_1 = t0(k);
            theta0_2 = 0;
            TC  = T*t0 - T_1.*theta0_1 ;
            
            T_1b =Tb(:,k);
            T_2b =0;  
            TCb  = Tb*t0 - T_1b.*theta0_1 ;
            
            [EV,OV,KV,UV,AV,AVB,TV,TVB] = ghu6_input(AC,A_1,A_2,TC,TCb,T_1,T_2,T_1b,T_2b,alpha1,alpha0_1,alpha0_2,nc,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb);
            [~,~,hw] =  ghu6(AC,AV,AVB,A_1,A_2,EV,KV,OV,TC,TCb,TV,TVB,T_1,T_2,T_1b,T_2b,UV,alpha1,alpha0_1,alpha0_2,bobs,nc,np,p_i,sig,siga,theta0_1,theta0_2,wobs,y,yb);
 
            h = sum(hw);
            h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));
            
            H(i,k+sa)=h(1,1+2);
    end
end


H = triu(H) + triu(H)' - diag(diag(H)) ;

       
end