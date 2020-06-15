

%%% NON LINEAR! %%%


clear

rng(1);

N = 20000;

t_dist = round(rand(N,1).*4 + .5);

p  = rand(N,1).*10;
e  = evrnd(0,1,N,2);

alpha1 = .5;
uc     =  -alpha1.*p + e(:,1);
us     = e(:,2);

Tobs = (t_dist.*(uc>us) + 4.*(uc<=us)).*(t_dist<=3) + t_dist.*(t_dist==4);

given = [alpha1; .25];
    
obj=@(input1)lpressure1ind(input1,Tobs,p, given)

% given

input = .9.*[alpha1; .25];

% input = .9.*[alpha1];

obj(input)

out   = fminunc(obj,input)

obj(out)