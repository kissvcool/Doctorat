function [erreurMaximale,erreurCarre,erreurAmpTotale] = AfficherMethode(dt,Ttot,VectL,Donnees1,Donnees2,Reference,Resultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,D,cas)
%% Verification

    if (Methode == 1) % POD
        if (max(ModesEspaceTemps) > (size(VectL,2) - size(D,1)))
            disp(['Il n y a pas assez de DDL pour calculer ' num2str(max(ModesEspaceTemps)) ' Modes Espace-Temps']);
            ErreurPOD;
        elseif (ModesEspace > (size(VectL,2) - size(D,1)))
            disp(['Il n y a pas assez de DDL pour calculer ' num2str(ModesEspace) ' Modes Espace']);
            ErreurPOD;
            return;
        elseif (ModesTemps > (size(VectL,2) - size(D,1)))
            disp(['Il n y a pas assez de DDL pour calculer ' num2str(ModesTemps) ' Modes Temps']);
            ErreurPOD;
            return;
        end
    elseif  (Methode == 2) % PGD
        HistMf = Donnees1;
        HistMg = Donnees2;
        if ( max(Resultat) > size(HistMg,2))
            disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(NombreResultat) ' Resultats']);
            ErreurPGD;
        elseif ( max(ModesEspaceTemps) > size(HistMg,2))
            disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(max(ModesEspaceTemps)) ' Modes Espace-Temps']);
            ErreurPGD;
        elseif ( ModesEspace > size(HistMg,2))
            disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(ModesEspace) ' Modes Espace']);
            ErreurPGD;
        elseif ( ModesTemps > size(HistMg,2))
            disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(ModesTemps) ' Modes Temps']);
            ErreurPGD;
        end
    end
    
    
%% Initialisation

    if Methode == 1
        [U_SVD,S_SVD,V_SVD]=svd(Donnees1);
    elseif Methode == 2
        
    end

    if Methode == 1
        NomMethode = 'POD';
    elseif Methode == 2
        NomMethode = 'PGD';
    end

