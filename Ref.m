%% Probleme de reference

%% Warnings

% Utiliser "ceil" peut entrainer des erreur en arrondissansant 1000 a 1001.
%   Ici j'utilise "round" mais s'il vient a poser probleme lui aussi
%   choisir Ttot/dt entier.

% La correction des deplacements imposes n'est possible que si il ne sont
%   pas lies. !! Les deplacements imposes en PGD ne sont pas non plus
%   possibles si il y a plus d'une composante non nulle par ligne de D

% Les non-linearite ne sont pas traite automatiquement car il faut
%   re-appliquer les CL. impossible avec substitution pour l'instant.

w = warning ('off','all');
% w = warning ('on','all');

addpath('Afficher','POD','PGD','Matlab2Tikz')

clear all
clc
diary FichierLog

IterProgram=10;

sortie(IterProgram)=struct('f',[],'a',0,'p',[]);

for program=0:(IterProgram-1)
    
    % clearvars -except program IterProgram ;
    % program
    
%% Parametres
    for cacher = 1
        L = 0.5;            % 0.5 m^2
        Egene = (210*10^9); % 210 GPa
        ENonConstant=0;
        ecart = 0.5;        % max( (Egene-E)/Egene )
        Sec=10^(-4);        % 10^-4 m^2 = 1 cm^2
        rho=7.8*10^3;       % kg/m^3
        AmpliF=100;         % N

    % Ressort
        % Lres = L/8;
        % kres = Egene*Sec/Lres;
        Lres = 0;
        kres = 0;
        nonLine = 0; %1;

    % elements
        nombreElementsParPartie=80; %5  *2^program;
        nombrePartie=2  ;
        nombreElements = nombrePartie*nombreElementsParPartie;               
        nombreNoeuds = nombreElements + 2;  % avec le noeud derriere le ressort
        LElement = L/nombreElements;
        disp(['nombreElementsParPartie = ' num2str(nombreElementsParPartie)]);

    % temps
        dt=  4e-6;%*2^-program ; %*0.5^program;
        Ttot= 1.0e-03;% * 5^program;% dt*400; %3.0000e-04;

        c=(Egene/rho)^(0.5);
        NbOscil=Ttot/(2*L/c);          % correct si E constant / recalcule plus loin
        nombrePasTemps=round(Ttot/dt); % Attention doit etre entier car ceil pose des problemes
        VectT=0:dt:Ttot;

    % probleme :
        cas = 8;
        disp(['cas = ' num2str(cas)]);
        % 1 Deformee de depart correspondant a un effort en bout de poutre puis relachee
        % 2 Effort sinusoidal en bout de poutre
        % 3 Deplacement impose en milieu de poutre
        % 4 Effort continue en bout de poutre
        % 5 Effort augmentant lineairement en bout de poutre
        % 6 Effort continue en bout de poutre les 50 premiers pas de temps
            NbPas6 = round(2e-4/dt);
        % 7 Vitesse initiale
        % 8 Une periode de sinusverse
            %T8=10*dt*2^program; % 10*dt < T < Ttot/4   
            T8=dt*(10+5*program);

    % schema d integration :
        schem = 3;
        disp(['schem = ' num2str(schem)]);
        alpha=-1/3;    % -1/3 <= alpha <= 0 
        % 1 Newmark - Difference centree
        % 2 Newmark - Acceleration lineaire
        % 3 Newmark - Acceleration moyenne
        % 4 Newmark - Acceleration moyenne modifiee
        % 5 HHT-alpha
        % 6 Galerkin Discontinu

    % Application des conditions limites :
        CL=1;
        disp(['CL = ' num2str(CL)]);
        % 1 Multiplicateur de Lagrange
        % 2 Substitution

        if (CL==1)
            VectL=[0:L/nombreElements:L L+Lres];
        elseif (CL==2)
            VectL=L/nombreElements:L/nombreElements:L;
        end
        
        if (schem==6)
            CL=2;
        end

    % Matrice de Masse :
        RepartMasse = 3;
        % 1 Me= [1/2  0 ;  0  1/2]  la masse est repartie equitablement entre les deux
        % 2 Me= [ 0   0 ;  0   1 ]  la masse est donnee au noeud a la droite de l'element
        % 3 Me= [1/3 1/6; 1/6 1/3]  la masse est repartie comme le decrivent les fonctions EF
    end

