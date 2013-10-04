function [HistUExact,HistVExact,HistAExact] = SolutionExacte(cas,c,AmpliF,Egene,Sec,L,VectL,VectT,dt,NbPas6)

   if cas == 4
        HistAExact=zeros( size(VectL,2),size(VectT,2) );
        HistVExact=zeros( size(VectL,2),size(VectT,2) );
        HistUExact=zeros( size(VectL,2),size(VectT,2) );
        CoeffChoc = ((c*AmpliF)/(Egene*Sec));
        for j=1:(size(VectT,2))
            for i=1:size(VectL,2)
                x= VectL(i);
                t= VectT(j);
                k= floor(c*t/(2*L));
                if (x > abs(L-c*t+2*k*L) )
                    HistVExact(i,j) = (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistUExact(i,j) = CoeffChoc * (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistUExact(i,j) = CoeffChoc * 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistUExact(i,j) = CoeffChoc * ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
                if (j>1)
                    HistAExact(i,j) = ( HistVExact(i,j) -HistVExact(i,j-1) ) / dt;
                end
            end
        end
    elseif cas == 6
        HistAExact=zeros( size(VectL,2),size(VectT,2) );
        HistVExact=zeros( size(VectL,2),size(VectT,2) );
        HistUExact=zeros( size(VectL,2),size(VectT,2) );
        CoeffChoc = ((c*AmpliF)/(Egene*Sec));
        for j=1:(size(VectT,2))
            for i=1:size(VectL,2)
                x= VectL(i);
                t= VectT(j);
                k= floor(c*t/(2*L));
                if (x > abs(L-c*t+2*k*L) )
                    HistVExact(i,j) = (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistUExact(i,j) = CoeffChoc * (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistUExact(i,j) = CoeffChoc * 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistUExact(i,j) = CoeffChoc * ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
            end
        end
        
        for j=(NbPas6+1):(size(VectT,2))
            for i=1:size(VectL,2)
                x= VectL(i);
                t= VectT(j-NbPas6);
                k= floor(c*t/(2*L));
                if (x > abs(L-c*t+2*k*L) )
                    HistVExact(i,j) = HistVExact(i,j) - (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistUExact(i,j) = HistUExact(i,j) - CoeffChoc * (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistUExact(i,j) = HistUExact(i,j) - CoeffChoc * 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistUExact(i,j) = HistUExact(i,j) - CoeffChoc * ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
            end
        end
        
        for j=2:(size(VectT,2))
            for i=1:size(VectL,2)
                HistAExact(i,j) = ( HistVExact(i,j) -HistVExact(i,j-1) ) / dt;
            end
        end
        
    elseif cas == 5
        % Dans ce cas AmpliF est utilise comme coefficient de la rampe,
        %  donc dans la bonne unité pour (c*AmpliF)/(Egene*Sec) soit une
        %  acceleration
        HistAExact=zeros( size(VectL,2),size(VectT,2) );
        HistVExact=zeros( size(VectL,2),size(VectT,2) );
        HistUExact=zeros( size(VectL,2),size(VectT,2) );
        CoeffChoc = ((c*AmpliF)/(Egene*Sec));
        for j=1:(size(VectT,2))
            for i=1:size(VectL,2)
                x= VectL(i);
                t= VectT(j);
                k= floor(c*t/(2*L));
                Dk = floor(k/2);
                if (x > abs(L-c*t+2*k*L) )
                    HistAExact(i,j) = (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistVExact(i,j) = CoeffChoc* (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistVExact(i,j) = CoeffChoc* 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistVExact(i,j) = CoeffChoc* ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
                CycleU = Dk * CoeffChoc * 2*x * 2*L/(c^2);
                if  (t2k < (2*L/c) )
                    if      (t2k > (L-x)/c ) && (t2k < (L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc* 1/2*(t2k- (L-x)/c)^2;
                    elseif  (t2k > (L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc* ( (2*x^2)/c^2 + (2*x/c)*(t2k - (L+x)/c) );
                    else
                        HistUExact(i,j) = CycleU ;
                    end
                else                    
                    if (t2k > (3*L-x)/c ) && (t2k < (3*L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc* ( (2*x^2)/c^2 + (2*x/c)*(t2k - (L+x)/c) );
                        HistUExact(i,j) = HistUExact(i,j) - CoeffChoc* 1/2*(t2k- (3*L-x)/c)^2;
                    elseif (t2k > (3*L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc*2*x * 2*L/(c^2);
                    else
                        HistUExact(i,j) = CycleU + CoeffChoc* ( (2*x^2)/c^2 + (2*x/c)*(t2k - (L+x)/c) );
                    end
                end
                
            end
        end
    else
        HistAExact = [];
        HistVExact = [];
        HistUExact = [];
    end