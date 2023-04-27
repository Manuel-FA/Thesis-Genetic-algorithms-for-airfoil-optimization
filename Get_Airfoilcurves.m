%% Obtención de curvas del PA a partir de parámetros IGP
function[yu,yl]=Get_Airfoilcurves(C,XC,T,XT,bXC,rho0,alphaTE,betaTE)
%sistema de ecauciones para obtener c1, c2, c3 y c4
ec=@(x)[(3*x(3)*(3*x(5)^2-4*x(5)+1))+(3*x(4)*(-3*x(5)^2+2*x(5)));
        (3*x(3)*x(5)*(1-x(5))^2)+(3*x(4)*(1-x(5))*x(5)^2)-C;
        (3*x(1)*x(5)*(1-x(5))^2)+(3*x(2)*(1-x(5))*x(5)^2)+(x(5)^3)-XC;
        (x(4)/(1-x(2)))-tan(alphaTE);
        abs(((6*x(3)*(3*x(5)-2))+(6*x(4)*(-3*x(5)+2)))/(((6*x(1)*(3*x(5)-2))+(6*x(2)*(-3*x(5)+2))+(3*x(5)^2))^2))-(bXC)];
options=optimoptions('fsolve','MaxFunctionEvaluations',2000,'Display','off'); 
CB0=[0.5,0.5,0.5,0.5,0.5];
for i=1:2
    CB=fsolve(ec,CB0,options);   
    CB0=CB;
end
c1=CB(1);                
c2=CB(2);
c3=CB(3);
c4=CB(4);
kc=CB(5);

%% Curvatura
data_pts=0:0.01:1; 
mx = [c1 c2]; 
my = [c3 c4]; 
syms k X; 
finv = solve((3*k*(1-k)^2*mx(1) + 3*(1-k)*k*k*mx(2) + k^3)-X,k);
finv = real(double(subs(finv,X,data_pts))); 
if finv(1,2)>0 && finv(1,2)<1
    K = finv(1,:);
elseif finv(2,2)>0 && finv(2,2)<1
    K = finv(2,:);
elseif finv(3,2)>0 && finv(3,2)<1
    K = finv(3,:);
end
fy=@(my,K)(3*K.*(1-K).^2*my(1) + 3*(1-K).*K.*K*my(2)); 
yc = fy(my,K);

%% Grosor
rho0   = rho0*T*T/XT/XT; 
betaTE = betaTE*atan(T/(1-XT)); 
syms x; 
Pt=[T 0 -tan(betaTE/2) sqrt(2*rho0) 0]; 
g0=[x^0.5         
    x
    x^2
    x^3
    x^4
    ];
dg0=[             
    0.5/x^0.5 
    1
    2*x
    3*x^2
    4*x^3
    ];
k0=[              
    1
    0
    0
    0
    0
    ];
G=[subs(g0,x,XT) subs(dg0,x,XT) subs(dg0,x,1)/2 k0 subs(g0,x,1)];
G=double(G); 
g=@(t,K)(t(1)*K.^0.5+t(2)*K+t(3)*K.^2+t(4)*K.^3+t(5)*K.^4); 
t=Pt/G; 

%% Obtención de curvas de intradós y extradós
yu=yc+g(t,data_pts)/2;
yl=yc-g(t,data_pts)/2;

end
