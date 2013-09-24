function [sortie] = resolutionTemporelle(schem,M,C,K0,dt,Ttot,HistF,U0,V0,conditionU,conditionV,conditionA,D,nonLine,nonLinearite)
%%  Schemas d'integration

    if (schem == 1)             % Newmark - Difference centree
        alpha = 0;
        beta = 0;
        gamma = 1/2;
    elseif (schem == 2)         % Newmark - Acceleration lineaire
        alpha = 0;
        beta = 1/12;
        gamma = 1/2; 
    elseif (schem == 3)         % Newmark - Acceleration moyenne
        alpha = 0;
        beta = 1/4;
        gamma = 1/2;
    elseif (schem == 4)        % Newmark - Acceleration moyenne modifiee
        alpha = -1/9;      % -1/3 <= alpha <= 0 
        gamma = 1/2 - alpha;
        beta  = ((1-alpha)^2)/4;  
        alpha = 0;
    elseif (schem == 5)         % HHT-alpha
        alpha = -1/9;      % -1/3 <= alpha <= 0 
        gamma = 1/2 - alpha;        % alpha = -1/3 -> amortissement maximal
        beta  = ((1-alpha)^2)/4;
    end

%% Initialisation

    %S = M + ( 1+alpha )*(C*gamma*dt + K0*beta*dt^2);
    %Si = inv(S);

    HistU=zeros(size(HistF));
    HistV=zeros(size(HistF));
    HistA=zeros(size(HistF));
    HistE  =zeros(1,size(HistF,2));
    HistEc =zeros(1,size(HistF,2));
    HistEp =zeros(1,size(HistF,2));
    HistEnl=zeros(1,size(HistF,2));
    HistEf =zeros(1,size(HistF,2));
    Ef =0;
    HistEu =zeros(1,size(HistF,2));
    Eu =0;
    
