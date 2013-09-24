function [PRT] = BaseReduite (reduc,TailleBase,nombreNoeuds,M,K0,D,conditionU,VectL,Donnees)


        if (TailleBase>nombreNoeuds)
            fprintf('Nombre de noeuds insuffisant\n');
            return;
        end
        PRT =zeros(size(M,1),TailleBase+size(D,1)); % Matrice de Passage 
                                           % de la base Reduite a la base Totale

        if (reduc == 1)
            % POD
            [U_SVD,S_SVD,V_SVD]=svd(Donnees);
            for i=1:TailleBase
                ModeEspace = S_SVD(i,i)*V_SVD(:,i)';
                PRT(:,i) = ModeEspace /norm(ModeEspace); 
            end

        elseif (reduc == 2)
            % Rayleigh-Ritz
            [Famille,omega]=AnalyseRR(TailleBase,M,K0,conditionU,D,VectL);
            if (size(Famille,2) >= TailleBase)
                PRT(:,1:TailleBase) = Famille(:,1:TailleBase);
            else
                fprintf('Il y a moins de mode trouves par Rayleigh que la taille souhaitee de reduction\n');
                return;
            end
            
        elseif (reduc == 3)
            % PGD
            if (Mmax >= TailleBase)                
                for i=1:TailleBase
                    ModeEspace = HistMfOrth(1:size(VectL,2),i)';
                    PRT(:,i) = ModeEspace /norm(ModeEspace); 
                end
            else
                fprintf('Il y a moins de mode PGD que la taille souhaitee de reduction\n');
                return;
            end
        end

        % On ajoute a la base les "modes" de deplacements imposes
        for j=1:size(D,1)
            for k=1:size(PRT,2)
                if (k<(TailleBase+j))
                    %x = PRT(:,k) - D(j,:)'*(D(j,:)/((norm(D(j,:)))^2) * PRT(:,k))
                    x = PRT(:,k) - (D(j,:)* PRT(:,k)/norm(D(j,:))) * (D(j,:)'/norm(D(j,:)));
                    PRT(:,k) = x/norm(x);
                end
            end
            PRT(:,TailleBase+j)=(D(j,:)/norm(D(j,:)))';
        end
end