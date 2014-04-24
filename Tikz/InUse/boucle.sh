
for fichier in *Sch*.tikz
do
#	echo "$fichier"
	./modif.sh $fichier
done

mv *.eps rrr/
