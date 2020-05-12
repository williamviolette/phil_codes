function U = u3gen(a1,a2,a3,g1,g2,g3,esq,...
                y1,y2,y3,...
                pi1,pr1,pi2,pr2,pi3,pr3)

            % scale, then EXP! 

u_ind = ua(a1,esq,g1,pi1,pr1,y1)  + ua(a2,esq,g2,pi2,pr2,y2) + ua(a3,esq,g3,pi3,pr3,y3) ; % IND

% check 1 prefs, 2 prices

u_12 = us2(a1,a2,esq,g1,g2,pi1,pr1,y1) + us2(a2,a1,esq,g2,g1,pi1,pr1,y2) + ua(a3,esq,g3,pi3,pr3,y3)  ; % 1+2 SHR 3 alone
u_21 = us2(a1,a2,esq,g1,g2,pi2,pr2,y1) + us2(a2,a1,esq,g2,g1,pi2,pr2,y2) + ua(a3,esq,g3,pi3,pr3,y3)  ; % 2+1 SHR 3 alone

u_13 = us2(a1,a3,esq,g1,g3,pi1,pr1,y1) + us2(a3,a1,esq,g3,g1,pi1,pr1,y3) + ua(a2,esq,g2,pi2,pr2,y2)  ; % 1+3 SHR 2 alone
u_31 = us2(a1,a3,esq,g1,g3,pi3,pr3,y1) + us2(a3,a1,esq,g3,g1,pi3,pr3,y3) + ua(a2,esq,g2,pi2,pr2,y2)  ; % 3+1 SHR 2 alone

u_23 = us2(a2,a3,esq,g2,g3,pi2,pr2,y2) + us2(a3,a2,esq,g3,g2,pi2,pr2,y3) + ua(a1,esq,g1,pi1,pr1,y1)  ; % 2+3 SHR 1 alone
u_32 = us2(a2,a3,esq,g2,g3,pi3,pr3,y2) + us2(a3,a2,esq,g3,g2,pi3,pr3,y3) + ua(a1,esq,g1,pi1,pr1,y1)  ; % 3+2 SHR 1 alone

u_1_3  =    us3(a1,a2,a3,esq,g1,g2,g3,pi1,pr1,y1) + ...
            us3(a2,a1,a3,esq,g2,g1,g3,pi1,pr1,y2) + ...
            us3(a3,a2,a1,esq,g3,g2,g1,pi1,pr1,y3) ; % all share with 1
        
u_2_3  =    us3(a1,a2,a3,esq,g1,g2,g3,pi2,pr2,y1) + ...
            us3(a2,a1,a3,esq,g2,g1,g3,pi2,pr2,y2) + ...
            us3(a3,a2,a1,esq,g3,g2,g1,pi2,pr2,y3) ; % all share with 2
        
u_3_3  =    us3(a1,a2,a3,esq,g1,g2,g3,pi2,pr3,y1) + ...
            us3(a2,a1,a3,esq,g2,g1,g3,pi2,pr3,y2) + ...
            us3(a3,a2,a1,esq,g3,g2,g1,pi2,pr3,y3) ; % all share with 3
        
U = [u_ind u_12 u_21 u_13 u_31 u_23 u_32 u_1_3 u_2_3 u_3_3];