%% Iterations Temporelles
  
    verif=0;
    if (size(D,1))    % correction de l erreur d integration, impossible si les deplacements sont lies
         verif=1;       % verification que les deplacement ne sont pas lies
         [c,~]=find(D);
         for j=1:size(c,1)
            for k=1:size(c,1)
                 if k~=j 
                     if ( c(j)==c(k) || verif == 0)
                         verif = 0;
                         break;
                     end
                 end
            end
         end
    end
    
    if norm(U0)
        if (verif)
            [i,~]=find(D');
            U0(i,1) = conditionU(:,1);
        else
            ErreurVerifConditionInitialNonPriseEnCompte;
        end     
    end
    U = U0;                     % deplacements - vecteur colonne
    V = V0;                     % vitesses
    A = zeros(size(M,1),1);     % accelerations
    F = HistF(:,1);     
    nombrePasTemps=round(Ttot/dt); % Attention doit etre entier car ceil pose des problemes
    if (nonLine==1)
        % Ajout du ressort
        kres =  nonLinearite(1).scalaires(1);
        KresU = nonLinearite(1).matriceKUnit;
        UresU = nonLinearite(1).dependanceEnU;
    end

    
    for t=0:nombrePasTemps

    % Conditions initiales
        if (t>0)
            % prediction
             F = (1+alpha)*HistF(:,t+1) - alpha*HistF(:,t);
             Vp = V + ( 1+alpha )*dt*(1-gamma)*A;
             Up = U + ( 1+alpha )*( dt*V + (dt^2)*(1/2 - beta)*A ); 
             Kn = K;    % en HHT on a besoin de l etape precedente
        else
            K =K0;
            Vp=V;
            Up=U;
        end            
             
        if (nonLine == 1)       % Si le ressort n'est pas lineaire
            U_i = U;
            epsilon = 10^-6;
            err = 1;
            
            % Faire un choix entre les deux methodes : 
            methode = 1;
            % 1 Modification de K a chaque pas de temps
            % 2 ajout du terme non-lineaire au second membre
            
            % Modification de K
            for cacher = 1
                while err > epsilon
                        for cacher2 = 1
                            % k = kres( U_i );
                            k = kres* (abs(UresU'*U_i))^(0.5) ;
                            Kres = k*KresU;
                            if (methode == 1)
                                K = K0;       % on retire l'ancienne contribution
                                K = K + Kres;
                                S = M + ( 1+alpha )*(C*gamma*dt + K*beta*dt^2);
                            elseif (methode == 2)                        
                                if (t>0)
                                    FnonlineaireN = Fnonlineaire;
                                    Fnonlineaire = Kres*U_i;
                                    F = F -( (1+alpha)*Fnonlineaire - alpha*FnonlineaireN);
                                else
                                    Fnonlineaire = Kres*U_i;
                                    F = F - Fnonlineaire ;
                                end
                            end
                        end
                    % S(Ui) * Ai = g1( U,Ui,V,F(n+1) );
                        if (size(D,1)) 
                             S = M + ( 1+alpha )*(C*gamma*dt + K*beta*dt^2);
                             SD  = [S D';D zeros(size(D,1))];
                             if (t>0 && methode == 1)
                                 F = F - alpha*(K-Kn)*U; % en HHT on a besoin de l etape precedente
                             end
                             Fs  = F - C*Vp - K*Up ;
                             Fsb = [Fs ; conditionA(:,t+1)];
                             AL  = SD\Fsb;
                             Ai = AL(1:size(A,1),1);
                             Landa = AL((size(A,1)+1):end,1);
                        else
                            Ai = S\( F - C*Vp - K*Up );
                        end
                    % Ui = U + g3( V,A,Ai )
                        U_ip = U_i;     % terme precedent
                        U_i = U +  dt*V + (dt^2)*( (1/2 - beta)*A  + beta*Ai );
                    % convergence
                        if (U_ip==U_i)
                            err = 0;
                        else
                            err = norm(U_i-U_ip)/ ( norm(U_i)+norm(U_ip) );
                        end
                end
            end

            if (t>0)
                 U = U_i;
                 V = V + dt*(1-gamma)*A + dt*gamma*Ai;
                 A = Ai;

                 if (verif)     % correction de l erreur d integration, impossible si les deplacements sont lies
                     [i,~]=find(D');
                     V(i,1) = conditionV(:,t+1);
                     U(i,1) = conditionU(:,t+1);
                 end
            end
            
        else
            S = M + ( 1+alpha )*(C*gamma*dt + K*beta*dt^2);
            if (size(D,1)) 
                 SD  = [S D';D zeros(size(D,1))];
                 Fs  = ( F - C*Vp - K*Up );
                 Fsb = [Fs ; conditionA(:,t+1)];
                 AL  = SD\Fsb;
                 A = AL(1:size(A,1),1);
                 Landa = AL((size(A,1)+1):end,1);
            else
                A = S\( F - C*Vp - K*Up );
                Landa = [];
            end

            if (t>0)
                 V = V + dt*(1-gamma)*HistA(:,t) + dt*gamma*A;
                 U = U + dt*HistV(:,t) + (dt^2)*(1/2 - beta)*HistA(:,t) + beta*(dt^2)*A;

                 if (verif)     % correction de l erreur d integration, impossible si les deplacements sont lies
                     [i,~]=find(D');
                     V(i,1) = conditionV(:,t+1);
                     U(i,1) = conditionU(:,t+1);
                 end
            end
        end
        
    % Calcul de l Energie pour verification
        for cacher = 1
          if (t>0)
            Ec = (M*V)'*V/2;
            HistEc(t) = Ec;
            Ep = 1/2 * U'*K0*U;
            if nonLine ==1
                Enl = kres*(2/5)*(abs(UresU'*U))^(5/2);
                HistEnl(t) = Enl;
                Ep = (Ep + Enl);
            end
            HistEp(t) = Ep;
            Ef = Ef + HistF(:,t+1)'*V*dt;
            HistEf(t) = Ef;
            if (size(Landa,1))
                Eu = Eu - Landa' * (D * V) * dt; %Eu + (D*(C*V + K*U))' * (D * V) * dt;
            end
            HistEu(t) = Eu;
            Etot=Ec+Ep-Ef-Eu;
            HistE(t) = Etot;
            % Mettre dans le progam principal :
            % plot(dt:dt:Ttot,sortie(program+1).f.HistE,'b',dt:dt:Ttot,sortie(program+1).f.HistEc,'r',dt:dt:Ttot,sortie(program+1).f.HistEp,'g')
          end
        end
        
    % Enregistrement
        HistU(:,t+1) = U;
        HistV(:,t+1) = V;
        HistA(:,t+1) = A;
        
    % Affichage

        % % if (mod(t,100)==0)      % decommenter pour afficher la progression lors des calculs longs
        % %     t*dt;
        % % end

    

    end
    
    sortie.HistU= HistU;
    sortie.HistV= HistV;
    sortie.HistA= HistA;
    
    sortie.HistE = HistE;
    sortie.HistEc= HistEc;
    sortie.HistEp= HistEp;
    sortie.HistEf= HistEf;
    sortie.HistEu= HistEu;
    sortie.HistEnl= HistEnl;
    
    % figure('Name','Deplacement du noeud en bout','NumberTitle','off')
    % plot(0:dt:Ttot,HistU(end,:));
    % %title(num2str(b));
    
    % figure('Name','Calcul sur base complete','NumberTitle','off')
    %  s(1).a = max(max(sortie(program+1).f.HistU)) - min(min(sortie(program+1).f.HistU));   % amplitude
    %  surf(0:dt:Ttot,VectL,sortie(program+1).f.HistU,'EdgeColor','none');


    %figure('Name',['Energie, probleme : ' num2str((program+1), '%10.u\n') ],'NumberTitle','off')
    % plot(0:dt:Ttot,sortie(program+1).f.HistE,'b',dt:dt:Ttot,sortie(program+1).f.HistEc,'r',dt:dt:Ttot,sortie(program+1).f.HistEp,'g',dt:dt:Ttot,sortie(program+1).f.HistEf,'k--',dt:dt:Ttot,sortie(program+1).f.HistEu,'m-.',dt:dt:Ttot,sortie(program+1).f.HistEnl,'r:');



end

