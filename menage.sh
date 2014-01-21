tac $1 | sed '1,4d' | tac | grep -v '\$' > $1.2
echo '\nfichier 2:\n'
cat $1.2 
iconv -f ISO-8859-1 -t UTF-8 $1.2 | sed -re "s/R.*valant: //g" > $1.3
echo '\nfichier 3:\n'
cat $1.3
