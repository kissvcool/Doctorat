function [erreurMaximale,erreurCarre,erreurAmpTotale] = AfficherSolution(Reference,Resultat,NomFigure,VectT,VectL,NoDisplay)

    s(3)=struct('f',[],'a',0);
                                 
    if ~NoDisplay
        figure('Name',NomFigure,'NumberTitle','off')
    end
    for i=1:3
        if (i ==1)
            s(i).f=Reference;
        elseif (i ==2)
            s(i).f=Resultat;
        elseif (i ==3)
            s(i).f= s(1).f - s(2).f;
        end

        s(i).a = max(max(s(i).f)) - min(min(s(i).f));   % amplitude

        if ~NoDisplay
            subplot(2,2,i);

                surf(VectT,VectL,s(i).f,'EdgeColor','none');

                if (s(i).a == 0)
                    axis([0 VectT(end) 0 VectL(end) 0 VectL(end)]);
                else
                    % % disp('m');
                    % % s(i).a 
                    % % min(min(s(i).f))-0.1*s(i).a
                    % % max(max(s(i).f))+0.1*s(i).a
                    axis([0 VectT(end) 0 VectL(end) min(min(s(i).f))-0.1*s(i).a max(max(s(i).f))+0.1*s(i).a]);
                end

                if (i ==1)
                    title(['Solution de Reference, d amplitude ' num2str(s(i).a, '%10.1e\n') ]);
                elseif (i ==2)
                    title(['Resultat, d amplitude ' num2str(s(i).a, '%10.1e\n') ]);
                elseif (i ==3)
                    title(['Difference, d amplitude ' num2str(s(i).a, '%10.1e\n') ' soit ' num2str((s(i).a/s(1).a)*100, '%2.2g\n') '%' ]);
                end
                xlabel('t');
                ylabel('x');
                zlabel('u(x,t)');            
        end
    end

    erreurMaximale = max(max(abs(s(3).f)))/s(1).a;
    DiffAmp = (s(1).a - s(2).a)/s(1).a;
    DiffVol = sum(sum((s(3).f).^2))/sum(sum((s(1).f).^2));
    erreurCarre = abs(DiffVol);
    erreurAmpTotale = abs(DiffAmp);
    
    if ~NoDisplay    
        ax = subplot(2,2,4);
        text(0,0,['Erreur sur l amplitude totale ' num2str(abs(DiffAmp)*100, '%2.2g\n') '%' ]);
        text(0,0.12,['Erreur volume au carre ' num2str(abs(DiffVol)*100, '%2.2g\n') '%' ]);
        set ( ax, 'visible', 'off')
        title(['Erreur sur l amplitude totale ' num2str(abs(DiffAmp/s(1).a)*100, '%2.2g\n') '%' ]);
    end
        
end
