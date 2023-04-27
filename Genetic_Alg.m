%% Algoritmo gen�tico para dise�o de perfiles aerodin�micos
function [clori,cdori,cloriave,clfitt,cdfitt,clfittave,IGPfitt,yufitt,ylfitt,clave,pop,realgen,clavebygenv]=Genetic_Alg(IGP0,OriginalFile,alfa,Re,Mach)

%declaraci�n de variables iniciales
range=[0.005 0.0551 0.0217 0.0485 0.1905 0.0889 0.0694 0.5617];
numgen=100;
popsize=20; 
transprob=0.05; 
crossprob=0.75; 
mutprob=0.2; 
newpop=[];
counter=0;
realgen=0;
clavebygenv=[];

%evaluaci�n aerodin�mica del PA base
[clori,cdori]=Solver(IGP0,OriginalFile,alfa,Re,Mach,counter);
clori10=clori(end);
cloriave=(sum(clori)/11);
counter=counter+1;

%ciclo principal
for k=1:numgen
cl10=[];
clave=[];
IGP=[];

%evaluaci�n aerodin�mica de la poblaci�n actual
for i=1:length(newpop) 
    IGP1=newpop(i,:);
    [clnew,~]=Solver(IGP1,OriginalFile,alfa,Re,Mach,counter);
    if ~isempty(clnew)
       cl10=[cl10;clnew(end)];
    else
       cl10=[cl10;0];
    end
    clnewave=(sum(clnew)/11);
    clave=[clave;clnewave]; 
    IGP=[IGP;IGP1]; 
end

%generaci�n la poblaci�n inicial
for i=1:popsize-length(newpop) 
    IGP1=Rand_IGP(IGP0,range); 
    [clnew,~]=Solver(IGP1,OriginalFile,alfa,Re,Mach,counter); 
    if ~isempty(clnew)
       cl10=[cl10;clnew(end)];
    else
       cl10=[cl10;0];
    end
    clnewave=(sum(clnew)/11);
    clave=[clave;clnewave]; 
    IGP=[IGP;IGP1];    
end

%torneo
pop=IGP; 
[clavesort,ind]=sort(clave,'descend');
clavebygen=clavesort(1);
clavebygenv=[clavebygenv;clavebygen];

%evaluaci�n de las restricci�n
realgen=realgen+1;
if clave(ind(1))>cloriave && cl10(ind(1))>clori10
    break
end

%proceso de evoluci�n
%operaci�n de trascendencia
ind=ind(1:ceil(transprob*popsize)); 
if k~=numgen 
    newpop=pop(ind,:);
    %operaci�n de cruzamiento
    for i=1:ceil(crossprob*popsize) 
        indv1=randi([1,popsize],1); 
        indv2=randi([1,popsize],1); 
        crossindex=randi([1,8],1); 
        newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)];
    end
    %operaci�n de mutaci�n
    for i=1:ceil(mutprob*popsize) 
        indv=pop(randi([1,popsize],1),:); 
        mutindex=randi([1,8],1);
        IGPmut=Rand_IGP(IGP0,range);
        indv(mutindex)=IGPmut(mutindex);
        newpop=[newpop;indv]; 
    end
end

%reporte de variables durante la ejeccuci�n del algoritmo
fprintf('realgen %d \n',realgen)
fprintf('clroriave %d clfittave %d \n',cloriave,clave(ind(1)))
fprintf('clori10 %d clfitt10 %d \n',clori10,cl10(ind(1)))
fprintf('clavebygenv %d \n',clavebygenv)
end

%selecci�n del individuo mejor adaptado y obtenci�n de las caracter�sticas aerodin�micas
IGPfitt=pop(ind(1),:); 
clfittave=clave(ind(1)); 
[clfitt,cdfitt]=Solver(IGPfitt,OriginalFile,alfa,Re,Mach,counter); 

%obtenci�n de las curvas del PA seleccionado
C=IGPfitt(1);
XC=IGPfitt(2);
T=IGPfitt(3);
XT=IGPfitt(4);
bXC=IGPfitt(5);
rho0=IGPfitt(6);
alphaTE=IGPfitt(7);
betaTE=IGPfitt(8); 
[yufitt,ylfitt]=Get_Airfoilcurves(C,XC,T,XT,bXC,rho0,alphaTE,betaTE); 

end