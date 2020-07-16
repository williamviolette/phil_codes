function [gx,dg,dg2] = ng_normalpdf(x,wobs,sig,pdf)

pii=3.14;

if pdf==1
    gx   = normpdf(wobs-x,0,sig);
    dg   =  ((wobs-x)./(sqrt(2.*pii).*sig.^3)) ...
        .*exp( (-(wobs-x).^2)./(2.*sig.^2)  ) ;
    
    dg2  =  ( ((wobs-x).^2)./(sqrt(2.*pii).*sig.^5)) ...
        .*exp( (-(wobs-x).^2)./(2.*sig.^2)  )  - ... 
        (1./(sqrt(2.*pii).*sig.^3)) ...
        .*exp( (-(wobs-x).^2)./(2.*sig.^2)  ) ;
else
    
    gx   = normcdf(wobs-x,0,sig);
    dg   = normpdf(wobs-x,0,sig);
    
    dg2  = ((wobs-x)./(sqrt(2.*pii).*sig.^3)) ...
        .*exp( (-(wobs-x).^2)./(2.*sig.^2)  ) ; % is it wobs negative?!
end

