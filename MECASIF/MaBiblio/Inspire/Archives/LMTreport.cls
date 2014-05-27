%% ====================================================================
%%  `LMTreport.cls' - a class for reports at LMT-Cachan
%%  -------------------------------------------------------------------
%%  David N\'eron
%%  neron@lmt.ens-cachan.fr
%% ====================================================================
\def\fileversion{1.2}
\def\filedate{2005/04/25}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{LMTreport}[\filedate\space v\fileversion\space-
                          a class for reports at LMT-Cachan]
\LoadClass[12pt]{book}

% ---------------------------------------> Chargement des packages <---

\RequirePackage{geometry}          % R\'egler la taille de la page
\RequirePackage{amsmath,amssymb,bm}% \'Etendre les fonctions maths
\RequirePackage{fancybox}          % Faire de jolies bo\^\ites
\RequirePackage{calc}              % Faire des calculs
\RequirePackage{xspace}            % Gestion automatique des espaces
\RequirePackage{fancyhdr}          % Configurer headers/footers
\RequirePackage[french]{minitoc}   % Minitocs en d\'ebut de chapitre
\RequirePackage{geometry}          % G\'eom\'etrie de la page
\RequirePackage[centerlast,bf]{caption2} % Captions
\RequirePackage[center]{subfigure} % Inclusion de subfigures
\RequirePackage{array}             % Gestion des tableaux
\RequirePackage{tocbibind}         % ToC, ToF, etc. dans la ToC
\RequirePackage[frenchb]{babel}    % R\`egles typo fran\ccaises
\RequirePackage{ifpdf}             % Tester si g\'en\'eration d'un pdf
%\RequirePackage{bbdd}  

% ------------------------------------------> G\'eom\'etrie de la page <---

\geometry{a4paper,
          twoside,
          body={15cm,22cm},
          lmargin=3cm,
          rmargin=3cm,
          footskip=1.5cm,
          top=4cm,
          headsep=1cm,
          head=15pt}

% ---------------------------------------------> LaTeX ou pdfLaTeX <---

\ifpdf
   \RequirePackage[pdftex]{graphicx,color}
   \RequirePackage[pdftex]{hyperref}
   \geometry{pdftex}
\else
   \RequirePackage[dvips]{graphicx,color}
   \RequirePackage[ps2pdf]{hyperref}
   \geometry{dvips}
\fi
	       
% --------------------------------------------> R\'eglage d'hyperref <---

\hypersetup{a4paper=true,
            pdfstartview=FitH,
	    linkcolor=blue,
        citecolor=blue,
        urlcolor=blue,
        colorlinks=true,
	    pdfborder=0 0 0}

% ------------------------------------------------> toc et minitoc <---

% R\'eglage de la toc
\setcounter{tocdepth}{2}       % profondeur de la toc
\setcounter{secnumdepth}{3}    % profondeur de la num\'erotation 

% R\'eglage de la minitoc
\setcounter{minitocdepth}{2}
\setlength{\mtcindent}{15pt}                % indentation des minitocs
\renewcommand{\mtcfont}{\small\rm}          % fonte des minitocs
\renewcommand{\mtcSfont}{\small\bfseries}   % fonte des minitocs
\newcommand{\mtoc}{\minitoc\thispagestyle{plain}\newpage}

% Pour g\'erer des interf\'erences entre minitoc et hyperref
\let\old@tableofcontents\tableofcontents
\def\tableofcontents{\old@tableofcontents\mtcaddchapter}
\let\old@listoffigures\listoffigures
\def\listoffigures{\old@listoffigures\mtcaddchapter}
\let\old@listoftables\listoftables
\def\listoftables{\old@listoftables\mtcaddchapter}

% --------------------------------------------> Quelques commandes <---

% Pour laisser un espace vertical entre deux paragraphes
\newcommand{\Par}{\bigskip\par}

% Pour que la page paire, ajout\'ee afin de commencer les chapitres
% sur une page impaire, soit sans header/footer
\newcommand{\clearemptydoublepage}{\newpage{\pagestyle{empty}%
                                   \cleardoublepage}}

% Des remerciements
\newenvironment{merci}
   {%
     \clearemptydoublepage
     \thispagestyle{empty}
     \null\vfill}
   {%
     \vfill\clearemptydoublepage}

% Des paragraphes encadr\'es
\newenvironment{parboxed}
   {%
     \setlength{\fboxsep}{10pt}
     \begin{Sbox}%
     \begin{minipage}{\linewidth-2\fboxrule-2\fboxsep}
     \setlength{\abovedisplayskip}{0pt}
     \setlength{\belowdisplayskip}{0pt}}
   {%
     \end{minipage}%
     \end{Sbox}
     \[\fbox{\TheSbox}\]\aftergroup\ignorespaces}

% Un r\'esum\'e du chapitre
\newenvironment{resumechap}[1][]
   {%
     \vspace{2cm}
     \begin{center}
     \begin{minipage}{.7\linewidth}
     \centering\itshape}
   {%
     \end{minipage}
     \end{center}
     \vspace{2cm}}

% -----------------------------> Configuration des headers/footers <---

% Titre de bas de page
\def\lmt@foottitle{}
\newcommand{\foottitle}[1]{\def\lmt@foottitle{#1}}

% Pour une page courante : avec header et footer
\fancyhf{}
\fancyfoot[C]{\small\itshape\lmt@foottitle}
\fancyhead[RO,LE]{\small\bfseries\thepage}
\fancyhead[LO]{\nouppercase{\small\bfseries\rightmark}}
\fancyhead[RE]{\nouppercase{\small\bfseries\leftmark}}
\renewcommand{\footrulewidth}{.0pt}
\renewcommand{\headrulewidth}{.5pt}

% Pour une page de d\'ebut de chapitre (ie de style plain) :
% avec seulement footer
\fancypagestyle{plain}{
\fancyhf{}
\fancyfoot[C]{\small\itshape\lmt@foottitle}
\renewcommand{\footrulewidth}{.0pt}
\renewcommand{\headrulewidth}{.0pt}}

\pagestyle{fancy}

\renewcommand{\chaptermark}[1]{\markboth{#1}{}}
\renewcommand{\sectionmark}[1]{\markright{#1}}

% -----------------------------------> Configuration des chapitres <---

% Num\'erotation moins charg\'ee
\renewcommand{\thesection}{\@arabic\c@section}

% Style de chapitre, esth\'etique pomp\'ee dans thesetb.cls
\newfont{\chapfonte}{cmr10 scaled 9000}
\def\haut{20mm}
\def\decal{1.75ex}
\newlength{\lgnamechap}
\newlength{\lgnumchap}
\newlength{\lgall}    

% Red\'efinition de \chapter
\def\@makechapterhead#1{%
  \vspace*{50\p@}%
  {\parindent \z@ \raggedleft \normalfont
    \ifnum \c@secnumdepth >\m@ne
      \if@mainmatter
        \huge\bfseries \@chapapp\space \thechapter
        \par\nobreak
        \vskip 20\p@
      \fi
    \fi
    \interlinepenalty\@M
    \Huge \bfseries #1\par\nobreak
    \vskip 40\p@
  }}

% Red\'efinition de \chapter*
\def\@makeschapterhead#1{%
  \vspace*{50\p@}%
  {\parindent \z@ \raggedleft
    \normalfont
    \interlinepenalty\@M
    \Huge \bfseries  #1\par\nobreak
    \vskip 40\p@
  }\markboth{#1}{#1}}

% Chapitre sans num\'ero mais qui apparait dans la ToC
\newcommand{\chapterwithnonb}[1]{\toc@chapter{#1}\mtcaddchapter}

% ------------------------------> Gestion des flottants/r\'ef\'erences <---

% Noms des flottants
\newcommand{\Figure}{\textsc{Fig.}}
\newcommand{\Tableau}{\textsc{Tab.}}
\newcommand{\Algorithme}{\textsc{Alg.}}
\newcommand{\Chapitre}{\textsc{Chap.}}
