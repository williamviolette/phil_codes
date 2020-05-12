


from sympy import * 


x, y, z, j, k, l, p, w, g, a, yy, pp, F = symbols('x y z j k l p w g a yy pp F')

init_printing(use_unicode=True)


uu = x + w - (1/(2*a))*(w + a - g)**2 

la = uu  - p*w - y*w*w

d1 = diff(la,w)


ss=solve(Eq(d1, 0), w)

su=collect(expand(uu.subs(w, ss[0])),g)
sua = collect(expand(uu.subs({w:ss[0], y:yy,p:pp})),g)
print ss
print su
print sua

suas=solve(Eq(su-sua-F,0),g)
print simplify(suas[0].subs({yy:y/2,pp:p/2}))