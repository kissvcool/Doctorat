function [Famille,omega]=AnalyseRR(nombreDeModeRR,M,K0,conditionU,D,VectL)

 % nombre de modes que l on desire calculer
Famille=zeros(size(M,1),nombreDeModeRR);                   % Contiendra les modes
omega=zeros(1,nombreDeModeRR);                             % Contiendra omega =2*pi*frequences
x=rand(size(M,1),1);
K0D  = [K0 D';D zeros(size(D,1))];
%M(6,6)=M(6,6)*1.01;
epsilon = 10^(-5);
for j=1:nombreDeModeRR 
    if (size(Famille,2))
        for i=1:size(Famille,2);
              x = x - x'*Famille(:,i)*Famille(:,i);
              x = x / norm(x);
        end
    end
    if (isempty(conditionU))
        b=[];
    else
        b=conditionU(:,1);
    end
    [Famille(:,j),omega(j)]=rayleigh(K0D,M,b,epsilon,x,Famille);
end

% Affichage
for j=1:nombreDeModeRR
    figure('Name','Modes par la Methode de Ratleigh-Ritz','NumberTitle','off')
    plot(VectL,Famille(:,j));
    axis([0 VectL(end) min(Famille(:,j))-0.2*abs(min(Famille(:,j))) max(Famille(:,j))+0.2*abs(max(Famille(:,j)))]);
    title(['mode '  num2str(j) ]);
end

end