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

addpath('Afficher','POD','PGD')

clear all
clc

IterProgram=1;

sortie(2*IterProgram)=struct('f',[],'a',0,'p',[]);

for program=0:(IterProgram-1)
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
        Lres = L/8;
        kres = Egene*Sec/Lres;
        nonLine = 0; %1;

    % elements
        nombreElementsParPartie=2; %5  *2^program;
        nombrePartie=2  ;
        nombreElements = nombrePartie*nombreElementsParPartie;               
        nombreNoeuds = nombreElements + 2;  % avec le noeud derriere le ressort
        LElement = L/nombreElements;

    % temps
        dt=  1e-6 ; %*0.5^program;
        Ttot= 1.0e-03;% * 5^program;% dt*400; %3.0000e-04;

        c=(Egene/rho)^(0.5);
        NbOscil=Ttot/(2*L/c);          % correct si E constant / recalcule plus loin
        nombrePasTemps=round(Ttot/dt); % Attention doit etre entier car ceil pose des problemes

    % probleme :
        cas = 4;
        % 1 Deformee de depart correspondant a un effort en bout de poutre puis relachee
        % 2 Effort sinusoidal en bout de poutre
        % 3 Deplacement impose en milieu de poutre
        % 4 Effort continue en bout de poutre
        % 5 Effort augmentant lineairement en bout de poutre
        % 6 Effort continue en bout de poutre les 50 premiers pas de temps

    % schema d integration :
        schem = 1;
        % 1 Newmark - Difference centree
        % 2 Newmark - Acceleration lineaire
        % 3 Newmark - Acceleration moyenne
        % 4 Newmark - Acceleration moyenne modifiee
        % 5 HHT-alpha

    % Application des conditions limites :
        CL=1;
        % 1 Multiplicateur de Lagrange
        % 2 Substitution

        if (CL==1)
            VectL=[0:L/nombreElements:L L+Lres];
        elseif (CL==2)
            VectL=L/nombreElements:L/nombreElements:L;
        end

    % Matrice de Masse :
        RepartMasse = 2;
        % 1 Me= [1/2  0 ;  0  1/2]  la masse est repartie equitablement entre les deux
        % 2 Me= [ 0   0 ;  0   1 ]  la masse est donnee au noeud a la droite de l'element
        % 3 Me= [1/3 1/6; 1/6 1/3]  la masse est repartie comme le decrivent les fonctions EF
    end

%% Matrices

    [nonLinearite,M,K0,C] = ConstructionMatrices(nombreElements,nombreNoeuds,LElement,Sec,rho,Egene,ENonConstant,Ttot,RepartMasse,nonLine);

%% Conditions limites

    [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0] = CondiLimit(CL,M,C,K0,L,nombreElements,cas,nombrePasTemps,dt,Ttot,AmpliF);