%% Matrices

    [nonLinearite,M,K0,C] = ConstructionMatrices(nombreElements,nombreNoeuds,LElement,Sec,rho,Egene,ENonConstant,Ttot,RepartMasse,nonLine);

%% Conditions limites

    [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0,verif] = CondiLimit(CL,M,C,K0,L,nombreElements,cas,nombrePasTemps,dt,Ttot,AmpliF,NbPas6,T8);

%% Resolution Temporelle

    tic;
    sortie(1).f =resolutionTemporelle(schem,alpha,M,C,K0,dt,Ttot,HistF,U0,V0,conditionU,conditionV,conditionA,D,nonLine,nonLinearite,verif);
    Tcalcul=toc;
    disp(['Estimation du temps de calcul sur base complete ' num2str(Tcalcul, '%10.1e\n') 's']);
    
%     figure('Name',['Calcul de choc schem ' num2str(schem) ],'NumberTitle','off')
%      surf(0:dt:Ttot,VectL,sortie(1).f.HistU,'EdgeColor','none');
%      plot(0:dt:Ttot,sortie(1).f.HistU(40,:),0:dt:Ttot,sortie(1).f.HistU(end-1,:),'r',0:dt:Ttot,(HistF(end-1,:)/(2*AmpliF))*max(sortie(1).f.HistU(end-1,:)),'LineWidth',2);
%      chainetitre=['Schema Newmark - Acceleration moyenne, T=' num2str(T8, '%10.1e\n') ', dt=' num2str(dt, '%10.1e\n')];
%     title(chainetitre);  
%         set(gca, 'FontSize', 20);
%         
%         matlab2tikz( ['../Latex/CalculSchem3.T1.dt' num2str(dt) '.tikz'] );
     
% end
% return;
% 
% for i=0:1

%     figure('Name','Difference entre U_m et U_p','NumberTitle','off')
%      surf(0:dt:Ttot,VectL,(sortie(1).f.HistU_m - sortie(1).f.HistU_p),'EdgeColor','none');
%         return;
        

%% Solution Exacte

    % Sans ressort - Cas 4, 5 et 6
    [HistUExact,HistVExact,HistAExact] = SolutionExacte(cas,c,AmpliF,Egene,Sec,L,VectL,VectT,dt,NbPas6);

                      %% Reduction du modele %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VectN = 1:1;%(size(M,1)-size(D,1));
