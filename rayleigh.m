function [x,w] = rayleigh(KD,M,b,epsilon,x,Famille)

  %A = inv(K)*M;     % Peut eventuellement etre calculee pour tous les appels de la fonction
  iter=0;
  err = 1;
  while err > epsilon
    if (size(Famille,2))
        for i=1:size(Famille,2);
          x = x - x'*Famille(:,i)*Famille(:,i);
          x = x / norm(x);
        end
    else
        x = x / norm(x);
    end 
    %y=A*x;
    y = KD \ [M*x;b];
    y = y(1:size(M,1)) / norm(y(1:size(M,1)));
    x;
    y;
    if (x'*y <0)
        err = norm(x+y);
    else
        err = norm(x-y);
    end 
    
    iter=iter+1;
    if (iter>=99)
        iter
        return;
    elseif (iter>=95)
        iter
        [x y]
        err
    end
    
    
    x=y;
    
  end
  x = x / norm(x);
  x2= KD \ [M*x;b];
  x2=x2(1:size(M,1));
  
  w=(1/(x2'*x))^(1/2);
end