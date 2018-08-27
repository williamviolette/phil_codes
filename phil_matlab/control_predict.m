function [SIG_EP,SIG_NU,ALPHA_1] = control_predict(sig_ep,sigma_1,alpha_1,CA,SE,D)


%%%%%% PREDICTED VALUES %%%%%%
SIG_EP = sig_ep(1).*CA(:,1);
for i = 2:size(CA,2)
    SIG_EP = SIG_EP + sig_ep(i).*CA(:,i);
end
    
SIG_NU = sigma_1(1).*SE(:,1);
for i = 2:size(SE,2)
    SIG_NU = SIG_NU + sigma_1(i).*SE(:,i);
end 
    
ALPHA_1 = alpha_1(1).*D(:,1);
for i = 2:size(D,2)
    ALPHA_1 = ALPHA_1 + alpha_1(i).*D(:,i);
end