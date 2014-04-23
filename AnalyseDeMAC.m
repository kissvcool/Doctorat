function AnalyseDeMAC(NbModesMethode1,NbModesMethode2,ModeMethode1,ModeMethode2)

    for k=1:3    %1:3
        
        if ( k == 1 )
            MAC = zeros(NbModesMethode1,NbModesMethode1);
        elseif (k == 2 )
            MAC = zeros(NbModesMethode1,NbModesMethode2);
        elseif (k == 3 )
            MAC = zeros(NbModesMethode2,NbModesMethode2);
        end
            
        for i=1:(max(NbModesMethode1,NbModesMethode2))
            if ( k == 1  )
                if i > NbModesMethode1
                    break;
                end
                modeI = ModeMethode1(i,:);
            elseif (k == 2 )
                if i > NbModesMethode1
                    break;
                end
                modeI = ModeMethode1(i,:);
            elseif (k == 3 )
                if i > NbModesMethode2
                    break;
                end
                modeI = ModeMethode2(i,:);
            end

            for j=1:(max(NbModesMethode1,NbModesMethode2))
                if ( k == 1 )
                    if j > NbModesMethode1
                        break;
                    end
                    modeJ = ModeMethode1(j,:);
                elseif (k == 2 )
                    if j > NbModesMethode2
                        break;
                    end
                    modeJ = ModeMethode2(j,:);
                elseif (k == 3 )
                    if j > NbModesMethode2
                        break;
                    end
                    modeJ = ModeMethode2(j,:);
                end
                MAC(i,j)= (modeI*modeJ')^2 / ( (modeI*modeI')*(modeJ*modeJ') );
            end
        end

        if norm(MAC)
            if ( k == 1 )
                figure('Name','Analyse MAC des modes obtenus par POD','NumberTitle','off')
            elseif (k == 2 )
                figure('Name','Analyse MAC entre les modes obtenus par POD et PGD','NumberTitle','off')
            elseif (k == 3 )
                close all;
                figure('Name','Analyse MAC entre les modes obtenus par PGD','NumberTitle','off')
            end
            
            h=bar3(MAC);
            
            for n=1:numel(h)
                 cdata=get(h(n),'zdata');
                 cdata=repmat(max(cdata,[],2),1,4);
                 set(h(n),'cdata',cdata,'facecolor','flat')
            end
            
            for l=1:0 %Creation du fichier pour histogramme 3D tikz
                fileID = fopen('../Latex/Tikz/TentativesHist3D/DataOutMac.dat','w');
                MaxMAC = max(MAC(:));
                fprintf(fileID,'X \t\t Y \t\t Z \n');
                %Maximums
                fprintf(fileID,['' num2str(size(MAC,1)) ' \t\t ' num2str(size(MAC,2)) ' \t\t ' num2str(MaxMAC) ' \t\t %% max \n \n']);
                for i=1:size(MAC,1)
                    for j=size(MAC,2):-1:1
                        if MAC(i,j)>(MaxMAC/10000)
                            fprintf(fileID,['' num2str(i) ' \t\t ' num2str(j) ' \t\t%12.8f \n'], MAC(i,j));%'%12.8f\n'], MAC(i,j));
                        end
                    end
                end
                fclose(fileID);
            end

        end
    end
    
end