%% Affichage des modes
    
    NbModesEspaceTemps = length(ModesEspaceTemps);
    if NbModesEspaceTemps
        figure('Name',['mode Espace-Temps par ' NomMethode],'NumberTitle','off')
            iter=0;
            for i=ModesEspaceTemps
                iter=iter+1;
                subplot(ceil(sqrt(NbModesEspaceTemps)),ceil(NbModesEspaceTemps/ceil(sqrt(NbModesEspaceTemps))),iter);
                    if (Methode == 1) % POD
                        Hist = U_SVD(:,i)*S_SVD(i,i)*V_SVD(:,i)';
                    elseif (Methode == 2) % PGD
                        Hist = zeros(size(HistMg,1),size(VectL,2));
                        for j=1:size(VectL,2)
                            for k=1:1:size(HistMg,1)
                                Hist(k,j) =  HistMf(j,i)*HistMg(k,i);
                            end
                        end
                    end
                    ampli = max(max(Hist)) - min(min(Hist));
                    surf(0:dt:Ttot,VectL,Hist','EdgeColor','none');
                    title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
                    if ampli
                        axis([0 Ttot 0 VectL(end) min(min(Hist))-0.1*ampli max(max(Hist))+0.1*ampli]);
                    else
                        axis([0 Ttot 0 VectL(end) 0 VectL(end)]);
                    end
            end
    end
    
    NbModesEspace = length(ModesEspace);
    if NbModesEspace
        figure('Name',['modes Espace par ' NomMethode],'NumberTitle','off')
            iter=0;
            for i=ModesEspace
                iter=iter+1;
                subplot(ceil(sqrt(NbModesEspace)),ceil(NbModesEspace/ceil(sqrt(NbModesEspace))),iter); 
                    if Methode == 1
                        Hist = S_SVD(i,i)*V_SVD(:,i)';
                    elseif Methode == 2
                        Hist =  HistMf(1:size(VectL,2),i);
                    end                
                    ampli = max(max(Hist)) - min(min(Hist));
                    plot(VectL,Hist');
                    if ampli
                        axis([0 VectL(end) min(Hist)-0.1*ampli max(Hist)+0.1*ampli]);
                    else
                        axis([0 VectL(end) 0 VectL(end)]);
                    end
                    title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
            end
    end

    NbModesTemps = length(ModesTemps);
    if NbModesTemps
        figure('Name',['mode Temps par ' NomMethode],'NumberTitle','off')
            iter=0;
            for i=ModesTemps
                iter=iter+1;
                subplot(ceil(sqrt(NbModesTemps)),ceil(NbModesTemps/ceil(sqrt(NbModesTemps))),iter);            
                    if Methode == 1
                        Hist = U_SVD(:,i)*S_SVD(i,i);                        
                    elseif Methode == 2
                        Hist =  HistMg(:,i);
                    end                
                    ampli = max(max(Hist)) - min(min(Hist));

                    % calcul de frequence                
                        periode = 0;
                        moy = mean(Hist);
                        % on commence en dessous de la moyenne : 
                        if (Hist(1) <= moy)
                            Signal = Hist;
                        else
                            Signal = -Hist;
                            moy = -moy;
                        end
                        compt = 0;
                        top = (1:3)*0;
                        for j=2:size(Signal)
                            if  (compt == 0)  
                                if (Signal(j) > (moy+ampli/4))
                                    compt = 1;
                                    top(1) = j;
                                end
                            elseif (compt == 1)
                                if (Signal(j) < (moy-ampli/4))
                                    compt = 2;
                                    top(2) = j;
                                end
                            elseif (compt == 2)
                                if (Signal(j) > (moy+ampli/4))
                                    top(3) = j;
                                    break
                                end
                            end
                        end
                        if ( top(3) == 0 )
                            if ( top(2) == 0 )
                                % echec car Ttot << periode ou trop amorti
                            else
                                periode = 2* dt* (top(2)-top(1));
                            end
                        else
                            periode = dt* (top(3)-top(1));
                        end

                    plot(0:dt:Ttot,Hist');
                    %plot(0:dt:Ttot,Hist',dt:dt:Ttot,(sin((dt:dt:Ttot)*(2*pi/periode)))*(ampli/2)');
                    if ampli
                        axis([(-5*dt) Ttot min(min(Hist))-0.1*ampli max(max(Hist))+0.1*ampli]);
                    else
                        axis([(-5*dt) Ttot 0 VectL(end)]);
                    end
                    title(['d ordre ' num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ' de periode ' num2str(periode, '%10.2e\n') 's']);
            end
    end

%% Affichage des solutions

    NbResultat = length(Resultat);
    if NbResultat
        % Solutions - Comparaison Methode / Resolution complete    
            erreurMaximale  = zeros(1,NbResultat);
            erreurCarre     = zeros(1,NbResultat);
            erreurAmpTotale = zeros(1,NbResultat);
            iter=0;
            for n=Resultat
                iter= iter+1;
                          
                    if Methode == 1
                        ResultatSol  = (Donnees2(n).p*Donnees2(n).f.HistU) ;
                    elseif Methode == 2               
                        ResultatSol  = zeros(size(VectL,2),size(0:dt:Ttot,2));
                        f=HistMf(1:size(VectL,2),1:n);
                        g=HistMg(:,1:n);
                        for j=1:size(VectL,2)
                            for k=1:1:size(0:dt:Ttot,2)
                                for l=1:n
                                    ResultatSol(j,k) = ResultatSol(j,k) + f(j,l)*g(k,l);
                                end
                            end
                        end                        
                    end 

                NomFigure = ['Calcul sur base reduite par ' NomMethode ' a ' num2str(n, '%10.u\n') ' modes'];
                %VectT
                %VectL

                [out1,out2,out3] = AfficherSolution(Reference,ResultatSol,NomFigure,0:dt:Ttot,VectL,NoDisplayResultat);
                erreurMaximale(iter)  = out1;
                erreurCarre(iter)     = out2;
                erreurAmpTotale(iter)  = out3;

            end
    end
    
%% Affichage de l'erreur

    if (NbResultat && ~NoDisplayErreur)
        NomFigure = ['Erreur / nombre de modes ' NomMethode ' du cas #' num2str(cas, '%10.u\n') ];
        
        figure('Name',NomFigure,'NumberTitle','off')
        plotyy(Resultat,log(abs(erreurAmpTotale))/log(10),Resultat,log(abs(erreurCarre)));
        legend('Log de :Erreur sur l amplitude totale','Log de :Erreur volume au carre');

        figure('Name',NomFigure,'NumberTitle','off')
        plotyy(Resultat,log(abs(erreurAmpTotale))/log(10),Resultat,log(abs(erreurMaximale)));
        legend('Log de :Erreur sur l amplitude totale','Log de :Erreur Maximale');
    end

        % Modification de l'affichage
        % % figure;
            % %    [aaa,bbb,ccc]=plotyy(1:NombreResultat,log(abs(erreurAmpTotale))/log(10),1:NombreResultat,log(abs(erreurMaximale)));
            % % set(ccc,'Color','r');
            % % xlabel('Nombres de modes de la solution PGD')
            % % set(aaa(2),'YColor','r');
            % % set(aaa,'Fontsize',25)
            % % set(ccc,'LineWidth',3);
            % % set(bbb,'LineWidth',3);
            % % set(ccc,'LineStyle','--');

    

end