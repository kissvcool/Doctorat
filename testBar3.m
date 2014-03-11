NbModesMethode2=NbModesPGD;
ModeMethode2=ModePGD;
        MAC = zeros(NbModesMethode2,NbModesMethode2);
            
        for i=1:NbModesMethode2
                modeI = ModeMethode2(i,:);

            for j=1:NbModesMethode2
                modeJ = ModeMethode2(j,:);
                MAC(i,j)= (modeI*modeJ')^2 / ( (modeI*modeI')*(modeJ*modeJ') );
            end
        end

        if norm(MAC)
                close all;
                figure('Name','Analyse MAC entre les modes obtenus par PGD','NumberTitle','off')
            
            h=bar3(MAC);
            
            for n=1:numel(h)
                 cdata=get(h(n),'zdata');
                 cdata=repmat(max(cdata,[],2),1,4);
                 set(h(n),'cdata',cdata,'facecolor','flat')
            end
            set(gcf,'PaperPositionMode','auto')
            %matlab2tikz( '../Latex/myfile2.tikz' );
        end
        
       return; 