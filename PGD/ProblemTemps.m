function [g_q,gp_q,gpp_q] = ProblemTemps(M, C, K0, HistF, D, conditionU, f_q, m, dt, HistMf, HistMg, HistMgp, HistMgpp, schem)

    K = K0; %[ K0 D' ; D zeros(size(D,1))];
%     C = [ C zeros(size(D')) ; zeros(size(D)) zeros(size(D,1))];
%     M = [ M zeros(size(D')) ; zeros(size(D)) zeros(size(D,1))];
%     HistF = [ HistF ; conditionU ] ;
    
    
%%  Schemas d'integration

    if (schem == 1)             % Newmark - Difference centree
        alpha = 0;
        beta = 0;
        gamma = 1/2;
    elseif (schem == 2)         % Newmark - Acceleration lineaire
        alpha = 0;
        beta = 1/12;
        gamma = 1/2; 
    elseif (schem == 3)         % Newmark - Acceleration moyenne
        alpha = 0;
        beta = 1/4;
        gamma = 1/2;
    elseif (schem == 4)        % Newmark - Acceleration moyenne modifiee
        alpha = -1/9;      % -1/3 <= alpha <= 0 
        gamma = 1/2 - alpha;
        beta  = ((1-alpha)^2)/4;  
        alpha = 0;
    elseif (schem == 5)         % HHT-alpha
        alpha = -1/9;      % -1/3 <= alpha <= 0 
        gamma = 1/2 - alpha;        % alpha = -1/3 -> amortissement maximal
        beta  = ((1-alpha)^2)/4;
    end

    
%% Premier membre
    Premier_g   = f_q' * K * f_q ;
    Premier_gp  = f_q' * C * f_q ;
    Premier_gpp = f_q' * M * f_q ;
    
%% Resolution

    % Equation differentielle :
    % Premier_g*g + Premier_gp*gp + Premier_gpp*gpp = Second
    
    for t=1:size( HistF,2 )

        % En cas de non linearite il faut recalculer le premier membre

        % Conditions initiales
            if (t>1)
                % prediction
                 F = (1+alpha)*HistF(:,t) - alpha*HistF(:,t-1);
                 gp_q_pred = gp_q(t-1) + ( 1+alpha )*dt*(1-gamma)*gpp_q(t-1);
                 g_q_pred  = g_q(t-1)  + ( 1+alpha )*( dt*gp_q(t-1) + (dt^2)*(1/2 - beta)*gpp_q(t-1) ); 
            else
                % Initialisation
                g_q = zeros(size( HistF(1,:)' ));
                gp_q = zeros(size( HistF(1,:)' ));
                gpp_q = zeros(size( HistF(1,:)' ));

                % Valeur initiale ?

                % Prediction
                g_q_pred  =  g_q(t);
                gp_q_pred = gp_q(t);
                F = HistF(:,t);
            end

        % Second membre

            sum = 0;
            Second = sum;
            for i=1:(m-1)
                g_k_q = HistMg(:,i);
                f_k_q = HistMf(:,i);
                sum = sum + (f_q' * K * f_k_q) * g_k_q(t);
            end
            Second = Second - sum;

            sum = 0;
            for i=1:(m-1)
                g_k_q = HistMg(:,i);
                %g_kp_q   = DerivVect(g_k_q  ,dt,5);
                g_kp_q = HistMgp(:,i);
                f_k_q = HistMf(:,i);
                sum = sum + f_q' * C * f_k_q *g_kp_q(t);
            end
            Second = Second - sum;

            sum = 0;
            for i=1:(m-1)
                g_k_q = HistMg(:,i);
                %g_kp_q   = DerivVect(g_k_q  ,dt,5);
                g_kp_q = HistMgp(:,i);
                %g_kpp_q  = DerivVect(g_kp_q ,dt,5);
                g_kpp_q = HistMgpp(:,i);
                f_k_q = HistMf(:,i);
                sum = sum + f_q' * M * f_k_q *g_kpp_q(t);
            end
            Second = Second - sum;

            Second = Second + f_q'*F ;


        gpp_q(t) = ( Second - Premier_g*g_q_pred - Premier_gp*gp_q_pred )/Premier_gpp;

        if (t>1)
             gp_q(t) = gp_q(t-1) + dt*(1-gamma)*gpp_q(t-1) + dt*gamma*gpp_q(t);
             g_q(t)  = g_q(t-1)  + dt*gp_q(t-1) + (dt^2)*(1/2 - beta)*gpp_q(t-1) + beta*(dt^2)*gpp_q(t);
        end
    end
    
        
end