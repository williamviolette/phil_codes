function h = simple_print(table_name,entry,format,slash,cd_out)


    fileID = fopen(strcat(cd_out,slash,'tables',slash,table_name,'.tex'),'w');
    fprintf(fileID,'%s',num2str(entry,format));
    fclose(fileID);
    
    h=1;
    