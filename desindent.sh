iconv -f ISO-8859-1 -t UTF-8 $1 | sed -r "s/\t//ig" > $1.dgibi
# cat $1.dgibi
./Lance_cast $1.dgibi
#| sed -re "s/^ *//ig" 
#| sed '/^$/d'