reduc = 1;
% 1 POD
% 2 Rayleigh
% 3 PGD
for n = VectN  % taille de la base modale
    %% Creation de la base reduite d une matrice de passage

        
        [PRT] = BaseReduite (reduc,n,M,K0,D,conditionU,VectL,sortie(1).f.HistU');
        sortie(1+n).p = PRT;

    %% Projection

        [MR,CR,K0R,U0R,V0R,DR,HistFR,nonLineariteR,PresenceNan] = Projection(PRT,M,C,K0,U0,V0,D,HistF,nonLine,nonLinearite);
        if PresenceNan           
            break;
        end
        
    %% Resolution Temporelle sur base Reduite

        tic;
        Ttot;
        sortie(1+n).f=resolutionTemporelle(schem,alpha,MR,CR,K0R,dt,Ttot,HistFR,U0R,V0R,conditionU,conditionV,conditionA,DR,nonLine,nonLineariteR,verif);
        Tcalcul= toc;
        disp(['Estimation du temps de calcul sur base reduite ' num2str(Tcalcul, '%10.1e\n') 's']);
end

if (n~=VectN(end))
            n=n-1;
            disp(['Arret des resolution POD au mode= ' num2str(n) ' sur ' num2str(VectN(end))]);
            VectN=1:n;
end

    
%% Animation
    for i=1:0%VectN % Animation
        Reference1 = sortie(1).f.HistV;
        Reference2 = HistVExact;
        Resultat = sortie(1+i).p*sortie(1+i).f.HistV;

        AfficherAnimation(Reference1,Reference2,Resultat,VectL,L);
    end
        
%% Affichage Complet

    Reference = sortie(1).f.HistU;
    ModesEspaceTemps = [];
    ModesEspace = [];
    ModesTemps = [];
    Resultat = VectN;
    NoDisplayResultat = 1;
    NoDisplayErreur = 1;
    Methode = 1; % POD

    [ErrMaxPOD,ErrCarrePOD,ErrAmpTotalePOD] = AfficherMethode(dt,Ttot,VectL,sortie(1).f.HistU',sortie(:),Reference,Resultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,D,cas);
    

                            %% PGD %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for PGD = 1
    %% Algorithme

        % Fonction f(X), g(t) %, h(theta)

        OthoIntern = 0;

        Mmax=15;        % Nombre de modes maximum
        Kmax=10;        % Nombre d'iterations max pour obtenir un mode
        epsilon = 10^-6;

        [HistMf,HistMg,HistMgp,HistMgpp,HistTotf,HistTotg,HistTotgp,HistTotgpp,TableConv,Mmax] = CalcModesPGD(Mmax,Kmax,M, C, K0, HistF, U0, V0, D, conditionU, OthoIntern,VectL,epsilon,Ttot,dt,verif,schem);


    %% Affichage Complet

        Reference = sortie(1).f.HistU;
        ModesEspaceTemps = [];
        ModesEspace = [];
        ModesTemps = [];
        Resultat = 1:Mmax;
        NoDisplayResultat = 1;
        NoDisplayErreur = 0;
        Methode = 2; % PGD

        chainetitre = ['T=' num2str(T8) ];
        
        % AfficherPGD(dt,Ttot,VectL,HistMf(1:size(VectL,2),:),HistMg,Reference,NombreResultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat);
            [ErrMaxPGD,ErrCarrePGD,ErrAmpTotalePGD] = AfficherMethode(dt,Ttot,VectL,HistMf(1:size(VectL,2),:),HistMg,Reference,Resultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,D,cas,chainetitre);

     
        % Convergence du point fixe
            for i=1:0 % 1:NombreResultat
                figure('Name',['Norme du couple '  num2str(i) ' dans le point fixe' ],'NumberTitle','off')
                plot(TableConv(i,:))
            end

    %% Animation
    
        for i=1:0%Mmax
            Reference1 = sortie(1).f.HistU;
            Reference2 = HistUExact;
            Resultat  = zeros(size(VectL,2),size(0:dt:Ttot,2));
                f=HistMf(1:size(VectL,2),1:i);
                g=HistMg(:,1:i);
                for j=1:size(VectL,2)
                    for k=1:1:size(0:dt:Ttot,2)
                        for l=1:i
                            Resultat(j,k) = Resultat(j,k) + f(j,l)*g(k,l);
                        end
                    end
                end

            AfficherAnimation(Reference1,Reference2,Resultat,VectL,L);
        end
    

end
             

% for program=
end 
return;
                        %% Analyse des modes %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    ModePOD = (sortie(1+n).p)';
    NbModesPOD= size(ModePOD,1);
    NbModesPGD = Mmax;
    ModePGD=zeros(NbModesPGD,size(VectL,2));
    
    for i=1:NbModesPGD
        ModePGD(i,:) = HistMf(1:size(VectL,2),i)';
    end
    
    AnalyseDeMAC(NbModesPOD,NbModesPGD,ModePOD,ModePGD);

    
    % fichier = ['Resultats' num2str(program+1)];
    % save(fichier);




                          %% Solutions EF %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cacher=1:0
    erreurCarre=zeros(IterProgram,1);
    erreurAmpTotale=zeros(IterProgram,1);
% Il faut placer :
    % TablVectT{program+1}=0:dt:Ttot;
% et 
    % TablVectL{program+1}=[0:L/nombreElements:L L+Lres];
% dans la boucle du programme
    
    VectL = TablVectL{IterProgram};
    VectT = TablVectT{IterProgram};
    Reference = sortie(IterProgram).f.HistU ;    

    for i=1:0 %:IterProgram %nombre de calcul EF a afficher
        Resultat  = sortie(i).f.HistU ;
        NomFigure = ['Calcul sur modele EF a ' num2str(i, '%10.u\n') ' modes'];
        VectLR = TablVectL{i};
        VectTR = TablVectT{i};
        NoDisplayResultat = 0;
        
        [erreurCarre(i),erreurAmpTotale(i)] = AfficherSolutionDifferenteDiscretisation(Reference,Resultat,NomFigure,VectT,VectL,VectTR,VectLR,NoDisplayResultat);
    end
end


    



