function    [CA,SE,D,control_id]=generate_controls...
                ( controls , SHH_control, CONTROL , Q_obs, t )


%%% CONTROLS OPTION
controls = controls(1:3);



    %%% CONTROLS:  (note: for now, controls are not included in simulation,
    %%% update later
    
    %%% FOR NOW :
    if controls(1)==1       %%%%%%%%%%%%%%%% CA %%%%%%%%%%%%%%
        CA=ones(size(CONTROL,1),1);
    else
        CA = [(round(CONTROL(:,2))==1) (round(CONTROL(:,2))==2) (round(CONTROL(:,2))>2)];
    end
    
    CC = zeros(size(CONTROL,1),1);    %%%%%%%%%%%%% SE %%%%%%%%%%%%%
    for i = 1:controls(2)
       pct = ( i./controls(2) ).*100;
       CC = CC +  ( PRC(pct,Q_obs,t)==1 ) ;
    end
    SE = dummyvar(CC);
    
    if SHH_control>0
       SE = [SE (round(CONTROL(:,2))==2) (round(CONTROL(:,2))==3)];
       controls = [controls(1) (controls(2)+SHH_control) controls(3)];   %% UPDATE CONTROLS FOR SHH !!!!!!!!!!!!!!!
    end
    
        D = ones(size(CONTROL,1),1); %%%%%%%%%%%%%%%%%%%%%% D %%%%%%%%%%%
    if controls(3)>=3
        D =[ones(size(CONTROL,1),1) ...
            (CONTROL(:,1)>prctile(CONTROL(:,1),33) & CONTROL(:,1)<prctile(CONTROL(:,1),67))...
            (CONTROL(:,1)>prctile(CONTROL(:,1),67)) ...
            ];
    end
    if controls(3)>=4
        for i = 4:controls(3)
            D = [ D CONTROL(:,i-1) ];   %%% KEY ! ITS i-1 !!
        end
    end
    

control_id=controls;




   
    
    