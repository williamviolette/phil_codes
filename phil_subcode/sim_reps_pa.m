function [h,v,v_PS,v_CS]=sim_reps_pa(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t,NRW)
 
sim_length= nA;

Q1_CS = Q0_CS/pipe_age;
Q1_PS = Q0_PS/pipe_age;

d = (((1+r)^(12*loan_term))-1)/(r*(1+r)^(12*loan_term));
F  = total_loan/d;

util1_PS =  (Q0_PS - A.*Q1_PS - F).*(Aprime==0 & A>=loan_term*12) + ...
            (Q0_PS - A.*Q1_PS - F).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
            (Q0_PS - A.*Q1_PS).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
            -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

util1_NRW = (NRW - (A.*NRW./pipe_age) - F).*(Aprime==0 & A>=loan_term*12) + ...
            (NRW - (A.*NRW./pipe_age) - F).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
            (NRW - (A.*NRW./pipe_age)).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
            -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

util1_CS =  (Q0_CS - A.*Q1_CS ).*(Aprime==0 & A>=loan_term*12) + ...
            (Q0_CS - A.*Q1_CS ).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
            (Q0_CS - A.*Q1_CS ).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
            -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

    
v    = zeros(nA,1);
v_PS = zeros(nA,1);
v_CS = zeros(nA,1);
decis   = zeros(nA,1);


% t=3000;
% wbar=.1;
% welfare=2;


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

            if tt<=loan_term*12
                ft=F;
            else
                ft=0;
            end

            up = up + (beta.^j).*(Q0_PS - tt.*Q1_PS - ft);
            uc = uc + (beta.^j).*(Q0_CS - tt.*Q1_CS );

            tt = tt+1;
            res(j+1,:) = tt;
        end
        h = max(res);
%         v=up+uc;
%         v_PS=up;
%         v_CS=uc;
        v(1,k) = up+uc;
        v_PS(1,k)=up;
        v_CS(1,k)=uc;
    end
    
end




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
end




%%%% every pipe_age %%%%

% if welfare==4
%     res = zeros(t,1);
%     tt=0;
%     up=0;
%     uc=0;
%     for j=0:t-1
% 
%         if tt > pipe_age - 1
%             tt=0;
%         end
%         
%         if tt<=loan_term*12
%             ft=F;
%         else
%             ft=0;
%         end
%         
%         up = up + (beta.^j).*(Q0_PS - tt.*Q1_PS - ft);
%         uc = uc + (beta.^j).*(Q0_CS - tt.*Q1_CS );
% 
%         tt = tt+1;
%         res(j+1,:) = tt;
%     end
%     h = max(res);
%     v=up+uc;
%     v_PS=up;
%     v_CS=uc;
% end




% Amark = sim_start;     
% states   = zeros(sim_length,1);
% surplus = zeros(sim_length,2);
% 
% for i = 1:sim_length
%     Aprime = decis(Amark);
%     
%     [~,~,~,~,cons1,cons2,cons3,cons4] = ...
%     u_w1loan3(Athis,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);
%     
%     cons_full = [cons1 cons2 cons3 cons4];
%     cons = cons_full(chain(i));
%     
%     states(i,:) = [ Amark ];
%     surplus(i,:) = [ util1_CS(i) util1_PS(i) ];
%     Amark = Aprime;
% end