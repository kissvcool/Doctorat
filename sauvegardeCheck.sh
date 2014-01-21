#!/bin/sh

cd ..
for iter in Autres Castem Latex Maple Matlab
do
	cd $iter
	git checkout
	git status
#	git commit -m "visuel"
#	git push origin $iter:$iter
	cd ..
done
