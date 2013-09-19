function [f_q,condi] = ProblemEspace(M, C, K0, HistF, U0, V0, D, conditionU, g_q, gp_q,gpp_q, m, dt, HistMf, HistMg, HistMgp, HistMgpp)

    K = [ K0 D' ; D zeros(size(D,1))];
    C = [ C zeros(size(D')) ; zeros(size(D)) zeros(size(D,1))];
    M = [ M zeros(size(D')) ; zeros(size(D)) zeros(size(D,1))];
    HistF = [ HistF ; conditionU ] ;
    
    t0 = 0;
    
%% Premier membre
%     gp_q  = DerivVect(g_q ,dt,5);
%     gpp_q = DerivVect(gp_q,dt,5);
    Premier =           IntegrLine(g_q,  g_q,t0,dt) * K ;
    Premier = Premier + IntegrLine(gp_q, g_q,t0,dt) * C ;
    Premier = Premier + IntegrLine(gpp_q,g_q,t0,dt) * M ;
    condi=rcond(Premier);

%% Second membre
    sum = zeros( size(HistF(:,1)) );
    Second = sum;
    for i=1:(m-1)
        g_k_q = HistMg(:,i);
        f_k_q = HistMf(:,i);
        sum = sum + IntegrLine(g_k_q,  g_q,t0,dt) * f_k_q;
    end
    Second = Second - K * sum;
    sum1=sum;
    
    sum = zeros( size(HistF(:,1)) );
    for i=1:(m-1)
        %g_k_q  = HistMg(:,i);
        %g_kp_q  = DerivVect(g_k_q ,dt,5);
        g_kp_q = HistMgp(:,i);
        f_k_q  = HistMf(:,i);
        sum = sum + IntegrLine(g_kp_q,  g_q,t0,dt) * f_k_q;
    end
    Second = Second - C * sum;
    sum2=sum;
    
    sum = zeros( size(HistF(:,1)) );
    for i=1:(m-1)
        %g_k_q = HistMg(:,i);
        %g_kp_q   = DerivVect(g_k_q  ,dt,5);
        %g_kp_q = HistMgp(:,i);
        %g_kpp_q  = DerivVect(g_kp_q ,dt,5);
        g_kpp_q = HistMgpp(:,i);
        f_k_q = HistMf(:,i);
        sum = sum + IntegrLine(g_kpp_q,  g_q,t0,dt) * f_k_q;
    end
    Second = Second - M * sum;
    sum3=sum;
    
    sum = zeros( size(HistF(:,1)) );
    for i=1:size(HistF,1)   % Intralge sur chaque composante de F(t)
        E_i = zeros( size(HistF(:,1)) );
        E_i(i) = 1;
        F_i = HistF(i,:)';
        sum = sum + IntegrLine(F_i,  g_q,t0,dt) * E_i;
    end
    Second = Second + sum;
    sum4=sum;
    
%% Resolution

    f_q = Premier\Second;
    if isnan(f_q(1))
        Second
        sum1
        sum2
        sum3
        sum4
        shakaponk;
    end
end