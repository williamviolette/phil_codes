




beta_up = .1;

beta = 1/( 1 + beta_up );

N = 200;
A = repmat((0:N)',1,N+1)';
Aprime = A';
nA = size(A,1);

% (161+131) - slope*(50) = 0
slope = (161+131)/50;

Q0 = 161+131;
Q1 = slope;

F  = 181;

util1 = (Q0 - A.*Q1 - F).*(Aprime==0) + (Q0 - A.*Q1).*(A<Aprime & Aprime~=0) + -1000000.*(A>=Aprime & Aprime~=0);

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

[(1:nA)' decis]

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

