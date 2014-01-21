#!/bin/sh

cd ..
for iter in Autres Castem Latex Maple Matlab
do
	cd $iter
	echo "$iter"
	git pull origin $iter:$iter
	cd ..
done
