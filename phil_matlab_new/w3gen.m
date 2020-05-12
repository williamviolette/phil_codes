function W = w3gen(a1,a2,a3,g1,g2,g3, ...
                pi1,pr1,pi2,pr2,pi3,pr3)

    w_p1_ind   = wa(a1,g1,pi1,pr1)            ;
    w_p2_ind   = wa(a2,g2,pi2,pr2)               ;
    w_p3_ind   = wa(a3,g3,pi3,pr3)               ;
    
    w_s_12  = w(a,g,p1) + w(a,g,p1)     ;
    w_i_12  = w(a,g,p3)                 ;
    
    w_s_21  = w(a,g,p2) + w(a,g,p2)     ;
    w_i_21  = w(a,g,p3)                 ;
    
    w_s_13  = w(a,g,p1) + w(a,g,p1)     ;
    w_i_13  = w(a,g,p2)                 ;
    
    w_s_31  = w(a,g,p3) + w(a,g,p3)     ;
    w_i_31  = w(a,g,p2)                 ;
    
    w_s_23  = w(a,g,p2) + w(a,g,p2)     ;
    w_i_23  = w(a,g,p1)                 ;
    
    w_s_32  = w(a,g,p3) + w(a,g,p3)     ;
    w_i_32  = w(a,g,p1)                 ;
    
    w_s_1_3  = w(a,g,p1) + w(a,g,p1) + w(a,g,p1)      ;
        
    w_s_2_3  = w(a,g,p2) + w(a,g,p2) + w(a,g,p2)      ;
       
    w_s_3_3  = w(a,g,p3) + w(a,g,p3) + w(a,g,p3)      ; 