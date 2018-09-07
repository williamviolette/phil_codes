function nu = error_sample(sn1,sn2,sn3,corr_2,corr_3)

rng(1);
nu = zeros(length(sn1),3);

for i = 1:length(sn1)
    nu(i,:) = mvnrnd( [0;0;0] ,[sn1(i)     (corr_2.*sqrt(sn1(i)).*sqrt(sn2(i)))  (corr_2.*sqrt(sn1(i)).*sqrt(sn3(i))) ; ...
                            (corr_2.*sqrt(sn1(i)).*sqrt(sn2(i)))  sn2(i)     (corr_3.*sqrt(sn2(i)).*sqrt(sn3(i))) ; ...
                            (corr_2.*sqrt(sn1(i)).*sqrt(sn3(i)))  (corr_3.*sqrt(sn2(i)).*sqrt(sn3(i)))   sn3(i)    ])   ;
end