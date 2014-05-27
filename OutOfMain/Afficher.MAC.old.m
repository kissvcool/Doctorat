
clear all
load('100ModesAvecNormNonAmortis1.7xFpropre.mat')
reduc = 1;
n=100;
[PRT] = BaseReduite (reduc,100,M,K0,D,conditionU,VectL,sortie(1).f.HistU');
        sortie(1+n).p = PRT;
ModePOD = (sortie(1+n).p)';
    NbModesPOD= size(ModePOD,1);
    NbModesPGD = Mmax;
    ModePGD=zeros(NbModesPGD,size(VectL,2));
    
for i=1:NbModesPGD
    ModePGD(i,:) = HistMf(1:size(VectL,2),i)';
end
AnalyseDeMAC(NbModesPOD,NbModesPGD,ModePOD,ModePGD);