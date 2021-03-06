function h = u( alpha0,alpha1,p1,theta0,theta1,S,B,beta,y,c)

h = ( alpha0 + (alpha1./beta) + alpha1.*p1 + ...
      S.*(theta0+theta1.*B) + beta.*(y-c.*B) ).*exp(-1.*beta.*p1) ;