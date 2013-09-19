function [MR,CR,K0R,U0R,V0R,DR,HistFR,nonLineariteR] = Projection(PRT,M,C,K0,U0,V0,D,HistF,nonLine,nonLinearite)


        MR  = PRT'*M*PRT;
        CR  = PRT'*C*PRT;
        K0R = PRT'*K0*PRT; 
        
        if (nonLine==1)
            % Ajout du ressort
            nonLineariteR(1).scalaires      = nonLinearite(1).scalaires; 
            nonLineariteR(1).matriceKUnit   = PRT'*nonLinearite(1).matriceKUnit*PRT; 
            nonLineariteR(1).dependanceEnU  = PRT'*nonLinearite(1).dependanceEnU;
        else
            nonLineariteR(1) = nonLinearite(1);
        end
        
        HistFR  = PRT'*HistF;
        U0R     = PRT'*U0;
        V0R     = PRT'*V0;

        if (size(D,1))
            DR=D*PRT;
        else    
            DR=[];
        end
end