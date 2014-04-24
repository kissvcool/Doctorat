
echo "\documentclass{standalone}
\usepackage{pgfplots}
\pgfplotsset{compat=newest}

\begin{document}

\input{TempTikzToEpsc.tikz}

\end{document}" > TempTikzToEps

sed -e 's/width=[0-9]*.[0-9]*in,/width=6cm,/' $1 > TempTikzToEpsb.tikz
sed -e 's/height=[0-9]*.[0-9]*in,/height=4cm,/' TempTikzToEpsb.tikz > TempTikzToEpsc.tikz
#sed -e 's/ymin=-[0-9]*.[0-9]*e-[0-9]*,/ymin=-1.5e-06,/' TempTikzToEpsc.tikz > TempTikzToEpsb.tikz
#sed -e 's/ymax=[0-9]*.[0-9]*e-[0-9]*,/ymax=1.5e-06, ylabel={u (m)}, %y label style={rotate=-90},/' TempTikzToEpsb.tikz > TempTikzToEpsc.tikz
#sed -e 's/Schema Newmark - Acceleration moyenne, //' TempTikzToEpsc.tikz > TempTikzToEpsb.tikz
#sed -e 's/dt=/$\\Delta t$=/' TempTikzToEpsb.tikz > TempTikzToEpsc.tikz
#sed -e 's/xmax=0.001,/xmax=0.001, xlabel={t (s)},/' TempTikzToEpsc.tikz > TempTikzToEpsb.tikz
#sed -e 's/eeeeeeeeee/eeeeeeeeee/' TempTikzToEpsb.tikz > TempTikzToEpsc.tikz

pdflatex TempTikzToEps
pdf2ps TempTikzToEps.pdf
ps2eps TempTikzToEps.ps

diff $1 TempTikzToEpsc.tikz

mv TempTikzToEps.eps $1.eps
mv TempTikzToEps.pdf $1.pdf
rm TempTikzToEps*

#ymin=-1.5e-06,
#ymax=1.5e-06,