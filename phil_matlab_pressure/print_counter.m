function [h]=print_counter(cd_dir,out,A,Tb,Tn,Pi,y,c  )


% [ut,bobs,wobs] = counter_gh9( out ,A,Tb,Tn,p_i,y,c);
%     mean(ut(post==1)) - mean(ut(post==0))

Tb     = [ones(size(wobs,1),Thet)  zeros(size(wobs,1),Thet)   zeros(size(wobs,1),Thet)  ]; % 2.5s, 60s
Tn     = Tb.*[zeros(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  zeros(size(wobs,1),Thet) ];
[utpre,bobspre,wobspre] = counter_gh9( out ,A,Tb,Tn,p_i,y,c);

Tb     = [ones(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  ]; % 2.5s, 60s
Tn     = Tb.*[zeros(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  zeros(size(wobs,1),Thet) ];
[utpost,bobspost,wobspost] = counter_gh9( out ,A,Tb,Tn,p_i,y,c);

mean(utpost(post==1)-utpre(post==1))
mean(bobspost(post==1)-bobspre(post==1))
mean(wobspost(post==1)-wobspre(post==1))


%%% NO booster!? welfare effects are bigger!! (by 20 PhP) %%%
Tb     = [zeros(size(wobs,1),Thet)  zeros(size(wobs,1),Thet)   zeros(size(wobs,1),Thet)  ]; % 2.5s, 60s
Tn     = Tb.*[zeros(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  zeros(size(wobs,1),Thet) ];
[utpre,bobspre,wobspre] = counter_gh9( out ,A,Tb,Tn,p_i,y,c);

Tb     = [zeros(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  zeros(size(wobs,1),Thet)  ]; % 2.5s, 60s
Tn     = Tb.*[zeros(size(wobs,1),Thet)  ones(size(wobs,1),Thet)  zeros(size(wobs,1),Thet) ];
[utpost,bobspost,wobspost] = counter_gh9( out ,A,Tb,Tn,p_i,y,c);


mean(utpost(post==1)-utpre(post==1))
mean(bobspost(post==1)-bobspre(post==1))
mean(wobspost(post==1)-wobspre(post==1))
