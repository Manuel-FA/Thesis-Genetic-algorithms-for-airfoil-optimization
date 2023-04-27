%% Variación de parámetros para la obtención de un nuevo PA
function [IGP]=Rand_IGP(IGP,range)
IGP1=2*range(1)*rand+IGP(1)-range(1);  
IGP2=2*range(2)*rand+IGP(2)-range(2);
IGP3=2*range(3)*rand+IGP(3)-range(3);
IGP4=2*range(4)*rand+IGP(4)-range(4);
IGP5=2*range(5)*rand+IGP(5)-range(5);
IGP6=2*range(6)*rand+IGP(6)-range(6);
IGP7=2*range(7)*rand+IGP(7)-range(7);
IGP8=2*range(8)*rand+IGP(8)-range(8);
IGP=[IGP1 IGP2 IGP3 IGP4 IGP5 IGP6 IGP7 IGP8];
end