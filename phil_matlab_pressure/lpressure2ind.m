function  [h] = lpressure2ind(input,Tobs,p, given)

alpha1 = input(1);
shr    = input(2);

pc = exp(-alpha1.*p)./(exp(-alpha1.*p)+1);

prob1 = shr.*pc;
prob2 = shr.*pc;
prob3 = shr.*pc;

prob4 = (1-3.*shr) + (1-pc).*3.*shr;

h = -1.*sum( (log(prob1).*(Tobs==1)) +  ...
    (log(prob2).*(Tobs==2)) + ...
    (log(prob3).*(Tobs==3)) + ...
    (log(prob4).*(Tobs==4)) );

end