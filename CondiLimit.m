function [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0] = CondiLimit(CL,M,C,K0,cas,nombrePasTemps,dt,Ttot,AmpliF)
%% Encastrement en debut et fin (ressort encastre)
if (CL==1)
    % Expression generale
    % [D]*[a] = [ba]
    % [D]*[v] = [bv]
    % [D]*[u] = [bu]
    % Dependant du schema de resolution on imposera acceleration ou vitesse
    % les autres termes peuvent etre utilise comme correcteurs
    conditionA=zeros(1,nombrePasTemps+1);
    conditionV=zeros(1,nombrePasTemps+1);
    conditionU=zeros(1,nombrePasTemps+1);

    D = zeros(1,size(M,1));
    noeudAuDepImp= 1;
    D(1,noeudAuDepImp)=1;

    conditionA(1,:) = 0;    % [ba](1)
    conditionV(1,:) = 0;    % [bv](1)
    conditionU(1,:) = 0;    % [bu](1)

    noeudAuDepImp= size(M,1);
    D(2,noeudAuDepImp)=1;

    conditionA(2,:) = 0;    % [ba](2)
    conditionV(2,:) = 0;    % ....
    conditionU(2,:) = 0;         
elseif (CL==2)  % elemination     
    M=M(2:end-1,2:end-1);
    K0=K0(2:end-1,2:end-1);
    C=C(2:end-1,2:end-1);
    nombreNoeuds = size(M,1);
end

%% Condition en effort
HistF=zeros(size(M,1),(nombrePasTemps+1)); % Donnees

if (CL==1)    
    NoeudCharge = size(M,1)-1;
elseif (CL==2)    
    NoeudCharge = size(M,1);
end


if (cas == 2)
    omega = 1.5516e+04 ; 
    HistF(NoeudCharge,:) = (1- cos( (0:dt:Ttot)*omega))*AmpliF;
elseif (cas ==4)
    HistF(NoeudCharge,:) = AmpliF;
elseif (cas ==5)
    HistF(NoeudCharge,:) = (0:dt:Ttot)*AmpliF;
elseif (cas ==6)
    HistF(NoeudCharge,1:50) = AmpliF;
end


%% Position et Vitesse initiales   
U0 = zeros(size(M,1),1);
if (cas==1)          % Deformee correspondant a un effort en bout
    if (CL==1)
        for j=1:size(M,1)       
            U0(j,1) = 0.1*L*(j-1)/nombreElements;
        end 
    elseif (CL==2)
        for j=1:size(M,1)       
            U0(j,1) = 0.1*L*j/nombreElements;
        end      
    end
end
V0 = zeros(size(M,1),1) ; 

%% Deplacement impose au cours du temps
if (cas ==3)
    omega = 1e+04;
    noeudAuDepImp= ceil(size(M,1)/2);
    if (CL==1)
        NumeroCondition = 3;
    elseif (CL==2)
        D = zeros(1,size(M,1));
        NumeroCondition = 1;
    end        
        D(NumeroCondition,noeudAuDepImp)=1;
        conditionA(NumeroCondition,:) = -omega^2 * cos( (0:dt:Ttot)*omega) /100;    
        conditionV(NumeroCondition,:) = -omega   * sin( (0:dt:Ttot)*omega) /100; 
        conditionU(NumeroCondition,:) = (-1      + cos( (0:dt:Ttot)*omega))/100; 
elseif (CL==2)    
        D = [];
        conditionA = [];   
        conditionV = []; 
        conditionU = [];
end










