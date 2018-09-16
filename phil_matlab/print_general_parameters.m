function h = print_general_parameters(est_version, ...
    tag,controls,sample,size_smp,boot_max,mac,reps,sto,cd_out,cd_dir)



if mac==1
    slash = '/';
else
    slash = '\';
end

%%% INPUT SAMPLE SIZE
    fileID = fopen(strcat(cd_out,'tables',slash,'standard_sample_size.tex'),'w');
    fprintf(fileID,'%s\n', ...
                    num2str(size_smp(1),'%20.0f'));            
    fclose(fileID);
      
%%% GROUP SAMPLE SIZE
    g          = csvread(strcat(cd_dir,'g_',tag,'.csv'),1,0)  ;
    group_sample=sum(g);
    fileID = fopen(strcat(cd_out,'tables',slash,'group_sample_size.tex'),'w');
    fprintf(fileID,'%s\n', ...
                    num2str(group_sample,'%5.0f'));            
    fclose(fileID);
    
    
%%% INPUT BOOT INTERATIONS
    fileID = fopen(strcat(cd_out,'tables',slash,'boot_max.tex'),'w');
    fprintf(fileID,'%s\n', ...
                    num2str(boot_max,'%5.0f'));            
    fclose(fileID);
    
%%% REPS
    fileID = fopen(strcat(cd_out,'tables',slash,'sim_repetitions.tex'),'w');
    fprintf(fileID,'%s\n', ...
                    num2str(reps,'%5.0f'));            
    fclose(fileID);
        
 
%%% REPS
    fileID = fopen(strcat(cd_out,'tables',slash,'sim_time_periods.tex'),'w');
    fprintf(fileID,'%s\n', ...
                    num2str(sto,'%5.0f'));            
    fclose(fileID);
    
    
    
    
h=1;