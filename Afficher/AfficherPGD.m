function [erreurMaximale,erreurCarre,erreurAmpTotale] = AfficherPGD(dt,Ttot,VectL,HistMg,HistMf,Reference,NombreResultat,ModesEspaceTemps,ModesEspace,ModesTemps)

% Modes Espace-Temps
if ( NombreResultat > size(HistMg,2))
    disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(NombreResultat) ' Resultats']);
    ErreurPGD;
elseif ( ModesEspaceTemps > size(HistMg,2))
    disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(ModesEspaceTemps) ' Modes Espace-Temps']);
    ErreurPGD;
elseif ( ModesEspace > size(HistMg,2))
    disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(ModesEspace) ' Modes Espace']);
    ErreurPGD;
elseif ( ModesTemps > size(HistMg,2))
    disp(['Il n y a pas assez de Modes PGD calcules pour afficher ' num2str(ModesTemps) ' Modes Temps']);
    ErreurPGD;
end

if ModesEspaceTemps
    figure('Name','modes Espace-Temps par PGD','NumberTitle','off')
        for i=1:ModesEspaceTemps
            Hist = zeros(size(HistMg,1),size(VectL,2));
            for j=1:size(VectL,2)
                for k=1:1:size(HistMg,1)
                    Hist(k,j) =  HistMf(j,i)*HistMg(k,i);
                end
            end
            subplot(ceil(sqrt(ModesEspaceTemps)),ceil(ModesEspaceTemps/ceil(sqrt(ModesEspaceTemps))),i);
                ampli = max(max(Hist)) - min(min(Hist));
                surf(0:dt:Ttot,VectL,Hist','EdgeColor','none');            
                axis([0 Ttot 0 VectL(end) min(min(Hist))-0.1*ampli max(max(Hist))+0.1*ampli]);
                title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
        end
end

if ModesTemps
    % Modes Temps
        figure('Name','modes Temps par PGD','NumberTitle','off')
            for i=1:ModesTemps      
                Hist =  HistMg(:,i);
                subplot(ceil(sqrt(ModesTemps)),ceil(ModesTemps/ceil(sqrt(ModesTemps))),i);
                    ampli = max(Hist) - min(Hist);
                    plot(0:dt:Ttot,Hist');            
                    axis([0 Ttot min(min(Hist))-0.1*ampli max(max(Hist))+0.1*ampli]);
                    title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
            end
end

if ModesEspace
    % Modes Espace
        figure('Name','modes Espace par PGD','NumberTitle','off')
            for i=1:ModesEspace       
                Hist =  HistMf(1:size(VectL,2),i);
                subplot(ceil(sqrt(ModesEspace)),ceil(ModesEspace/ceil(sqrt(ModesEspace))),i);
                    ampli = max(Hist) - min(Hist);
                    plot(VectL,Hist');            
                    axis([0 VectL(end) min(min(Hist))-0.1*ampli max(max(Hist))+0.1*ampli]);
                    title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
            end
end
if NombreResultat
    % Solutions - Comparaison PGD / Resolution complete    
        erreurMaximale  = zeros(1,NombreResultat);
        erreurCarre     = zeros(1,NombreResultat);
        erreurAmpTotale = zeros(1,NombreResultat);
        for n=1:NombreResultat
        
        Resultat  = zeros(size(VectL,2),size(0:dt:Ttot,2));
            f=HistMf(1:size(VectL,2),1:n);
            g=HistMg(:,1:n);
                for j=1:size(VectL,2)
                    for k=1:1:size(0:dt:Ttot,2)
                        for l=1:n
                            Resultat(j,k) = Resultat(j,k) + f(j,l)*g(k,l);
                        end
                    end
                end
                
        NomFigure = ['Calcul sur base reduite par PGD a ' num2str(n, '%10.u\n') ' modes'];
        %VectT
        %VectL
        
        [out1,out2,out3] = AfficherSolution(Reference,Resultat,NomFigure,0:dt:Ttot,VectL);
        erreurMaximale(n)  = out1;
        erreurCarre(n)     = out2;
        erreurAmpTotale(n) = out3;
        
        end
end

    % Indicateurs d erreur
        figure;
        plotyy(1:NombreResultat,log(abs(erreurAmpTotale))/log(10),1:NombreResultat,log(abs(erreurCarre)));
        legend('Log de :Erreur sur l amplitude totale','Log de :Erreur volume au carre');

        figure;
        plotyy(1:NombreResultat,log(abs(erreurAmpTotale))/log(10),1:NombreResultat,log(abs(erreurMaximale)));
        legend('Log de :Erreur sur l amplitude totale','Log de :Erreur Maximale');

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

    % Convergence du point fixe
        for i=1:0 % 1:NombreResultat
            figure('Name',['Norme du couple '  num2str(i) ' dans le point fixe' ],'NumberTitle','off')
            plot(TableConv(i,:))
        end
    
% for cacher Affichage Complet
end