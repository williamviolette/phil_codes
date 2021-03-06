


clear

% to do:
% (1) identify c? (understand identification in general) [ NO ASSUME IT! ]
    % * FROM FUNCTIONAL FORM see whether the estimates are reasonable
% (2) robust to SC?   [ ESTIMATED! ]
% (3) get the right solutions?   maybe dig deeper here...
% (4) DO EXPECTED UTILITY! DO NON-LINEAR PRICING! (think about rental of booster pump)
     % no expected utility!  rental market each period! ! 
% (5) run counterfactuals?? COMPARE welfare with and without   [ yes! ]
% order:  do counterfactuals with current model
     %    then test assumptions of model
            % model assumes that large users are more likeily
     %    then think about adding proper utility and price 
% 1 HP engine uses 0.786 Kw/Hour , meaning a .5 HP engine uses .786/2=.3930
% price .2 USD * 44 PhP/USD = 8.8 PhP per KwH
% 30days*2.6hrs*8.8 per KwH * .393 Kwh = 269.8
% btw .25 and 1 hp engines used in Manila
%  .5*270/2 + .5*270*2 = 338 PhP

% .786*.75engine = .5895 kwH * 8.8 PhP * 30 days * 2.6 hrs = 405 PhP

     
data=1;
if data==1
    
    for r=1:2
          
        cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/booster_sample_date.csv');

         if r==1
            cs = cs(1:40000,:)  ;
         end
         if r==2
            cs = cs(1:80000,:)  ;  
         end
            wobs    = cs(:,1);
            bobs    = cs(:,2);
            post    = cs(:,3);
            p_i     = cs(:,4);
            date    = cs(:,5);
            cmax    = cs(:,6);
            cch     = cs(:,7);
            hhsize  = cs(:,8);
            hhemp   = cs(:,9); 
            good_job= cs(:,10);
            treated = cs(:,11);
            sho     = cs(:,12);

    
            D = dummyvar(date);
            D = D(:,2:end);

            % second run: 35 sec
           alpha0 = [ 16.8;             2.4;     .27;       3.28;       -3.19;  0;     2.38;   zeros(size(D,2),1) ];
           theta1 = [1.51; 4.8; -1.07 ]; 
           alpha1 =  .17;
           sig  = 17;
           siga = 230;
          A = [ ones(size(wobs,1),1)   hhsize    hhemp     good_job      cmax   cch   treated     D  ];

          Thet = 1;          

          Tb     = [ones(size(wobs,1),1)  post  ones(size(wobs,1),1).*post ]; % 2.5s, 60s
          Tn     = Tb.*[0 1 0];

         y = 1000;
         c = 405;
%        c = 338;
         
         
         if r==1
            input = [alpha0; theta1; alpha1; sig; siga];
         else
             input = out;
         end
         given  = [ ];

        obj=@(input1)lbooster_gh9(input1,A,Tb,Tn,wobs,bobs,p_i,y,c,given); 

        tic
        [t1,t2,t3]=obj(input)
        toc

        options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');

        tic
            out=fminunc(obj,input,options)
            obj(out)
        toc
    end
else
    rng(3)
    n = 100000; % 50, 14s; 100, 34s; 200, 66s; 400000, 123s
    p_i = 5 + 30.*rand(n,1);

    alpha0 = .1.*[5 4 6 7 ]';

    A  = [   (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1)) ];
    Tb = [   (1+20.*rand(n,1))  (1+20.*rand(n,1))  (1+20.*rand(n,1))   ];
    Tn = [   0  1 0   ].*Tb;
    sig    = 5;
    alpha1 = .8;
    theta1 =  .1.*[4 2 3]';
    siga = 100;

    y = 1100;
    c = 100;

    ep  = normrnd(0,sig,n,1);
    epa = normrnd(0,siga,n,1);

    ub = upnl(A*alpha0,0,0,Tb*theta1,0,0,alpha1,0,0,p_i,0,0,y-c);
    un = upnl(A*alpha0,0,0,Tn*theta1,0,0,alpha1,0,0,p_i,0,0,y  );

    bobs=ub-un>epa;
    mean(bobs)

    wobs =   (bobs==1).*wpnl(A*alpha0,0,0,Tb*theta1,0,0,alpha1,0,0,p_i,0,0) + ...
             (bobs==0).*wpnl(A*alpha0,0,0,Tn*theta1,0,0,alpha1,0,0,p_i,0,0) + ep;

    scale = .9;
    input = scale.*[alpha0; theta1; alpha1; sig];
    input = [input; 1.1.*siga];
    given  = [ ];

    obj=@(input1)lbooster_gh9(input1,A,Tb,Tn,wobs,bobs,p_i,y,c,given); 

    tic
    [t1,t2,t3]=obj(input)
    toc

    options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');

    tic
        out=fminunc(obj,input,options)
        obj(out)
    toc


end


cd_dir = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_paper/tables/'; 
r = out;
rb = zeros(size(r,1),1);
ver = '1';
print_estimates(cd_dir,r,rb,ver)




[ut,bobs,wobs] = counter_gh9( out ,A,Tb,Tn,p_i,y,c);
    mean(ut(post==1)) - mean(ut(post==0))

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

