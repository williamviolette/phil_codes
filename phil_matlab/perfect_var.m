function [t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4]=...
    perfect_var(i,reps,Q_obs_range,p_var)

t = repelem(reps,i,1);

Q_obs = ((1:i)./(i))'.*(Q_obs_range(2)) + Q_obs_range(1);
Q_obs = repelem(Q_obs,reps,1);

p_1 = 5   + rand(sum(t),1).*p_var;
p_2 = p_1 + 5 + rand(sum(t),1).*p_var;
p_3 = p_2 + 5 + rand(sum(t),1).*p_var;
p_4 = p_3 + 5 + rand(sum(t),1).*p_var;

k_1=ones(sum(t),1).*10;
k_2=ones(sum(t),1).*20;
k_3=ones(sum(t),1).*40;