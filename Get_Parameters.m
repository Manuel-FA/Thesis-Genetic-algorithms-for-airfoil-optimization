%% Obtención de los parámetros IGP
function [C,XC,T,XT,bXC,rho0,alphaTE,betaTE,xeff,ycurv,ycfit,ylfit,yufit]=Get_Parameters(xcoord,ycoord)
%% Preparación de vectores
pts=300;
k=length(xcoord)/2;
%vector con las coordenadas de x que describen el extradós
xup=zeros([1,(k)]);
i=1;
while i<=(k)
    xup(i)=xcoord(i);
    i=i+1;
end
%vector con las coordenadas de x que describen  el intradós
xlow=zeros([1,k]);
i=1;
while i<=(k)
    xlow(i)=xcoord(i+(k));
    i=i+1;
end
%vector con las coordenadas de y que describen el extradós
yup=zeros([1,k]);
i=1;
while i<=(k)
    yup(i)=ycoord(i);
    i=i+1;
end
%vector con las coordenadas de x que describen el intradós
ylow=zeros([1,k]);
i=1;
while i<=(k)
    ylow(i)=ycoord(i+(k));
    i=i+1;
end
%vector de x que se utiliza para definir las curvas
xeff=linspace(0,1,pts);
%ajuste del extradós
coefup=polyfit(xup,yup,12);
yupfix=polyval(coefup,xeff);
%ajuste del intradós 
coeflow=polyfit(xlow,ylow,12);
ylowfix=polyval(coeflow,xeff);
%construción de la linea de curvatura
ycurv=zeros([1,pts]);
i=1;
while i<=(pts)
      ycurv(i)=yupfix(i)-(yupfix(i)-ylowfix(i))/2;
      i=i+1;
end

%% Obtención de C XC T XT
%obtención de C y XC
[C,I]=max(ycurv);
XC=xeff(I);
%obtención de T y XT
Tv=abs(yupfix-ylowfix);
[T,I]=max(Tv);
XT=xeff(I);

%% Obtención de bXC
%función que describe la curvatura del PA
coefcurv=polyfit(xeff,ycurv,12);
%ecuación de curvatura
syms x
yc=(coefcurv(1)*x^12)+(coefcurv(2)*x^11)+(coefcurv(3)*x^10)+(coefcurv(4)*x^9)+(coefcurv(5)*x^8)+(coefcurv(6)*x^7)+(coefcurv(7)*x^6)+(coefcurv(8)*x^5)+(coefcurv(9)*x^4)+(coefcurv(10)*x^3)+(coefcurv(11)*x^2)+(coefcurv(12)*x)+(coefcurv(13));
ycp=diff(yc);
ycpp=diff(yc,2);
kcurv=abs(ycpp)/((1+ycp^2)^(3/2));
%obtención de bXC
bXC=double(subs(kcurv,XC));

%% Obtención de rho0 alphaTE betaTE
%funciones de intradós y extradós
yu=(coefup(1)*x^12)+(coefup(2)*x^11)+(coefup(3)*x^10)+(coefup(4)*x^9)+(coefup(5)*x^8)+(coefup(6)*x^7)+(coefup(7)*x^6)+(coefup(8)*x^5)+(coefup(9)*x^4)+(coefup(10)*x^3)+(coefup(11)*x^2)+(coefup(12)*x)+(coefup(13));
yl=(coeflow(1)*x^12)+(coeflow(2)*x^11)+(coeflow(3)*x^10)+(coeflow(4)*x^9)+(coeflow(5)*x^8)+(coeflow(6)*x^7)+(coeflow(7)*x^6)+(coeflow(8)*x^5)+(coeflow(9)*x^4)+(coeflow(10)*x^3)+(coeflow(11)*x^2)+(coeflow(12)*x)+(coeflow(13));
%funcion del grosor en función de x 
thick=(yu-yl);
thickp=diff(thick);
thickpp=diff(thick,2);
%obtención de rho0
rho=abs((1+thickp^2)^(3/2)/(thickpp));
rhovector=abs(double(subs(rho,x,xeff)));
rho0=rhovector(1);
%obtención de aplhaTE
alpha=atan(-ycp/2);
alphaTEv=double(subs(alpha,x,xeff));
alphaTE=alphaTEv(end);
%obtención de betaTE
beta=2*atan(-thickp/2);
betaTEv=double(subs(beta,x,xeff));
betaTE=betaTEv(end);
betaTE=(betaTE)/(atan(T/(1-XT)));

%% Valores de y de ajuste
ycfit=double(subs(yc,x,xeff));
yufit=double(subs(yu,x,xeff));
ylfit=double(subs(yl,x,xeff));
end