%% Resolution Temporelle

    tic;
    sortie(program+1).f =resolutionTemporelle(schem,M,C,K0,dt,Ttot,HistF,U0,V0,conditionU,conditionV,conditionA,D,nonLine,nonLinearite);
    Tcalcul=toc;
    disp(['Estimation du temps de calcul sur base complete ' num2str(Tcalcul, '%10.1e\n') 's']);
    
    % figure('Name','Calcul sur base complete','NumberTitle','off')
    %  s(1).a = max(max(sortie(program+1).f.HistU)) - min(min(sortie(program+1).f.HistU));   % amplitude
    %  surf(0:dt:Ttot,VectL,sortie(program+1).f.HistU,'EdgeColor','none');
        
                 
                      %% Reduction du modele %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for n = 1:3  % taille de la base modale
    %% Creation de la base reduite d une matrice de passage

        reduc = 1;
        % 1 POD
        % 2 Rayleigh
        % 3 PGD

        [PRT] = BaseReduite (reduc,n,nombreNoeuds,M,K0,D,conditionU,VectL,sortie(1).f.HistU');
        sortie(program+IterProgram+n).p = PRT;

    %% Projection

        [MR,CR,K0R,U0R,V0R,DR,HistFR,nonLineariteR] = Projection(PRT,M,C,K0,U0,V0,D,HistF,nonLine,nonLinearite);

    %% Resolution Temporelle sur base Reduite

        tic;
        Ttot;
        sortie(program+IterProgram+n).f=resolutionTemporelle(schem,MR,CR,K0R,dt,Ttot,HistFR,U0R,V0R,conditionU,conditionV,conditionA,DR,nonLine,nonLineariteR);
        Tcalcul= toc;
        disp(['Estimation du temps de calcul sur base reduite ' num2str(Tcalcul, '%10.1e\n') 's']);
end
    
%% Animation
    
    % Reference = sortie(1).f.HistU;
    % Resultat = sortie(program+IterProgram+1).p*sortie(IterProgram+1).f.HistU;
    % 
    % AfficherAnimation(Reference,Resultat,VectL,L);
    
%% Affichage Complet

    Reference = sortie(program+1).f.HistU;
    ModesEspaceTemps = 0;
    ModesEspace = 0;
    ModesTemps = 0;
    NombreResultat = 0; %n;
    NoDisplayResultat = 1;
    NoDisplayErreur = 1;
    Methode = 1; % POD

    AfficherMethode(dt,Ttot,VectL,sortie(1).f.HistU',sortie(program+IterProgram+(1:n)),Reference,NombreResultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,D,cas);

% return;
                            %% PGD %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for PGD = 1
    %% Algorithme

    % Fonction f(X), g(t) %, h(theta)

    OthoIntern = 0;

    Mmax=10;        % Nombre de modes maximum
    Kmax=40;        % Nombre d'iterations max pour obtenir un mode
    epsilon = 10^-6;

    [HistMf,HistMg,HistTotf,HistTotg,HistTotgp,HistTotgpp,TableConv] = CalcModesPGD(Mmax,Kmax,M, C, K0, HistF, U0, V0, D, conditionU, OthoIntern,VectL,epsilon,Ttot, dt);

    %% Affichage Complet

        Reference = sortie(program+1).f.HistU;
        ModesEspaceTemps = 0;
        ModesEspace = 0;
        ModesTemps = 0;
        NombreResultat = Mmax;
        NoDisplayResultat = 0;
        NoDisplayErreur = 0;
        Methode = 2; % PGD

        % AfficherPGD(dt,Ttot,VectL,HistMf(1:size(VectL,2),:),HistMg,Reference,NombreResultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat);
            AfficherMethode(dt,Ttot,VectL,HistMf(1:size(VectL,2),:),HistMg,Reference,NombreResultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,D,cas);

        % Convergence du point fixe
            for i=1:0 % 1:NombreResultat
                figure('Name',['Norme du couple '  num2str(i) ' dans le point fixe' ],'NumberTitle','off')
                plot(TableConv(i,:))
            end

end 

% for program=
end 


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
                                 
        %Reference
        Resultat  = sortie(i).f.HistU ;
        NomFigure = ['Calcul sur modele EF a ' num2str(i, '%10.u\n') ' modes'];
        VectLR = TablVectL{i};
        VectTR = TablVectT{i};
        NoDisplayResultat = 0;
        
        [erreurCarre(i),erreurAmpTotale(i)] = AfficherSolutionDifferenteDiscretisation(Reference,Resultat,NomFigure,VectT,VectL,VectTR,VectLR,NoDisplayResultat);
        
    end
end

                        %% Analyse des modes %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cacher = 1:0    
    [U_SVD,S_SVD,V_SVD]=svd(sortie(program+1).f.HistU');
    NbModesPOD = (size(VectL,2) - size(D,1));
    NbModesPGD = Mmax;
    ModePOD=zeros(NbModesPOD,size(VectL,2));
    ModePGD=zeros(NbModesPGD,size(VectL,2));
    
    for i=1:NbModesPOD
        ModePOD(i,:) = S_SVD(i,i)*V_SVD(:,i)';
    end
    for i=1:NbModesPGD
        ModePGD(i,:) = HistMf(1:size(VectL,2),i)';
    end
    
    AnalyseDeMAC(NbModesPOD,NbModesPGD,ModePOD,ModePGD);
end

    



