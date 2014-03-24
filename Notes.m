%% Matlab2tikz

	matlab2tikz( '../Latex/myfile2.tikz' );
	
%% Generer un image

    axis off
    print -dpng matlabout -r400 % PNG called "matlabout.png" with 400 dpi resolution
    
    % Remove the white background of the image, for example using the ImageMagick command
    convert matlabout.png -transparent white 3dcolumnchart.png
    
    % If you would rather use vector PDF output, you'll have to set the paper size
    %   to match the figure size yourself, since the PDF driver doesn't automatically adjust the size:
    
    currentScreenUnits=get(gcf,'Units')     % Get current screen units
    currentPaperUnits=get(gcf,'PaperUnits') % Get current paper units
    set(gcf,'Units',currentPaperUnits)      % Set screen units to paper units
    plotPosition=get(gcf,'Position')        % Get the figure position and size
    set(gcf,'PaperSize',plotPosition(3:4))  % Set the paper size to the figure size
    set(gcf,'Units',currentScreenUnits)     % Restore the screen units
    
    print -dpdf matlabout      % PDF called "matlabout.pdf"
    
%% Save a file     
    fichier = ['Resultats.' num2str(program+1) '.schem.' num2str(schem) '.Kmax.' num2str(Kmax) '.Mmax.' num2str(Mmax) '.mat' ];
    save(fichier);
    exit;
    return;
    
%% Quelque traces    
    NomFigure = ['Erreur / nombre de modes PGD du cas #' num2str(cas, '%10.u\n') ];
    figure('Name',NomFigure,'NumberTitle','off')
    Resultat = 1:Mmax;
            plot(Resultat,log(abs(ErrAmpTotalePGD))/log(10),Resultat,log(abs(ErrMaxPGD))/log(10));
            legend('Log de :Erreur sur l amplitude totale','Log de :Erreur volume au carre');
    
    
    
    NomFigure = ['Erreur / nombre de modes POD du cas #' num2str(cas, '%10.u\n') ];
    figure('Name',NomFigure,'NumberTitle','off')
    Resultat = VectN;
            plot(Resultat,log(abs(ErrAmpTotalePOD))/log(10),Resultat,log(abs(ErrMaxPOD))/log(10));
            legend('Log de :Erreur sur l amplitude totale','Log de :Erreur volume au carre');

