function [h,v,v_PS,v_CS,vm_PS,vm_CS]=sim_reps_va(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t,NRW)
 
sim_length= nA;

Q1_CS = Q0_CS/pipe_age;
Q1_PS = Q0_PS/pipe_age;

d = (((1+r)^(12*loan_term))-1)/(r*(1+r)^(12*loan_term));
F  = total_loan/d;

util1_PS =  (- A.*Q1_PS - F).*(Aprime==0 & A>=loan_term*12) + ...
            (- A.*Q1_PS - F).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
            (- A.*Q1_PS).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
            -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

util1_NRW = (- (A.*NRW./pipe_age) - F).*(Aprime==0 & A>=loan_term*12) + ...
            (- (A.*NRW./pipe_age) - F).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
            (- (A.*NRW./pipe_age)).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
            -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

util1_CS =  (- A.*Q1_CS ).*(Aprime==0 & A>=loan_term*12) + ...
            (- A.*Q1_CS ).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
            (- A.*Q1_CS ).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
            -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

    
v    = zeros(nA,1);
v_PS = zeros(nA,1);
v_CS = zeros(nA,1);
decis   = zeros(nA,1);


% t=3000;
% wbar=.1;
% welfare=2;




%%%% full surplus or producer surplus %%%%
    
if welfare==1 || welfare==3 || welfare==5
metric=1000;

    while metric > 1e-7
      [tv1,tdecis1]=max(util1_PS.*(welfare==1) + util1_PS.*(welfare==3) + util1_NRW.*(welfare==5) + util1_CS.*(welfare==1) + beta.*repmat(v,1,nA));

      u_ps_temp  = util1_PS + beta.*repmat(v_PS,1,nA);
      u_ps_temp1 = u_ps_temp(sub2ind(size(u_ps_temp), tdecis1, 1:size(u_ps_temp,2)));

      u_cs_temp  = util1_CS + beta.*repmat(v_CS,1,nA);
      u_cs_temp1 = u_cs_temp(sub2ind(size(u_cs_temp), tdecis1, 1:size(u_cs_temp,2)));
    %   testsum=u_ps_temp1 + u_cs_temp1;

      tdecis=tdecis1';
      tv=tv1';
    %   v_test=v_PS + v_CS

      metric=max(max(abs((tv-v)./tv)));
      v=tv;
      decis=tdecis;
      v_PS = u_ps_temp1';
      v_CS = u_cs_temp1';
    end

    % [(1:nA)' decis]
    h=max(decis);
%     v=v(1);
%     v_PS=v_PS(1);
%     v_CS=v_CS(1);


vv_PS = zeros(1,sim_length);
vv_CS = zeros(1,sim_length);
   
k=1;
for j=1:sim_length
    vv_PS(1,j)=util1_PS(k+1,k);
    vv_CS(1,j)=util1_CS(k+1,k);
    k=decis(k);
end

vm_PS = mean(vv_PS);
vm_CS = mean(vv_CS);


end




%%%% quality standard %%%%

if welfare==2 || welfare==4
    v = zeros(1,sim_length);
    v_PS = zeros(1,sim_length);
    v_CS = zeros(1,sim_length);

    for k=1:sim_length
        res = zeros(t,1);
        tt=k;
        up=0;
        uc=0;
        for j=1:t-1
            ww = wm - (tt*we/pipe_age);
    %  tt  %  ww
            if welfare==2
                if ww > wbar && tt>loan_term*12 - 1
                    tt=0;
                end
            else
                if tt>pipe_age - 1
                    tt=0;
                end                
            end
            if tt>pipe_age*2 
                tt=0;
            end
            
            if tt<=loan_term*12
                ft=F;
            else
                ft=0;
            end

            up = up + (beta.^j).*(- tt.*Q1_PS - ft);
            uc = uc + (beta.^j).*(- tt.*Q1_CS );

            tt = tt+1;
            res(j+1,:) = tt;
        end
        h = max(res);
        v(1,k) = up+uc;
        v_PS(1,k)=up;
        v_CS(1,k)=uc;
    end


        
    vv_PS=zeros(1,sim_length);
    vv_CS=zeros(1,sim_length);
    
    tt=0;
    for j=1:sim_length
        ww = wm - (tt*we/pipe_age);
    %  tt  %  ww
        if welfare==2
            if ww > wbar && tt>loan_term*12 - 1
                tt=0;
            end
        else
            if tt>pipe_age - 1
                tt=0;
            end                
        end

        if tt<=loan_term*12
            ft=F;
        else
            ft=0;
        end

        vv_PS(1,j) = (-tt.*Q1_PS - ft);
        vv_CS(1,j) = (-tt.*Q1_CS );

        tt = tt+1;
    end
        
    vm_PS = mean(vv_PS);
    vm_CS = mean(vv_CS);
end
    
    
    
end
