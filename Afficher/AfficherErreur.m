function [] = AfficherErreur(n,nombreNoeuds,Reference,Resultat,VectL)

        figure('Name',['Calcul erreurs sur base reduite a ' num2str(n, '%10.u\n') ' modes'],'NumberTitle','off')

        DiffMax = zeros(1,nombreNoeuds);
        DiffMin = zeros(1,nombreNoeuds);
        DiffAmp = zeros(1,nombreNoeuds);

        for i=1:nombreNoeuds

            amp1 = max(Reference(i,:)) - min(Reference(i,:));
            amp2 = max(Resultat(i,:)) - min(Resultat(i,:));

            if (amp1==0 && amp2==0)
                DiffMax(i) = 0;
                DiffMin(i) = 0;
                DiffAmp(i) = 0;            
            elseif amp1==0          % presence d'un mouvement dans le calcul reduit absent du calcul complet
                DiffMax(i) = -0.5;
                DiffMin(i) = -0.5;
                DiffAmp(i) = -0.5;      
            else
                DiffMax(i) = abs( max(Reference(i,:)) - max(Resultat(i,:)) )/amp1;
                DiffMin(i) = abs( min(Reference(i,:)) - min(Resultat(i,:)) )/amp1;
                DiffAmp(i) = abs( amp1 - amp2 )/amp1;
            end
        end
        maxi = max([max(DiffMax);max(DiffMin);max(DiffAmp)]);
        mini = min([min(DiffMax);min(DiffMin);min(DiffAmp)]);
        plot(VectL,DiffMax,'r',VectL,DiffMin,'g',VectL,DiffAmp,'b');
        axis([0 VectL(end) (mini-0.1*(maxi-mini)) (maxi+0.1*(maxi-mini)) ]);
        legend(['Erreur de valeur Max, max:' num2str((max(DiffMax)*100), '%2.2g\n') '%'],['Erreur de valeur Min, max:' num2str((max(DiffMin)*100), '%2.2g\n') '%'],['Erreur d amplitude, max:' num2str((max(DiffAmp)*100), '%2.2g\n') '%']);
        xlabel('x');
        ylabel('%');