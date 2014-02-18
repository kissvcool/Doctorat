#!/bin/sh

for iter in Autres Castem Latex Maple Matlab
do
	git clone https://github.com/kissvcool/Doctorat.git
	mv Doctorat/ $iter/
	cd $iter/
	git checkout -b $iter origin/$iter
	git branch -d master
	cd ..
done

cd Autres
chmod a+x Installation.sh push.sh pull.sh Cluster/scripctJobs.sh