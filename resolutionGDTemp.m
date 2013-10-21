function [sortie] = resolutionGDTemp(M,C,K0,dt,Ttot,HistF,U0,V0,conditionU,conditionV,conditionA,D,nonLine,nonLinearite,verif)
%% Initialisation

    HistU_m=zeros(size(HistF));
    HistU_p=zeros(size(HistF));
    HistV_m=zeros(size(HistF));
    HistV_p=zeros(size(HistF));
    %HistA=zeros(size(HistF));
    HistE  =zeros(1,size(HistF,2));
    HistEc =zeros(1,size(HistF,2));
    HistEp =zeros(1,size(HistF,2));
    HistEnl=zeros(1,size(HistF,2));
    HistEf =zeros(1,size(HistF,2));
    Ef =0;
    HistEu =zeros(1,size(HistF,2));
    Eu =0;
    
    K = K0;
    Mp= M + (2/3) * (dt^2) * K; % Attention en nonLineaire il faudra recalculer
    
%% Conditions Initiales
    
    if norm(U0)
        if (verif)
            [i,~]=find(D');
            U0(i,1) = conditionU(:,1);
        else
            ErreurVerifConditionInitialNonPriseEnCompte;
        end     
    end
    U_m = U0;   % deplacements - vecteur colonne
    U_p  = U0;
    V_m = V0;   % vitesses
    V_p  = V0;
%     A = zeros(size(M,1),1);     % accelerations
    
    nombrePasTemps=round(Ttot/dt); % Attention doit etre entier car ceil pose des problemes
    
%     if (nonLine==1)
%         % Ajout du ressort
%         kres =  nonLinearite(1).scalaires(1);
%         KresU = nonLinearite(1).matriceKUnit;
%         UresU = nonLinearite(1).dependanceEnU;
%     end

    
%% Iterations Temporelles
    
    
    for t=0:nombrePasTemps
        
        if t==0            
            HistU_m(:,t+1)  = U_m;
            HistU_p(:,t+1)  = U_p;
            HistV_m(:,t+1)  = V_m;
            HistV_p(:,t+1)  = V_p;
        else       
            
            F1 = dt*( (1/3)*HistF(:,t) + (1/6)*HistF(:,t+1) );
            F2 = dt*( (1/6)*HistF(:,t) + (1/3)*HistF(:,t+1) );
            
            F1p= (5/2)*F1 + M*V_m - (1/3)*F2 - (2/3)*dt*K*U_m;
            F2p= F1 + F2  + M*V_m            -       dt*K*U_m;
            
            VmVp = [ (1/3)*(dt^2)*Mp  Mp ; Mp  (2/3)*M ] \ [F2p ; F1p]; % Mettre en place multiplicateur Lagrange
            
            V_m = VmVp(1:size(V_m));            %V_m(t+1)
            V_p = VmVp((size(V_m)+1):end);      %V_p(t)
            
            U_p = U_m + (1/6)*dt*V_p - (1/6)*dt*V_m; %U_p(t)
            U_m = U_m + (1/2)*dt*V_p + (1/2)*dt*V_m; %U_m(t+1)            
            
            HistU_m(:,t+1)  = U_m;
            HistU_p(:,t  )  = U_p;
            HistV_m(:,t+1)  = V_m;
            HistV_p(:,t  )  = V_p;
            
        end
    
    end
        
    sortie.HistU_m= HistU_m;
    sortie.HistU_p= HistU_p;
    sortie.HistV_m= HistV_m;
    sortie.HistV_p= HistV_p;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    