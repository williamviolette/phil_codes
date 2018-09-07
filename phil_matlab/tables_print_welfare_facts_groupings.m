function h = tables_print_welfare_facts_groupings(mac,cd_dir,cd_out)

if mac==1
    slash = '/';
else
    slash = '\';
end

RES_NS=csvread(strcat(cd_dir,'tables',slash,'RES_','high_ph_group','.csv'));

RES_WS=csvread(strcat(cd_dir,'tables',slash,'RES_','normal_group','.csv'));

mean_inc = csvread(strcat(cd_dir,'tables',slash,'mean_inc_group.csv'));



h=simple_print('first_best_surplus_group',RES_NS(4,1),'%5.1f',slash,cd_out);
h=simple_print('first_best_surplus_percent_income_group',100*RES_NS(4,1)/mean_inc,'%5.2f',slash,cd_out);

h=simple_print('first_best_percent_vendor_group',100*RES_NS(2,1),'%5.0f',slash,cd_out);

h=simple_print('tpt_surplus_improvement_group',100*(1-((RES_NS(4,1)-RES_NS(4,3))/RES_NS(4,1))),'%5.0f',slash,cd_out);


h=simple_print('tpt_improvement_percent_sharing_group',100*(RES_WS(4,3)-RES_WS(4,2))/RES_WS(4,2),'%5.0f',slash,cd_out);


h=simple_print('tpt_improvement_income_sharing_group',100*(RES_WS(4,3)-RES_WS(4,2))/mean_inc,'%5.1f',slash,cd_out);


h=simple_print('tpt_social_surplus_change_low_sharing_group',(RES_WS(5,4)-RES_WS(5,3)),'%5.1f',slash,cd_out);
h=simple_print('tpt_social_surplus_change_avg_sharing_group',(RES_WS(4,4)-RES_WS(4,3)),'%5.1f',slash,cd_out);


%h=simple_print(table_name,matrix,entry,format,slash);




