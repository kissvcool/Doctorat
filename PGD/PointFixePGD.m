function [HistKf,HistKg,HistKgp,HistKgpp,ConvergPointFixe,Conditionnement,f_q,g_q,gp_q,gpp_q] = PointFixePGD(Kmax,M, C, K0, HistF, U0, V0, D, conditionU, m, dt, HistMf, HistMg, HistMgp, HistMgpp,OthoIntern,VectL,epsilon,Ttot)

    % Initialiser g(t) %, h(theta)
    gpp_q = ones(size( 0:dt:Ttot ))';
    gp_q  = (0:dt:Ttot)';
    g_q   = 1/2*gp_q.^2;
    
    K = [ K0 D' ; D zeros(size(D,1))];
    
    HistKf  =zeros(size(K,1),Kmax);
    HistKg 	=zeros(size(g_q,1),Kmax);
    HistKgp =zeros(size(g_q,1),Kmax);
    HistKgpp=zeros(size(g_q,1),Kmax);
    ConvergPointFixe = zeros(1,Kmax);
    Conditionnement  = zeros(1,Kmax);
        
    for k=1:Kmax
        [f_q,condi] = ProblemEspace(M, C, K0, HistF, U0, V0, D, conditionU, g_q, gp_q,gpp_q, m, dt, HistMf, HistMg, HistMgp, HistMgpp);
        if OthoIntern
            for i=1:(m-1)
                f_q(1:size(VectL,2)) = f_q(1:size(VectL,2)) - HistMf(1:size(VectL,2),i)*(HistMf(1:size(VectL,2),i)'*f_q(1:size(VectL,2)) );
            end
        end
        Conditionnement(k) = condi;
        if ~(norm(f_q)==0)
            f_q(1:size(VectL,2)) = f_q(1:size(VectL,2)) / norm(f_q(1:size(VectL,2)));
        end
        HistKf(:,k) = f_q;
        if m>1  % Enlever les multiplicateur de Lagrange
            HistMfg=HistMf(1:size(VectL,2),:);
        else
            HistMfg=HistMf;
        end
        %disp(['---------Probleme en temps------------']);
        [g_q,gp_q,gpp_q] = ProblemTemps(M, C, K0, HistF, D, conditionU, f_q(1:size(VectL,2),:), m, dt, HistMfg, HistMg, HistMgp, HistMgpp, 3);

        HistKg(:,k)   = g_q  ;
        HistKgp(:,k)  = gp_q ;
        HistKgpp(:,k) = gpp_q;

        if (k>1) 
            ConvergPointFixe(k) = IntegrLine((g_q-HistKg(:,k-1)),(g_q-HistKg(:,k-1)),0,dt) * (f_q-HistKf(:,k-1))' *K* (f_q-HistKf(:,k-1));
            ConvergPointFixe(k) = ConvergPointFixe(k) / (IntegrLine( g_q,g_q ,0,dt) * f_q' *K* f_q);
            ConvergPointFixe(k) = sqrt(ConvergPointFixe(k)) ;
            if (k>2)
                if (ConvergPointFixe(k) < epsilon && ConvergPointFixe(k-1) < epsilon)
                    disp(['convergence apres ' num2str(k) ' iterations']);
                    break
                end
            end
        end
    end
    if k==Kmax        
        disp(['ne convergence pas apres ' num2str(k) ' iterations']);
    end
    HistKf   = HistKf(:,1:k);
    HistKg   = HistKg(:,1:k);
    HistKgp  = HistKgp(:,1:k);
    HistKgpp = HistKgpp(:,1:k);
    
end