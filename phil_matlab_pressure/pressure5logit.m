

%%% NON LINEAR! %%%


clear
    
    cs = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/conacct_sample.csv');
        mru_c   = cs(:,2);
        pi      = cs(:,3);
        pr      = cs(:,4);
        alpha0  = cs(:,5);
        alpha1  = -1.*cs(:,6);
        theta   = cs(:,7);
    ms = readmatrix('/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/mru_sample.csv');
        mru_m   = ms(:,1);
        year    = ms(:,2);
        post    = ms(:,3);
        ba      = ms(:,4);
        baD     = dummyvar(ba);
        Nobs    = ms(:,5);

        
y = 10000;

c = 900;
t = 17.6;
gamma = 1;

[~,~,iy] = unique( ba );  
N = accumarray(iy,Nobs,[],@mean);
N = N- t.*mean(year);

SC = 1000;

given = [c; gamma; t;  N];
input = [c; gamma; t;  N]
% input = [c;  t;  N]

obj=@(input1)lpressure5(input1,Nobs,pi,pr,alpha0,alpha1,theta,y,mru_c,year,post,baD,SC,given)

% given
 
obj(input)

out   = fminunc(obj,input)

obj(out)

out(1)
out(2:end)






temp = (100:100:3000)';
v=[];
se=[];

for i=1:size(temp,1)
    [o1,o2] = obj([1400;temp(i);t;N]);
    v=[v;o1];
    se=[se;o2];
end

plot(temp,v)

plot(temp,se)




temp = (100:100:3000)';
v=[];
se=[];

for i=1:size(temp,1)
    [o1,o2] = obj([1400;temp(i);t;N]);
    v=[v;o1];
    se=[se;o2];
end

plot(temp,v)

plot(temp,se)





%%%%% THERE IS AN ISSUE IDENTIFYING THE DISTRIBUTION! %%%%%

temp1 = (100:100:1000);
temp2 = (100:100:2000);

v=zeros(size(temp1,2),size(temp2,2));
se=zeros(size(temp1,2),size(temp2,2));

for i=1:size(temp1,2)
    for j=1:size(temp2,2)
        [o1,o2] = obj([temp2(j);temp1(i);t;N]);
        v(i,j)=o1;
        se(i,j)=o2;
    end
end

surf(v)

surf(se)



% u1s = up(  S ,alpha0 ,alpha1,p,theta,y)./SC + e(:,1);
% u2s = up(  S ,alpha0 ,alpha1,0,theta,y - 2.*c )./SC + e(:,2);
% mean(u2s>u1s)
% [ud,ix,iy]=   unique( mru_year_ind );  
% output    = [ud, accumarray(iy,Bobs,[],@mean)];
