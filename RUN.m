%% Script para la ejecución del código
clc, clear, close all

%% Variables iniciales
%lectura de las coorrdenadas del PA base
OriginalFile='fx 60-126.txt';
fid=fopen(OriginalFile);
coord=textscan(fid,'%f %f');
xcoord=coord{1};
ycoord=coord{2};
fclose(fid);
%propiedades del flujo para el análisis con XFOIL
Re=225964.226;
Mach=0.06465;
alfa='0 10 1'; 

%% Llamado de funciones
%función que obtiene los parámetros de IGP
[C,XC,T,XT,bXC,rho0,alphaTE,betaTE,xeff,ycurv,ycfit,ylfit,yufit]=Get_Parameters(xcoord,ycoord);
%parámetros de IGP del perfil original
IGP0=[C XC T XT bXC rho0 alphaTE betaTE];
%función que obtiene el intradós y extradós del PA construido con parametrización
[yuparametric,ylparametric]=Get_Airfoilcurves(C,XC,T,XT,bXC,rho0,alphaTE,betaTE);
%algoritmo genético
[clori,cdori,cmori,cloriave,clfitt,cdfitt,cmfitt,clfittave,IGPfitt,yufitt,ylfitt,clave,pop,realgen,clavebygenv]=Genetic_Alg(IGP0,OriginalFile,alfa,Re,Mach);

%% Resultados
%vectores de x para las gráficas
data_pts=0:0.01:1;
xalpha=0:1:10;
efiori=clori./cdori;
efifitt=clfitt./cdfitt;

%ajuste con curvas de polinomios del PA base
figure(1);
%perfil original construido con coordenadas
p1=plot(xcoord,ycoord,'k');
hold on
%PA con polinomios ajustados
p2=plot(xeff,yufit,'g');
hold on
plot(xeff,ylfit,'g');
hold on
%curvatura del PA base con coordenadas
p3=plot(xeff,ycurv,'c');
hold on
%curvatura del PA con polimios ajustados
p4=plot(xeff,ycfit,'m');
title('Ajuste de perfil base')
legend([p1 p2 p3 p4],{'Perfil por coordenadas','Perfil de ajuste','Curvatura por coordenadas','Curvatura de ajuste'})
axis([0 1 -0.5 0.5])

%PA base y parametrizado
figure(2);
%PA base construido con coordenadas
p5=plot(xcoord,ycoord,'k');
hold on
%PA orginal construido con la parametrización
p6=plot(data_pts,yuparametric,'b');
hold on
plot(data_pts,ylparametric,'b');
title('Similitud entre perfil base y perfil parametrizado')
legend([p5 p6],{'Perfil base','Perfil parametrizado'})
axis([0 1 -0.5 0.5])

%PA base y mejorado
figure(3);
%PA base
p7=plot(xcoord,ycoord,'k');
hold on
%PA mejorado
p8=plot(data_pts,yufitt,'r');
hold on
plot(data_pts,ylfitt,'r');
title('Similitud entre perfil base y perfil mejorado')
legend([p7 p8],{'Perfil base','Perfil mejorado'})
axis([0 1 -0.5 0.5])

%gráfica del cl
figure(4);
plot(xalpha,clori,'-ok')
hold on
plot(xalpha,clfitt,'-or')
title('Coeficientes de sustentación')
ylabel('Cl')
xlabel('Ángulos de ataque')
yticks(0.2:0.2:2)
xticks(0:1:10)
legend('Perfil base','Perfil mejorado')
axis ([0 10 0 2])
grid on

%gráfica del cd
figure(5);
plot(xalpha,cdori,'-ok')
hold on
plot(xalpha,cdfitt,'-or')
title('Coeficientes de arrastre')
ylabel('Cd')
xlabel('Ángulos de ataque')
yticks(0:0.01:0.1)
xticks(0:1:10)
legend('Perfil base','Perfil mejorado')
axis ([0 10 0 0.1])
grid on

%gráfica de cl/cd
figure(6);
plot(xalpha,efiori,'-ok')
hold on
plot(xalpha,efifitt,'-or')
title('Eficiencia aerodinámica')
ylabel('Cl/Cd')
xlabel('Ángulos de ataque')
yticks(0:20:200)
xticks(0:1:10)
legend('Perfil base','Perfil mejorado')
axis ([0 10 0 200])
grid on


%% Impresión del nuevo PA
%obtención de la información sobre las coordenadas de las cruvas
figure(7);
plot(data_pts,yufitt,data_pts,ylfitt);
cData=get(gca,'Children'); 
xdata=get(cData,'XData'); 
xdata1=xdata{1}; 
xdata2=xdata{2};
ydata=get(cData,'YData');
ydata1=ydata{1};
ydata2=ydata{2};
close
%organización de las coordenadas
xcon=[fliplr(xdata2) xdata1];
ycon=[fliplr(ydata2) ydata1];
xcoord2=transpose(xcon);
ycoord2=transpose(ycon);
%generación del archivo
fid=fopen('Perfil mejorado.txt','w');
for i=1:length(xcoord2)
    fprintf(fid,'%f %f\n',xcoord2(i), ycoord2(i));
end
fclose(fid);

%final del código