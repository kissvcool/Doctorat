function [] = AfficherAnimation(Reference,Resultat,VectL,L)

    amp1 = max(max(Reference)) - min(min(Reference));
    amp2 = max(max(Resultat)) - min(min(Resultat));

    mini = min(min(Reference))-0.1*amp1;
    maxi = max(max(Reference))+0.1*amp1;
    mini2 = min(min(Resultat))-0.1*amp2;
    maxi2 = max(max(Resultat))+0.1*amp2;
    miniT = min([mini;mini2]);
    maxiT = max([maxi;maxi2]);    

    figure('Name','Animation : onde longitudinale dans la poutre sur base reduite','NumberTitle','off')
    for i=1:size(Reference,2)
        plot(VectL,Reference(:,i),'r',VectL,Resultat(:,i),'b');
        axis([0 L miniT maxiT ]);        
        xlabel('x');
        ylabel('u(x,t)');
        %legend('Reference',['Resultat, avec ' num2str(size(PRT,2)) ' modes']);
        pause(0.02);
    end
    
end

        