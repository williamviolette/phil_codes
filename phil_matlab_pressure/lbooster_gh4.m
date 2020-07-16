function  [VAL,G,H] = lbooster_gh4(input,A,T,wobs,p_i,p_r,given)


sa = size(A,2);
st = size(T,2);
a0       = input(1:sa);
t0       = input(sa+1:sa+st);
alpha1   = input(sa+st+1);
sig      = input(sa+st+2);

% alpha0 = A*a0;

% es=zeros(1,size(A,2));
% yb=y-c;
% theta1b=theta1;

nc = sqrt(pi*2);
np = ones(size(wobs,1),1);
es = zeros(size(wobs,1),1);


% VAL
G = zeros(1,size(input,1));
H = zeros(size(input,1),size(input,1));

% G=(1:10)
% G([2 4 7:end])=[0 1 1 1 1 1]

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
            
            [valw,gw,hw] = gh4(AC,A_1,A_2,TC,T_1,T_2,alpha1,alpha0_1,alpha0_2,nc,np,p_i,p_r,sig,theta0_1,theta0_2,wobs);
           
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
            
            [~,gw,hw] = gh4(AC,A_1,A_2,TC,T_1,T_2,alpha1,alpha0_1,alpha0_2,nc,np,p_i,p_r,sig,theta0_1,theta0_2,wobs);
           
%             if i==1
%                 VAL= sum(valw );
%             end
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
            
            [~,~,hw] = gh4(AC,A_1,A_2,TC,T_1,T_2,alpha1,alpha0_1,alpha0_2,nc,np,p_i,p_r,sig,theta0_1,theta0_2,wobs);
           
            h = sum(hw);
            h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));
            
            H(i,k+sa)=h(1,1+2);
%             H(k+sa,(sa+st+1):end)=h(2+2,end-(size(input,1)-(sa+st+1)):end);
%             H((sa+st+1):end,(sa+st+1):end)=h(end-(size(input,1)-(sa+st+1)):end,end-(size(input,1)-(sa+st+1)):end);
%         end
    end
end


H = triu(H) + triu(H)' - diag(diag(H)) ;

% [valu,gu,hu] = ghu2(alpha0,alpha1,bobs,es,np,p_i,p_r,siga,theta1,theta1b,wobs,y,yb);







% val = sum(valw + valu);
% g   = sum(gw + gu);
% h = sum(hw + hu);
% 
% h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));
% 

%        
% v1 =  upnl(  a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y) ;
% v2 =  upnl(  a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c) ;
% 
% Bprob1=normcdf(v1-v2,0,siga);
% Bprob2=1-normcdf(v1-v2,0,siga);
% 
% w1 = normpdf( (wobs - wpnl( a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) ),0,sig );
% w2 = normpdf( (wobs - wpnl( a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3)  ),0,sig );
% 
% m = -1.*sum( (Bobs==0).*(log(Bprob1) + log(w1)) ...
%            + (Bobs==1).*(log(Bprob2) + log(w2)) );


       
       
%        
%        
% if nargout>1
%     rng(3);
%     n = size(A,1);
%     e  = normrnd(0,siga,n,2);
% %     ep = normrnd(0,sig,n,2);
% 
%     v1s = upnl(  a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y)  + e(:,1);
%     v2s = upnl(  a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c) + e(:,2);
% %     w1s = wp1( a0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) + ep(:,1);
% %     w2s = wp1( a0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3)   + ep(:,2);
%     
% %     um = mean( upn1.*(v1s>=v2s) + upn2.*(v2s>v1s) );
%     um = mean( v1s.*(v1s>v2s) + v2s.*(v2s>v1s) );
%     bm = mean((v2s>v1s));
% end
       
end