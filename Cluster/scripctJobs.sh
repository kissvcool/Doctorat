#!/bin/sh

for iter in `seq 1 6480` #6480`
do

	# $((C+(( ((($iter-1)/A)%B) +1)-1)*D))
	#A : Nombre d iteration sans changement = Nombre de possibilites anterieures
	#B : Nombre de valeurs a tester
	#C : Valeur minimale
	#D : interval entre les valeurs
	rebut=0;

		possibilites=1;
	cas=$(((($iter-1)%6) +1));	# 1 a 6
		possibilites=$(($possibilites*6));
	schem=$(( ((($iter-1)/$possibilites)%6) +1));	# 1 a 34 -> 1 a 6 plus changements alpha et dt
		possibilites=$(($possibilites*6));
	dt=$(( ((($iter-1)/$possibilites)%5) +1))
	dt=$(( $dt + ($dt/3) + 3*($dt/4) + 11*($dt/5)   ))	# 1, 2, 4, 8, 20
		possibilites=$(($possibilites*5));
	alpha=$(( ((($iter-1)/$possibilites)%3) +1))	# 1, 2, 3
		possibilites=$(($possibilites*3));
	Mmax=$((50+(( ((($iter-1)/$possibilites)%2) +1)-1)*50)); 	# 50, 100
		possibilites=$(($possibilites*2));
	Kmax=$((10+(( ((($iter-1)/$possibilites)%2) +1)-1)*30));	# 10, 40
		possibilites=$(($possibilites*2));
	Elem=$((( ((($iter-1)/$possibilites)%3) +1)-1))
	Elem=$((20+($Elem+($Elem/2))*20));	# 20, 40, 80
	possibilites=$(($possibilites*3));

	iter=$( printf "%04d" $iter )

	if [ "$schem" -lt 3 ]	# Schema a stabilite conditionnelle
		then
		if [ "$(($Elem*$dt))" -ge 48 ]	# condition stabilite : c*dt < Lelem
			then
			rebut=1;
			echo "$iter au rebut pour Condition stabilite $(($Elem*$dt)) > 48"
		fi
	fi

	if [ "$schem" -lt 4 ]||[ "$schem" -eq 6 ]	# Schema independents de alpha
		then
		if [ "$alpha" -gt 1 ]	# Calcul redondant
			then
			rebut=1;
			echo "$iter au rebut pour Calcul redondant"
		fi
		alpha=0;
	fi

	ecrire=1;
	if [ "$rebut" -eq 0 ]
		then
		if [ "$ecrire" -eq 1 ]
			then
			echo "rsync -ravz --exclude='*.mat' master:/home/nargil/Calcul  /usrtmp/nargil/" > job
			echo "scp master:/home/nargil/Ref$iter.m  /usrtmp/nargil/Calcul" >> job
			echo "cd /usrtmp/nargil/Calcul/" >> job
			echo "/usr/local/MATLAB-R2012b/bin/matlab -nodisplay -r Ref$iter > Log$iter" >> job
			echo "mkdir /data1/nargil/resultats/JOB$iter/" >> job
			echo "cp /usrtmp/nargil/Calcul/*Log$iter /data1/nargil/resultats/JOB$iter/" >> job
			echo "cp /usrtmp/nargil/Calcul/*.mat /data1/nargil/resultats/JOB$iter/" >> job
			echo "rm -r /usrtmp/nargil/" >> job
			mv job job"$iter"

		    cp aRef.m Ref"$iter".m

			sed -e "s/cas = 0;/cas = $cas;/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/schem = 0;/schem = $schem;/g" Refb"$iter".m > Ref"$iter".m
			sed -e "s/Mmax=0;/Mmax=$Mmax;/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/Kmax=0;/Kmax=$Kmax;/g" Refb"$iter".m > Ref"$iter".m
			sed -e "s/nombreElementsParPartie=20;/nombreElementsParPartie=$Elem;/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/alpha=0/alpha=-$alpha\/9/g" Refb"$iter".m > Ref"$iter".m
			sed -e "s/dt=  4/dt=  $dt/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/alpha=0/alpha=-$alpha\/9/g" Refb"$iter".m > Ref"$iter".m
			sed -e "s/diary FichierLog/diary FichierLog$iter/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/rrrrr/rrrrr/g" Refb"$iter".m > Ref"$iter".m
		fi

		echo "$iter cas = $cas - schem = $schem - Mmax=$Mmax - Kmax=$Kmax - Elem =$Elem - alpha = -$alpha/9 - dt =$dt - rebut=$rebut"
		T0=4;
		Tf=$(( ($Mmax/50)*($Mmax/50)  *  ($Kmax/10)  *  ($Elem/20) * $T0 * (1+2/dt)));
		echo "temps de calcul T0*$(( ($Mmax/50)*($Mmax/50)  ))*$(( $Kmax/10 ))*$(( $Elem/20 ))*$((1+2/dt)) = $Tf"
		if [ $Tf -ge 60 ]
			then
			Th=$(($Tf/60));
			Tm=$(($Tf%60));
			Th=$( printf "%02d" $Th )
			Th=$( printf "%02d" $Th )
		else
			Th="00";
			Tm=$Tf;
			Tm=$( printf "%02d" $Tm )
		fi
		if [ "$ecrire" -eq 1 ]
			then
			sed -e "s/for i=VectN % Animation/for i=1:0 % Animation/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/surf/%surf/g" Refb"$iter".m > Ref"$iter".m
			sed -e "s/figure/%figure/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/plot/%plot/g" Refb"$iter".m > Ref"$iter".m

			sed -e "s/% clearvars -except program IterProgram ;/disp('script : cas = $cas - schem = $schem - Mmax=$Mmax - Kmax=$Kmax - Elem =$Elem - alpha = -$alpha\/9  - dt=$dt');/g" Ref"$iter".m > Refb"$iter".m
			sed -e "s/% program/NumeroCalcul=$iter/g" Refb"$iter".m > Ref"$iter".m

			
			#sed -e "s/sdfserrthrzzrzer/sdfserrthrzzrzek/g" Refb"$iter".m > Ref"$iter".m

			if [ "$schem" -eq 6 ]  # GD en temps
				then
				sed -e "s/CL=1;/CL=2;/g" Ref"$iter".m > Refb"$iter".m
				###### mettre le % devant exit pour local
				sed -e "s/% Fonction f(X), g(t) %, h(theta)/fichier = ['Resultats.' num2str(NumeroCalcul) '.schem.' num2str(schem) '.elem.' num2str(nombreElementsParPartie) '.alpha.$alpha.sur9.dt.$dt.mat' ];\nsave(fichier);\nexit;\nreturn;/g" Refb"$iter".m > Ref"$iter".m
			else
				sed -e "s/AnalyseDeMAC(NbModesPOD,NbModesPGD,ModePOD,ModePGD);/fichier = ['Resultats.' num2str(NumeroCalcul) '.schem.' num2str(schem) '.elem.' num2str(nombreElementsParPartie) '.alpha.$alpha.sur9.dt.$dt.mat' ];\nsave(fichier);\nexit;\nreturn;/g" Ref"$iter".m > Refb"$iter".m
				###### mettre le % devant exit pour local
				sed -e "s/sdfserrthrzzrzer/sdfserrthrzzrzek/g" Refb"$iter".m > Ref"$iter".m
			fi

			rm Refb"$iter".m
		fi

			#mem=$(( ($Mmax/50) * ($Elem/20) * 3 ));
		#### enlever echo
			qsub -l nodes=01:ppn=3,walltime=$Th:$Tm:00,pvmem=3gb job$iter
	fi

done

	echo "possibilites=$possibilites"
