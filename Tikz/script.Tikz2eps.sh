echo "\documentclass{standalone}
\usepackage{pgfplots}
\pgfplotsset{compat=newest}

\begin{document}

\input{$1}

\end{document}" > TempTikzToEps

pdflatex TempTikzToEps
pdf2ps TempTikzToEps.pdf
ps2eps TempTikzToEps.ps
mv TempTikzToEps.eps imageEPS.$1.eps
mv TempTikzToEps.pdf imagePDF.$1.pdf
rm TempTikzToEps*