function [erreurCarre, erreurAmpTotale] = AfficherSolutionDifferenteDiscretisation(Reference,Resultat,NomFigure,VectT,VectL,VectTR,VectLR)

    s(3)=struct('f',[],'a',0);
    
    figure('Name',NomFigure,'NumberTitle','off')
        for i=1:3
            if (i ==1)
                s(i).f=Reference;
            elseif (i ==2) 
                if (size(VectLR,2) == size(VectL,2))  %Modele reduit
                    disp('A');     
                    s(i).f=Resultat;
                elseif (size(VectT,2) == size(VectTR,2))
                    disp('D');
                    s(i).f = zeros(size(s(1).f));
                    for j=1:size(VectL,2)
                        MemeCompos = 0;
                            for l=1:size(VectLR,2)
                                if (VectL(j) == VectLR(l))
                                    s(i).f(j,:)=Resultat(l,:);
                                    MemeCompos = 1;
                                    break;
                                end
                            end
                        if (MemeCompos==0)
                            for l=1:size(VectLR,2)
                                if (VectLR(l) > VectL(j))
                                    
                                    C1 =     (VectLR(l)  - VectL(j)) / ( VectLR(l) - VectLR(l-1) );
                                    C2 = - ((VectLR(l-1) - VectL(j)) / ( VectLR(l) - VectLR(l-1) ));
                                    
                                    for t=1:size(VectT,2)
                                        s(i).f(j,t)= C2*Resultat(l,t) + C1*Resultat(l-1,t);
                                    end
                                    
                                    break;
                                end
                            end
                        end
                    end
                        
                end
                
                if (size(VectT,2) == size(VectTR,2))                        
                    disp('B');
                elseif (size(VectLR,2) == size(VectL,2))
                    disp('C');
                    for j=1:size(VectT,2)
                        MemeCompos = 0;
                            for l=1:size(VectTR,2)
                                if (VectT(j) == VectTR(l))
                                    s(i).f(:,j)=sortie(n).f.HistU(:,l);
                                    MemeCompos = 1;
                                    break;
                                end
                            end
                        if (MemeCompos==0)
                            for l=1:size(VectTR,2)
                                if (VectTR(l) > VectT(j))
                                    C1 =    ( VectTR(l)  - VectT(j) )/ ( VectTR(l) - VectTR(l-1) );
                                    C2 = - ((VectTR(l-1) - VectT(j) )/ ( VectTR(l) - VectTR(l-1) ));
                                    for x=1:size(VectL,2)
                                        s(i).f(x,j)= C2*sortie(n).f.HistU(x,l) + C1*sortie(n).f.HistU(x,l-1);
                                    end
                                    break;
                                end
                            end
                        end
                    end
                end
            elseif (i ==3)
                s(i).f= s(1).f - s(2).f;
            end

            s(i).a = max(max(s(i).f)) - min(min(s(i).f));   % amplitude
            if (s(i).a ==0)
                s(i).a = s(i-1).a /100;
            end

            subplot(2,2,i);
            surf(VectT,VectL,s(i).f,'EdgeColor','none');

            axis([0 VectT(end) 0 VectL(end) min(min(s(i).f))-0.1*s(i).a max(max(s(i).f))+0.1*s(i).a]);
            
            s(i).a = max(max(s(i).f)) - min(min(s(i).f));
            
%             if (i ==1)
%                 title(['Resolution sur ' num2str(nombreElements, '%10.u\n') ' elements, amplitude =' num2str(s(i).a, '%10.1e\n') ]);
%             elseif (i ==2)
%                 nombreElementsParPartie2=5  *2^(n-1);
%                 nombreElements2 = nombrePartie*nombreElementsParPartie2;
%                 title(['Resolution sur ' num2str(nombreElements2, '%10.u\n') ' elements, amplitude =' num2str(s(i).a, '%10.1e\n') ]);
%             elseif (i ==3)
%                 title(['Difference d amplitude PGD ' num2str(s(i).a, '%10.1e\n') ' soit ' num2str((s(i).a/s(1).a)*100, '%2.2g\n') '%' ]);
%             end

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
        
        DiffAmp = (s(1).a - s(2).a)/s(1).a;
        %spy();
        ax = subplot(2,2,4);
        text(0,0,['Erreur sur l amplitude totale ' num2str(abs(DiffAmp)*100, '%2.2g\n') '%' ]);
        DiffVol = sum(sum((s(3).f).^2))/sum(sum((s(1).f).^2));
        text(0,0.12,['Erreur volume au carre ' num2str(abs(DiffVol)*100, '%2.2g\n') '%' ]);
        set ( ax, 'visible', 'off');
        erreurCarre = abs(DiffVol);
        title(['Erreur sur l amplitude totale ' num2str(abs(DiffAmp/s(1).a)*100, '%2.2g\n') '%' ]);
        erreurAmpTotale = abs(DiffAmp/s(1).a);
end