function x=triangle(n)

x = log(n./(sqrt(2.*pi)))/lambertw( (1/exp(1)).*(log(n./(sqrt(2.*pi))))) - 1/2;