clear all;
clc;
clf;

% Image originale
S = load('gatlin.mat'); %image existante dans Matlab
map = rgb2gray(S.map);
memory = ceil(numel(S.X)/1024);

b=4;    % nombre de SVD tronquees, precise suffisament tot 
        % pour utiliser 'subplot' a la place des 'figure'
CalculDErreur=1;

%% Calcul de l'erreur
if(CalculDErreur)
    b = min(size(S.X));
    Verreur = zeros(min(size(S.X)),1);
end
%% Calcul de la SVD sur l'image

% subplot(2,b+1,1);
    image(S.X);
    axis('image')
    axis off
    colormap(map);
    title(['Image originale : ' num2str(memory) 'ko']);

% Image apres SVD
A = double(S.X);
[U0,S0,V0] = svd(A);
ASVD = U0*S0*V0';
memory = ceil((size(U0,1) + size(V0,1))*min(size(S0))/1024);

% subplot(2,b+1,b+2);
figure
    image(ASVD);
    axis('image')
    axis off
    colormap(map);
    title(['Image apres SVD : ' num2str(memory) 'ko']);
    
VS = zeros(min(size(S0)),1); %Valeurs singulieres
for j = 1:min(size(S0))
    VS(j) = S0(j,j);
end

    
%% Calcul des SVD tronquees

for i = 1:b
    % svd tronque au k-ieme ordre
    if (CalculDErreur)
        k=i;
    else
        k = 4^i;
    end
    % Tronquer la SVD premiere manniere
    S=S0(1:k,1:k);
    V=V0(:,1:k);
    U=U0(:,1:k);
    Ak = U*S*V';
    % Tronquer la SVD deuxieme maniere
%     Vk = V0(:,1:k);
%     M = A*Vk;
%     [Tild,S,V] = svd(M'*M);
%     S = S^(1/2);
%     U = M*(V/S);
%     V = Vk*V;
%     Ak = U*S*V';
    
    
    memory = ceil((size(U,1) + size(V,1))*k/1024);
    
    if(CalculDErreur)
        Verreur(i) = norm(ASVD-Ak,'fro')/norm(A,'fro');
        disp(['' num2str(i*100/b) '%']);
    else
%         subplot(2,b+1,i+1);
        figure
        image(Ak);
        axis('image')
        axis off
        colormap(map);
        title(['Image apres une SDS d ordre ' num2str(k) ' : ' num2str(memory) 'ko.']);

    % Differences
%         subplot(2,b+1,b+i+2);
        figure
        image(ASVD-Ak);
        axis('image')
        axis off
        colormap(map);
        title(['|A-A_k| Erreur : ' num2str(norm(ASVD-Ak,'fro')/norm(A,'fro'))]);
    end
end
    
%% Post traitement



if(CalculDErreur)
    figure % Affichage des valeurs singulieres avec ordonnees en semilog
    semilogy(Verreur(1:(size(Verreur)-1)))
    title('Erreur');
else
    figure % Affichage des valeurs singulieres avec ordonnees en semilog
    semilogy(VS(1:end,:));
    AXIS([0 500 0 17000]) % pour cadrer un peu mieux dans le cas de gatlin.mat
    title('Valeur singulieres');
end

