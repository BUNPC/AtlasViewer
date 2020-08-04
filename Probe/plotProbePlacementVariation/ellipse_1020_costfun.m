function f = ellipse_1020_costfun( x, headSize )

a = x(1); %  Al to Ar axis
b = x(2); % Nz to Iz axis
c = x(3); % Cz axis

% HC
h = (a-b)^2 / (a+b)^2;
HC = 3.14159 * (a+b) * (1+3*h/(10+sqrt(4-3*h)));

% IzNz
h = (b-c)^2 / (b+c)^2;
IzNz = 3.14159 * (b+c) * (1+3*h/(10+sqrt(4-3*h))) * 1.2/2;

% AlAr
h = (a-c)^2 / (a+c)^2;
AlAr = 3.14159 * (a+c) * (1+3*h/(10+sqrt(4-3*h))) * 1.2/2;



%[HC IzNz AlAr]
f = (HC-headSize.HC)^2 + (IzNz-headSize.IzNz)^2 + (AlAr-headSize.LPARPA)^2;

