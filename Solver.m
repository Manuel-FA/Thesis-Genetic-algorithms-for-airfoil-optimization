%% Análisis aerodinámico
function [cl,cd]=Solver(IGP1,OriginalFile,alfa,Re,Mach,counter)
%% Conversión de los parámetros IGP a cooordenadas en un archivo de texto
%asignación del vector IGP a la correspondiente variable
if counter==0
   CoordFileName=OriginalFile;
else
   C=IGP1(1);
   XC=IGP1(2);
   T=IGP1(3);
   XT=IGP1(4);
   bXC=IGP1(5);
   rho0=IGP1(6);
   alphaTE=IGP1(7);
   betaTE=IGP1(8);
%generación de las curvas
   [yu,yl]=Get_Airfoilcurves(C,XC,T,XT,bXC,rho0,alphaTE,betaTE);
%obtención de la información sobre las coordenadas de las cruvas
   figure(1)
   data_pts=0:0.01:1;
   plot(data_pts,yu,data_pts,yl);
   cData=get(gca, 'Children'); 
   xdata=get(cData, 'XData'); 
   xdata1=xdata{1}; 
   xdata2=xdata{2};
   ydata=get(cData, 'YData');
   ydata1=ydata{1};
   ydata2=ydata{2};
   close 
%organización de las coordenadas
   xcon=[fliplr(xdata2) xdata1];
   ycon=[fliplr(ydata2) ydata1];
   xcoord=transpose(xcon); 
   ycoord=transpose(ycon);
%generación del archivo
   if exist('CoordFileName.txt','file'),delete('CoordFileName.txt'); end
   fid=fopen('CoordFileName.txt','w');
   for i=1:length(xcoord)
      fprintf(fid,'%f %f\n',xcoord(i), ycoord(i));
   end
   fclose(fid);
   CoordFileName='CoordFileName.txt';
end
%% Preparación de la ejecuión de XFOIL
%eliminación de archivos existentes
if exist('xfoil.inp','file'),delete('xfoil.inp'); end
if exist('xfoil.out','file'),delete('xfoil.out'); end
if exist('outputfile.dat','file'),delete('outputfile.dat'); end
%generación del archivo de comandos    
fid=fopen('xfoil.inp','w');
if (fid<=0)
        error('Unable to create xfoil.inp file');
else    
%carga del PA
   fprintf(fid,'load %s \n',CoordFileName);
   fprintf(fid,'DefaultName \n');
%valores de Reynolds y Mach
   fprintf(fid,'OPER \n');
   fprintf(fid,'VISC %g \n', Re);
   fprintf(fid,'MACH %g \n', Mach);
%número de iteraciones
   fprintf(fid,'iter \n');
   fprintf(fid,'200 \n');
%archivo de salida
   fprintf(fid,'PACC \n');
   fprintf(fid,'outputfile.dat \n');
   fprintf(fid,'\n');
%análisis en los grados indicados
   fprintf(fid,'ASEQ %s \n', alfa);
   fprintf(fid,'\n');
%cerrar el programa
   fprintf(fid,'QUIT \n');
   fclose(fid);

%% Ejecución de xfoil
   wd=fileparts(which(CoordFileName));
   cmd=sprintf('cd %s && xfoil.exe < xfoil.inp > xfoil.out', wd);
   system(cmd);

%% Lectura del archivo de salida
   fid=fopen('outputfile.dat','r');
   if (fid<=0) 
      error('Unable to read xfoil polar file outputfile.dat'); 
   else 
      P=textscan(fid, '%f%f%f%f%f%f%f%*s%*s%*s%*s', 'Delimiter',  ' ', 'MultipleDelimsAsOne', true, 'HeaderLines' , 12, 'ReturnOnError', false);
      fclose(fid);
      pol.alpha=P{1}(:,1);
      pol.CL=P{2}(:,1);
      pol.CD=P{3}(:,1);
      pol.CDp=P{4}(:,1);
      pol.Cm=P{5}(:,1);
      pol.Top_xtr=P{6}(:,1);
      pol.Bot_xtr=P{7}(:,1);
   end
end
%variables de salida
cl=pol.CL;
cd=pol.CD;
end
