function [U_SVD,S_SVD,V_SVD] = AfficherPOD(Donnees,dt,Ttot,VectL,D,cas,ModesEspaceTemps,ModesEspace,ModesTemps)

[U_SVD,S_SVD,V_SVD]=svd(Donnees);

if (ModesEspaceTemps > (size(VectL,2) - size(D,1)))
    disp(['Il n y a pas assez de DDL pour calculer ' num2str(ModesEspaceTemps) ' Modes Espace-Temps']);
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

% % Val = svd(sortie.HistU');  % eviter de refaire SVD Quand la matrice est grande

% % figure('Name','Valeurs singulieres','NumberTitle','off')
% %     semilogy(Val);

% % % SVD Tronquee
% % figure('Name','SVD Tronquee','NumberTitle','off')
% %     for i=1:4
% %         subplot(2,2,i);
% %             Hist = U_SVD(:,1:i)*S_SVD(1:i,1:i)*V_SVD(:,1:i)';
% %             surf(0:dt:Ttot,VectL,Hist','EdgeColor','none');
% %             title(['a l ordre '  num2str(i) ]);
% % 
% %     end


% Modes Espace-Temps
if ModesEspaceTemps
figure('Name','mode Espace-Temps par POD','NumberTitle','off')
    for i=1:ModesEspaceTemps
        subplot(ceil(sqrt(ModesEspaceTemps)),ceil(ModesEspaceTemps/ceil(sqrt(ModesEspaceTemps))),i);
            Hist = U_SVD(:,i)*S_SVD(i,i)*V_SVD(:,i)';
            ampli = max(max(Hist)) - min(min(Hist));
            surf(0:dt:Ttot,VectL,Hist','EdgeColor','none');
            title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
            axis([0 Ttot 0 VectL(end) min(min(Hist))-0.1*ampli max(max(Hist))+0.1*ampli]);
    end
end

% Mode Espace
if ModesEspace
figure('Name',['mode Espace par POD probleme ' num2str(cas, '%10.u\n') ],'NumberTitle','off')
    for i=1:ModesEspace
        subplot(ceil(sqrt(ModesEspace)),ceil(ModesEspace/ceil(sqrt(ModesEspace))),i);
            Hist = S_SVD(i,i)*V_SVD(:,i)';
            ampli = max(max(Hist)) - min(min(Hist));
            plot(VectL,Hist');
            axis([0 VectL(end) min(Hist)-0.2*abs(min(Hist)) max(Hist)+0.2*abs(max(Hist))]);
            title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ]);
    end
end

% Mode Temps
if ModesTemps
figure('Name','mode Temps par POD ','NumberTitle','off')
    for i=1:ModesTemps
        subplot(ceil(sqrt(ModesTemps)),ceil(ModesTemps/ceil(sqrt(ModesTemps))),i);
            Hist = U_SVD(:,i)*S_SVD(i,i);
            ampli = max(max(Hist)) - min(min(Hist));
            
            % calcul de frequence                
                periode = 0;
                moy = mean(Hist);
                % on commence en dessous de la moyenne : 
                if (Hist(1) <= moy)
                    Signal = Hist;
                else
                    Signal = -Hist;
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
            axis([(-5*dt) Ttot min(Hist)-0.2*abs(min(Hist)) max(Hist)+0.2*abs(max(Hist))]);
            title(['d ordre '  num2str(i) ' d amplitude ' num2str(ampli, '%10.1e\n') ' de periode ' num2str(periode, '%10.2e\n') 's']);
    end
end

end