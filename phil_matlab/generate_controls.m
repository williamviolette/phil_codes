function    [CA,SE,D,control_id]=generate_controls...
                ( controls , SHH_control, CONTROL , Q_obs, t )


%%% controls_gen OPTION
controls_gen = controls(1:3);



    %%% controls_gen:  (note: for now, controls_gen are not included in simulation,
    %%% update later
    
    %%% FOR NOW :
    if controls_gen(1)==1       %%%%%%%%%%%%%%%% CA %%%%%%%%%%%%%%
        CA=ones(size(CONTROL,1),1);
    else
        CA = [(round(CONTROL(:,2))==1) (round(CONTROL(:,2))==2) (round(CONTROL(:,2))>2)];
    end
    
    CC = zeros(size(CONTROL,1),1);    %%%%%%%%%%%%% SE %%%%%%%%%%%%%
    for i = 1:controls_gen(2)
       pct = ( i./controls_gen(2) ).*100;
       CC = CC +  ( PRC(pct,Q_obs,t)==1 ) ;
    end
    SE = dummyvar(CC);
    
    if SHH_control>0
       SE = [SE (round(CONTROL(:,2))==2) (round(CONTROL(:,2))==3)];
       controls_gen = [controls_gen(1) (controls_gen(2)+SHH_control) controls_gen(3)];   %% UPDATE controls_gen FOR SHH !!!!!!!!!!!!!!!
    end
    
        D = ones(size(CONTROL,1),1); %%%%%%%%%%%%%%%%%%%%%% D %%%%%%%%%%%
    if controls_gen(3)>=3
        D =[ones(size(CONTROL,1),1) ...
            (CONTROL(:,1)>prctile(CONTROL(:,1),33) & CONTROL(:,1)<prctile(CONTROL(:,1),67))...
            (CONTROL(:,1)>prctile(CONTROL(:,1),67)) ...
            ];
    end
    if controls_gen(3)>=4
        for i = 4:controls_gen(3)
            D = [ D CONTROL(:,i-1) ];   %%% KEY ! ITS i-1 !!
        end
    end
    

control_id=controls_gen;




   
    
    