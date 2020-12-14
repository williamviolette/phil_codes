




beta_up = .03/12;

beta = 1/( 1 + beta_up );

N = 500;
A = repmat((0:N)',1,N+1)';
Aprime = A';
nA = size(A,1);

% (161+131) - slope*(50) = 0
surplus   =  161 + 131;
pipe_age  =  28*12;
slope     =  surplus/pipe_age;
Q0        =  surplus;
Q1        =  slope;

surplus_rec = 131;
slope_rec = surplus_rec/pipe_age;

loan_term = 15;
total_loan = 17021;
r = .05/12;

pay=0;
for i=0:loan_term*12-1
    pay = pay + surplus_rec - slope_rec*i;
end
pay = pay/(loan_term*12);

n = 12*loan_term;
d = (((1+r)^n)-1)/(r*(1+r)^n);
F  = total_loan/d;

% business accounts close the gap!

pay
F
% need to raise 181 = p*Q(p)
% F = (p+p1)*(gamma - alpha*(p+p1) + Q)

% Fr = F-57-74;
% a = .6;
% p = 20;
% g = 20 + 1.89 + .6*p;

% F1 = Fr + (g-a*p)*p
% p1 = (sqrt(g.^2-4*a*F1)-2*a*p+g)/(2*a);
% g - 2*a*p
% g/(2*a)
% (g - a.*(g/(2*a))).*g/(2*a)
% (g-a*p)*p


util1 = (Q0 - A.*Q1 - F).*(Aprime==0 & A>=loan_term*12) + ...
        (Q0 - A.*Q1 - F).*(Aprime==A+1 & Aprime<loan_term*12) + ... 
        (Q0 - A.*Q1).*(Aprime==A+1 & Aprime>=loan_term*12) + ...
        -1000000.*(1-((Aprime==0 & A>loan_term*12)+(Aprime==A+1)));

v       = zeros(nA,1);
decis   = zeros(nA,1);
metric=1000;


while metric > 1e-7

  [tv1,tdecis1]=max(util1 + beta.*repmat(v,1,nA));

  tdecis=tdecis1';
  tv=tv1';
  
  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end

% [(1:nA)' decis]
max(decis)

% 
% decis=(decis-1)*inA + minA; %%% try to understand this better...
% 
% Amark = size(Agrid,1);
% Athis = Agrid(Amark,1);        % initial level of assets        
% states   = zeros(n-1,2);
% controls = zeros(n-1,2);
% for i = 1:n-1
%     Aprime = decis(Amark,chain(i));
%     Amark  = tdecis(Amark,chain(i));
%     
%     [~,~,~,~,cons1,cons2,cons3,cons4] = ...
%     u_w1loan3(Athis,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);
%     
%     cons_full = [cons1 cons2 cons3 cons4];
%     cons = cons_full(chain(i));
%     
%     states(i,:) = [ Athis chain(i) ];
%     controls(i,:) = [ cons Aprime ];
%     Athis = Aprime;
% end
% 
% 
% w_debt_max = p.*controls(:,1);
% w_debt = ( controls(:,2).*(controls(:,2)>w_debt_max) + ...
%             w_debt_max.*(controls(:,2)<=w_debt_max) ).* ...
%             (controls(:,2)<0).*(states(:,2)<=2);  %%% only measured when no default (and when negative) (otherwise zero)
% 
%         
% %SAV = controls(:,2);
% C = controls(:,1);
% C1 = [1;1;1;1;1;1;1;1;1];
% %S1 = [1;1;1;1;1;1;1;1;1];
% for i=6:size(states,1)-6
%    if states(i,2)>=3 && controls(i,2)<0
%       C1=[C1 C(i-4:i+4,1)]; 
%       %S1=[S1 SAV(i-4:i+4,1)]; 
%    end 
% end
% 
% %avg_debt = mean( controls(:,2) < 0 );
% 
% CM=mean(C1(:,2:end),2);
% 
% % C_def = C(states(:,2)>=3);
% % mean(C_def); std(C_def);
% 
% 
% h = [mean(mean(C)); std(C);  mean(w_debt);  std(w_debt); corr(w_debt,C);  CM ];

