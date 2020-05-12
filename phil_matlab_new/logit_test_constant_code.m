%%% logit test

clear;
rng(1);
global Y X0 X1 X2 X3 z div2 div3

div2=1;
div3=1;

j=100;

xt=ones(j,1);
ind=[1:j]';

%for i=1:j
     i=1;
    z=10.*i + 20;
    K=1;
    F=2.1;
    
    %%% sim
    %{
    X0=rand(z,1).*10;
    X1=rand(z,1).*10;
    X2=rand(z,1).*10;
    X3=rand(z,1).*10;
    %}
    
    X0=ones(z,1);
    X1=ones(z,1);
    X2=ones(z,1);
    X3=ones(z,1);
    
    ev0=evrnd(0,1,z,1);    
    ev1=evrnd(0,1,z,1);
    ev2=evrnd(0,1,z,1);
    ev3=evrnd(0,1,z,1);

    u0= K.*X0 + ev0;
    u1= K.*X1 + F.*ones(z,1) + ev1;
    u2= K.*X2 + (F./div2).*ones(z,1) + ev2;
    u3= K.*X3 + (F./div3).*ones(z,1) + ev3;

    Y = zeros(z,1) + (u1>u2 & u1>u3 & u1>u0) ...
        + 2.*(u2>u1 & u2>u3 & u2>u0) ...
        + 3.*(u3>u2 & u3>u1 & u3>u0);

    x1=[4];
    x=fminsearch(@logit_test,x1)
    xt(i,1)=x(1,1);
    %x1=[5];
    %x=fminsearch(@logit_test,x1)
%end

plot(ind,xt)

