function [] = AfficherAnimation(Reference1,Reference2,Resultat,VectL,L)

    amp1 = max(max(Reference1)) - min(min(Reference1));
    amp2 = max(max(Resultat)) - min(min(Resultat));

    mini = min(min(Reference1))-0.1*amp1;
    maxi = max(max(Reference1))+0.1*amp1;
    mini2 = min(min(Resultat))-0.1*amp2;
    maxi2 = max(max(Resultat))+0.1*amp2;
    miniT = min([mini;mini2]);
    maxiT = max([maxi;maxi2]);    
    
    figure('Name','Animation : onde longitudinale dans la poutre sur base reduite','NumberTitle','off')
    for i=1:size(Reference1,2)
        if isempty(Reference2)
            plot(VectL,Reference1(:,i),'r',VectL,Resultat(:,i),'b');
        else
            plot(VectL,Reference1(:,i),'r',VectL,Reference2(:,i),'k',VectL,Resultat(:,i),'b');
        end
        axis([0 L miniT maxiT ]);        
        xlabel('x');
        ylabel('u(x,t)');
        %legend('Reference',['Resultat, avec ' num2str(size(PRT,2)) ' modes']);
        pause(0.02);
    end
    
end

        