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


    % Transmettre M, C, K0, D, condition(t)
    for m=1:Mmax
        disp(['m = ' num2str(m)]);

        [HistKf,HistKg,HistKgp,HistKgpp,TableConv(m,:),TableCondi(m,:),f_q,g_q,gp_q,gpp_q] = CalcCouplePGD(Kmax,M, C, K0, HistF, U0, V0, D, conditionU, m, dt, HistMf, HistMg, HistMgp, HistMgpp,OthoIntern,VectL,epsilon,Ttot);

%         norme_f_q=norm(f_q(1:size(VectL,2)))-1
        f_q(1:size(VectL,2)) = f_q(1:size(VectL,2)) / norm(f_q(1:size(VectL,2))); 
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