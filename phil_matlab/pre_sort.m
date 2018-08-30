function  [input1,input2,input3,errors1,errors2,errors3,CHOICE_TRUE] = pre_sort(input1,input2,input3,...
                                                                    errors1,errors2,errors3,CHOICE_TRUE,...
                                                                    sort_condition_pre,TUNE,sto,reps,...
                                                                    F_given,FA_given,PA_given)
    
    F1 = F_given.*ones(size(input1,1),1);
    F2 = F_given.*ones(size(input1,1),1);
    F3 = F_given.*ones(size(input1,1),1);
                                                                               
    FA1 = FA_given.*ones(size(input1,1),1);
    FA2 = FA_given.*ones(size(input1,1),1);
    FA3 = FA_given.*ones(size(input1,1),1);
    
    PA1 = PA_given.*ones(size(input1,1),1);
    PA2 = PA_given.*ones(size(input1,1),1);
    PA3 = PA_given.*ones(size(input1,1),1);

input1 = [input1 CHOICE_TRUE(:,1) F1 PA1 FA1];
input2 = [input2 CHOICE_TRUE(:,2) F2 PA2 FA2];
input3 = [input3 CHOICE_TRUE(:,3) F3 PA3 FA3];

    if sort_condition_pre==1
            [~,~,U1_I] =utility_calc_input_tune(sto,input1(:,1:3),input1(:,5:7),input1(:,8:11),input1(:,13:14),errors1,TUNE);
            [~,~,U2_I] =utility_calc_input_tune(sto,input2(:,1:3),input2(:,5:7),input2(:,8:11),input2(:,13:14),errors2,TUNE);
            [~,~,U3_I] =utility_calc_input_tune(sto,input3(:,1:3),input3(:,5:7),input3(:,8:11),input3(:,13:14),errors3,TUNE);

            [~,~,U1_A] =utility_calc_single_price_input(sto,input1(:,1:2),input1(:,15),[input1(:,13) input1(:,16)],errors1);
            [~,~,U2_A] =utility_calc_single_price_input(sto,input2(:,1:2),input2(:,15),[input2(:,13) input2(:,16)],errors2);
            [~,~,U3_A] =utility_calc_single_price_input(sto,input3(:,1:2),input3(:,15),[input3(:,13) input3(:,16)],errors3);

            UD_1=U1_I-U1_A;
            UD_2=U2_I-U2_A;
            UD_3=U3_I-U3_A;

            U_M=[UD_1 UD_2 UD_3];

                    [~,S2]=sort(U_M,2,'descend');
    elseif sort_condition_pre==2
           w1a =utility_calc_single_price_input(sto,input1(:,1:2),ptest.*ones(size(input1,1),1),[input1(:,13) input1(:,16)],errors1);
           w2a =utility_calc_single_price_input(sto,input2(:,1:2),ptest.*ones(size(input2,1),1),[input2(:,13) input2(:,16)],errors2);
           w3a =utility_calc_single_price_input(sto,input3(:,1:2),ptest.*ones(size(input3,1),1),[input3(:,13) input3(:,16)],errors3);
            U_M=[w1a w2a w3a];
                    [~,S2]=sort(U_M,2,'descend');
    else
            U_M=[ input1(:,1) input2(:,1) input3(:,1) ];
                    [~,S2]=sort(U_M,2,'descend');
    end


            %%%%%%% INPUTS
                    S2input = repmat(S2,size(input1,2),1); %%% FIRST FOR INPUTS 
                    [m,n]=size(S2input);
                    ind = sub2ind([m n],repmat((1:m)',1,n),S2input);

                    inputr = [ reshape(input1,size(input1,1).*size(input1,2),1) ...
                               reshape(input2,size(input2,1).*size(input2,2),1) ...
                               reshape(input3,size(input3,1).*size(input3,2),1) ];
                    inputr  = inputr(ind);

            input1 = reshape(inputr(:,1),size(input1,1),size(input1,2));
            input2 = reshape(inputr(:,2),size(input1,1),size(input1,2));
            input3 = reshape(inputr(:,3),size(input1,1),size(input1,2));

            %%%%%%% ERRORS
                    S2einput = repmat(repelem(S2,sto*reps,1),size(errors1,2),1); %%% SECOND FOR ERRORS
                    [me,ne]=size(S2einput);
                    inde = sub2ind([me ne],repmat((1:me)',1,ne),S2einput);       

                    errorsr = [ reshape(errors1,size(errors1,1).*size(errors1,2),1) ...
                                reshape(errors2,size(errors2,1).*size(errors2,2),1) ...
                                reshape(errors3,size(errors3,1).*size(errors3,2),1) ];
                    errorsr = errorsr(inde);
            errors1 = reshape(errorsr(:,1),size(errors1,1),size(errors1,2));
            errors2 = reshape(errorsr(:,2),size(errors1,1),size(errors1,2));
            errors3 = reshape(errorsr(:,3),size(errors1,1),size(errors1,2)); 
            
CHOICE_TRUE = [ input1(:,end-3) input2(:,end-3) input3(:,end-3) ];

input1=input1(:,1:(end-4));
input2=input2(:,1:(end-4));
input3=input3(:,1:(end-4));



