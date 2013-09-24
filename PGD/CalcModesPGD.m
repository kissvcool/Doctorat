function [HistMf,HistMg,HistTotf,HistTotg,HistTotgp,HistTotgpp,TableConv] = CalcModesPGD(Mmax,Kmax,M, C, K0, HistF, U0, V0, D, conditionU, OthoIntern,VectL,epsilon,Ttot, dt)

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

    verif=0;
    if (size(D,1))      % correction de l erreur d integration, impossible si les deplacements sont lies
     verif=1;           % verification que les deplacement ne sont pas lies
     [c,~]=find(D);
     for j=1:size(c,1)
        for k=1:size(c,1)
             if k~=j 
                 if ( c(j)==c(k) || verif == 0)
                     verif = 0;
                     break;
                 end
             end
        end
     end
    end
    
    for m=1:Mmax
        disp(['m = ' num2str(m)]);
        
        if norm(U0) && m==1
            if (verif)
                [i,~]=find(D');
                U0(i,1) = conditionU(:,1);
            else
                ErreurVerifConditionInitialNonPriseEnCompte;
            end
                     
            HistKf = [];
            HistKg  = [];
            HistKgp  = [];
            HistKgpp  = [];
            f_q = [U0 ; zeros(size(D,1),1)] ;
            g_q = ones(size(HistF,2),1);
            gp_q = zeros(size(HistF,2),1);
            gpp_q = zeros(size(HistF,2),1);

%             gpp_q = ones(size( 0:dt:Ttot ))';
%             gp_q  = (0:dt:Ttot)';
%             g_q   = 1/2*gp_q.^2;
    
        else
            [HistKf,HistKg,HistKgp,HistKgpp,TableConv(m,:),TableCondi(m,:),f_q,g_q,gp_q,gpp_q] = PointFixePGD(Kmax,M, C, K0, HistF, U0, V0, D, conditionU, m, dt, HistMf, HistMg, HistMgp, HistMgpp,OthoIntern,VectL,epsilon,Ttot);
        end
        
%         norme_f_q=norm(f_q(1:size(VectL,2)))-1
%         f_q(1:size(VectL,2)) = f_q(1:size(VectL,2)) / norm(f_q(1:size(VectL,2))); 
%         norme_f_q=norm(f_q(1:size(VectL,2)))-1
        
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