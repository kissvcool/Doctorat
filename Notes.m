fichier = ['Resultats.' num2str(program+1) '.schem.' num2str(schem) '.Kmax.' num2str(Kmax) '.Mmax.' num2str(Mmax) '.mat' ];
save(fichier);
exit;
return;


NomFigure = ['Erreur / nombre de modes PGD du cas #' num2str(cas, '%10.u\n') ];
figure('Name',NomFigure,'NumberTitle','off')
Resultat = 1:Mmax;
        plot(Resultat,log(abs(ErrAmpTotalePGD))/log(10),Resultat,log(abs(ErrMaxPGD))/log(10));
        legend('Log de :Erreur sur l amplitude totale','Log de :Erreur volume au carre');



NomFigure = ['Erreur / nombre de modes PGD du cas #' num2str(cas, '%10.u\n') ];
figure('Name',NomFigure,'NumberTitle','off')
Resultat = VectN;
        plot(Resultat,log(abs(ErrAmpTotalePOD))/log(10),Resultat,log(abs(ErrMaxPOD))/log(10));
        legend('Log de :Erreur sur l amplitude totale','Log de :Erreur volume au carre');


