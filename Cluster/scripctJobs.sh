#!/bin/sh

for iter in `seq 1 144`
do
#	echo "rsync -ravz --exclude='*.mat' master:/home/nargil/Calcul  /usrtmp/nargil/" > job
#	echo "scp master:/home/nargil/Ref$iter.m  /usrtmp/nargil/Calcul" >> job
#	echo "cd /usrtmp/nargil/Calcul/" >> job
#	echo "usr/local/MATLAB-R2012b/bin/matlab -nodisplay -r Ref$iter > Log" >> job
#	#echo "mkdir /data1/nargil" >> job
#	echo "rsync -ravz /usrtmp/nargil/ /data1/nargil/resultats/JOB$iter" >> job
#	echo "rm -r /usrtmp/nargil/" >> job
#	mv job job"$iter"

#    cp aRef.m Ref"$iter".m
#	if [ "$(($iter % 2))" -eq 1 ]
#		then
#		echo "iter $iter"
#	fi

#	sed -e "s/cas = 0;/cas = $(((($iter-1)%6) +1));/g" Ref"$iter".m > Refb"$iter".m
## $(( ((($iter-1)/A)%B) +1))
#	sed -e "s/schem = 0;/schem = $(( ((($iter-1)/6)%6) +1));/g" Refb"$iter".m > Ref"$iter".m
#	sed -e "s/Mmax=0;/Mmax=$((50+(( ((($iter-1)/36)%2) +1)-1)*50));/g" Ref"$iter".m > Refb"$iter".m
## $((C+(( ((($iter-1)/A)%B) +1)-1)*D))
	#A : Nombre d iteration sans changement = Nombre de possibilites anterieures
	#B : Nombre de valeurs a tester
	#C : Valeur minimale
	#D : interval entre les valeurs
#	sed -e "s/Kmax=0;/Kmax=$((10+(( ((($iter-1)/72)%2) +1)-1)*30));/g" Refb"$iter".m > Ref"$iter".m
	echo "$(((($iter-1)%6) +1)) - $(( ((($iter-1)/6)%6) +1)) - $((50+(( ((($iter-1)/36)%2) +1)-1)*50)) - $((10+(( ((($iter-1)/72)%2) +1)-1)*30))"
#	rm Refb"$iter".m

#    qsub -l nodes=01:ppn=3,walltime=10:00:00,pvmem=3gb job"$iter"
done
