function [HistMf,HistMg,HistTotf,HistTotg,HistTotgp,HistTotgpp,TableConv,Mmax] = CalcModesPGD(Mmax,Kmax,M, C, K0, HistF, U0, V0, D, conditionU, OthoIntern,VectL,epsilon,Ttot,dt,verif)

    if norm(U0)
        if (verif)
            Mmax = Mmax + 1;
            [i,~]=find(D');
            U0(i,1) = conditionU(:,1);
        else
            ErreurVerifConditionInitialNonPriseEnCompte;
        end
    end
    
    if norm(conditionU)     
        if ~verif    
            ErreurVerifConditionDeplacementNonPriseEnCompte;
        end
        
        for i=1:size(conditionU,1)
            if norm(conditionU(i,:))
                Mmax = Mmax + 1;
            end
        end
        
    end
        
    HistMf    =zeros(size(K0,1)+size(D,1),Mmax);
    HistMg  =zeros(size((0:dt:Ttot)',1),Mmax);
    HistMgp =zeros(size(HistMg));
    HistMgpp=zeros(size(HistMg));

    HistTotf=cell(1,Mmax);
    HistTotg  =cell(1,Mmax);
    HistTotgp =cell(1,Mmax);
    HistTotgpp=cell(1,Mmax);


    TableCondi = zeros(Mmax,Kmax);
    TableConv =  zeros(Mmax,Kmax);

    
    LectureConditionU =1;
    for m=1:Mmax
        disp(['m = ' num2str(m)]);
        
        if norm(U0) && m==1                     
            HistKf = [];
            HistKg  = [];
            HistKgp  = [];
            HistKgpp  = [];
            f_q = [U0 ; zeros(size(D,1),1)] ;
            g_q = ones(size(HistF,2),1);
            g_q = g_q * norm(f_q(1:size(VectL,2)));
            f_q = f_q / norm(f_q(1:size(VectL,2)));
            gp_q = zeros(size(HistF,2),1);
            gpp_q = zeros(size(HistF,2),1);
            
        elseif norm(conditionU(LectureConditionU:end,:)) %&& LectureConditionU <= size(conditionU,1)
            for i=LectureConditionU:size(conditionU,1)
                if norm(conditionU(i,:))
                    
                    HistKf = [];
                    HistKg  = [];
                    HistKgp  = [];
                    HistKgpp  = [];
                    f_q = [D(i,:)' ; zeros(size(D,1),1) ];
                    g_q = conditionU(i,:);
                    g_q = g_q * norm(f_q(1:size(VectL,2)));
                    f_q = f_q / norm(f_q(1:size(VectL,2)));
                    gp_q = zeros(size(HistF,2),1);
                    gpp_q = zeros(size(HistF,2),1);
            
                    LectureConditionU = i + 1;
                    break
                elseif i>=size(conditionU,1)
                    % LectureConditionU = size(conditionU,1) + 1;
                    Il.y.a.une.erreur
                end
            end            
        else
            [HistKf,HistKg,HistKgp,HistKgpp,TableConv(m,:),TableCondi(m,:),f_q,g_q,gp_q,gpp_q] = PointFixePGD(Kmax,M, C, K0, HistF, U0, V0, D, conditionU, m, dt, HistMf, HistMg, HistMgp, HistMgpp,OthoIntern,VectL,epsilon,Ttot);
        end
        
        % norme_f_q=norm(f_q(1:size(VectL,2)))-1
        % f_q(1:size(VectL,2)) = f_q(1:size(VectL,2)) / norm(f_q(1:size(VectL,2))); 
        % norme_f_q=norm(f_q(1:size(VectL,2)))-1
        
        HistTotf{m} = HistKf;
        HistTotg{m}   = HistKg;
        HistTotgp{m}  = HistKgp;
        HistTotgpp{m} = HistKgpp;
        HistMf(:,m) = f_q;
        HistMg(:,m)  = g_q  ;
        HistMgp(:,m) = gp_q ;
        HistMgpp(:,m)= gpp_q;

    end

end