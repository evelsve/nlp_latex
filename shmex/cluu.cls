\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cluu}[2019/08/22 cluu]

\RequirePackage{iftex}
\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage[full]{textcomp}
  \RequirePackage[utf8]{inputenc}
  \input{ix-utf8enc.dfu}          % define more characters
\else
  % Can't use ix-utf8enc, so add some characters from there
  \RequirePackage{newunicodechar}
  \newunicodechar{ }{\nobreakspace}
  \newunicodechar{­}{\-}
  \newunicodechar{ﬁ}{fi}
  \newunicodechar{ﬂ}{fl}
  \newunicodechar{–}{--}
  \newunicodechar{—}{---}
  \newunicodechar{‘}{`}
  \newunicodechar{’}{'}
  \newunicodechar{“}{``} % ''
  \newunicodechar{”}{''}
  % LuaLaTeX normally prefers system fonts to texmf fonts.
  % But libertine package works best with the versions it expects.
  \ifLuaTeX
  \directlua{
    fonts.names.set_location_precedence{
      "local", "texmf", "system" % The default is "local", "system", "texmf"
    }
  }
  \fi
\fi
%? \RequirePackage{amsmath}
\RequirePackage{placeins} % for FloatBarrier

\RequirePackage{etoolbox}
\RequirePackage{xpatch}

\frenchspacing

% As in Michael Downes's recommendations, quoted in memman.
\clubpenalty=9996
\widowpenalty=9999
\brokenpenalty=4991
\predisplaypenalty=10000
\postdisplaypenalty=1549
\displaywidowpenalty=1602

\RequirePackage{etoolbox}

% Using pgfopts with help from answer in
% http://tex.stackexchange.com/questions/166463/passing-just-other-options-when-using-pgfopts
\RequirePackage{pgfopts}

\def\cluu@classoptions{twoside=false,DIV=calc}

\def\cluu@fonts{}
\def\cluu@baseclass{scrartcl}
\def\cluu@minmarg{0pt}
\newtoggle{thesis}
\togglefalse{thesis}
\newtoggle{bachelor}
\newtoggle{wide}
\newtoggle{xwide}

\newcommand\cluu@initthesis{
  \def\cluu@fonts{uu}
  \def\cluu@baseclass{scrreprt}
  \toggletrue{thesis}
}

\pgfkeys{
  /cluu/.cd,
  % lang/.store in=\cluu@mainlang,
  % lang/.default=sv,
  marg/.store in=\cluu@minmarg,
  marg/.default=1cm,
  wide/.code = {
    \toggletrue{wide}
  },
  xwide/.code = {
    \toggletrue{xwide}
  },
  % thesis/.store in=\cluu@thesis, [ no, do more than that ]
  thesis/.code={
    \ClassWarning{cluu}{doing thesis}
    \def\cluu@thesis{#1}
    \def\cluu@fonts{uu}
    \def\cluu@baseclass{scrreprt}
    \toggletrue{thesis}
  },
  thesis/.default=master,
  thesis/.is choice,
  thesis/master/.code = {
    \cluu@initthesis
    \togglefalse{bachelor}
  },
  thesis/bachelor/.code = {
    \cluu@initthesis
    \toggletrue{bachelor}
  },
  % Set fonts afterwards, since in some cases several options can
  % influcence the call.
  fonts/.store in=\cluu@fonts,
  %% unknown keys are assumed to be options to the parent class
  %% (paper, pagesize and some more should be sent to typearea instead.)
  .unknown/.code={
    \ifx\pgfkeyscurrentvalue\pgfkeysnovalue@text
    \def\cluu@addval{\pgfkeyscurrentname}
    \else
    \def\cluu@addval{\pgfkeyscurrentname=\pgfkeyscurrentvalue}
    \fi
    \edef\cluu@classoptions{\cluu@classoptions,\cluu@addval}}
}
\ProcessPgfOptions{/cluu}

\ifdefstring{\cluu@baseclass}{scrartcl}{%
  \LoadClass[\cluu@classoptions]{scrartcl}}{%
  \LoadClass[\cluu@classoptions,titlepage=false]{scrreprt}}
% \PassOptionsToPackage{paper=a5,pagesize}{typearea}

% Patch caption to not add ":" if empty
% https://tex.stackexchange.com/questions/473159/empty-captions-with-koma-script-and-hyperref
\patchcmd\@@makecaption{\begingroup}
{%
 \settowidth{\@tempdima}{#3}%
 \ifdim\@tempdima=0pt
  \def\captionformat{}%
 \fi
  \begingroup
}{}{\fail}

% What fonts?
\ifdefvoid{\cluu@fonts}{%
  \def\cluu@fonts{libertine}}{}

\ifdefstring{\cluu@fonts}{none}{}
{%
  \ifdefstring{\cluu@fonts}{times}{%
    \usepackage[osf]{newtxtext}
    \usepackage[bigdelims]{newtxmath}
    \usepackage[scaled=0.87]{helvet}
  }
  {%
    \ifdefstring{\cluu@fonts}{uu}{%
      \usepackage{uufonts}
    }
    {%
      \ifdefstring{\cluu@fonts}{palatino}{%
        \usepackage[osf]{mathpazo}
        \linespread{1.05}
        \usepackage[scaled=0.88]{helvet}
        % \usepackage{courier}
        % Not needed, because use sffamily there anyway
        % \preto\@tabular{\fontfamily{pplx}\selectfont}
      }
      {%
        \ifdefstring{\cluu@fonts}{libertine}{%
          % If using libertine monospace, then ttscale=0.875,
          % because it's so big otherwise.
          % But prefer some other font.
          \usepackage[osf,semibold]{libertine}
          % Inconsolata doesn't have italics
          % \usepackage[varqu,varl]{z14} % inconsolata
          % beramono needs scaling.
          % scaled=0.83 according to "Herbert" at
          % http://tex.stackexchange.com/a/71346/48251
          % but here even smaller is preferred.
          % Setting the height of "x" the same yields scaled=0.746.
          % Setting the height of "m" the same yields scaled=0.804.
          \usepackage[scaled=0.804]{beramono}
          % TXTT also looks good with Libertine:
          % \renewcommand*\ttdefault{txtt}
          \usepackage[libertine]{newtxmath}
        }{%
          \ifdefstring{\cluu@fonts}{fourier}{%
            \usepackage{fourier}
            \usepackage[scaled=0.875]{helvet}
            \renewcommand{\ttdefault}{lmtt}
          }{%
            \ifdefstring{\cluu@fonts}{lm}{%
              \usepackage{lmodern}
            }{%
              \ClassError{cluu}{Unknown value for keyword fonts}{}
            }}}}}}}

\normalfont % Use when processing fontsize, for instance

% Packages

\RequirePackage{microtype}
\RequirePackage{graphicx}
\RequirePackage{booktabs}

\let\note\footnote

\RequirePackage{xcolor}
% Load hyperref in simplest possible way, to avoid option clashes.
% In particular I had problems with bookmark.sty loaded implicitly
% by menukeys.sty.
\RequirePackage{hyperref}
\urlstyle{same}
\AtEndPreamble{
  \hypersetup{citecolor=black,linkcolor=black,urlcolor=blue!50!black}
  % We want this as well, but it doesn't work with menukeys.
  % Then instead use option "hyperrefcolorlinks" with menukeys.
  \@ifpackageloaded{menukeys}{%
    \@ifpackagewith{menukeys}{hyperrefcolorlinks}{}{%
      \ClassWarning{cluu}{can't do colorlinks for hyperref when package menukeys is used. You can activate it with the option hyperrefcolorlinks to menukeys}}
  }{\hypersetup{colorlinks}}

  \@ifpackageloaded{babel}{%
    \RequirePackage[babel]{csquotes}}{%
    \RequirePackage{csquotes}}
  \let\q\enquote
}

\providecommand*{\coursename}{Course}
\newcommand\course[1]{\titlehead{\coursename: #1}}
\providecommand*{\deptname}{Department of Linguistics and Philology}
\providecommand*{\univname}{Uppsala University}
\providecommand*{\masterprogramname}{Master Programme in Language Technology}
\providecommand*{\masterthesisname}{Master's Thesis in Language Technology}
\providecommand*{\bachelorprogramname}{Language Technology Programme}
\providecommand*{\bachelorthesisname}{Bachelor's Thesis in Language Technology}
\providecommand*{\supervisorname}{Supervisor}
\providecommand*{\supervisorsname}{Supervisors}
\providecommand*{\creditsname}{\textsc{ects} credits}

\AtBeginDocument{%
  \@ifpackagewith{babel}{swedish}{%
    % Strömquist: "Om du skriver på svenska bör du använda benämningen
    % sammandrag. Ordet sammanfattning har en tendens att bli
    % missförstått."
    \addto\captionsswedish{\renewcommand*\abstractname{Sammandrag}}%
    \addto\captionsswedish{\renewcommand*\coursename{Kurs}}%
    \addto\captionsswedish{\renewcommand*\deptname{Institutionen för
        lingvistik och filologi}}%
    \addto\captionsswedish{\renewcommand*\univname{Uppsala universitet}}%
    \addto\captionsswedish{\renewcommand*\masterprogramname{Masterprogrammet
        i språkteknologi}}%
    \addto\captionsswedish{\renewcommand*\masterthesisname{Masteruppsats
        i språkteknologi}}%
    \addto\captionsswedish{\renewcommand*\bachelorprogramname{Språkteknologiprogrammet}}%
    \addto\captionsswedish{\renewcommand*\bachelorthesisname{Kandidatuppsats
        i språkteknologi}}%
    \addto\captionsswedish{\renewcommand*\supervisorname{Handledare}}%
    \addto\captionsswedish{\renewcommand*\supervisorsname{Handledare}}%
    \addto\captionsswedish{\renewcommand*\creditsname{\textsc{ects}-krediter}}%
  }{}
  \@ifpackagewith{babel}{english}{%
    \addto\captionsenglish{\renewcommand*\coursename{Course}}%
    \addto\captionsenglish{\renewcommand*\deptname{Department of Linguistics and Philology}}%
    \addto\captionsenglish{\renewcommand*\univname{Uppsala universitet}}%
    \addto\captionsenglish{\renewcommand*\masterprogramname{Master Programme in Language Technology}}%
    \addto\captionsenglish{\renewcommand*\masterthesisname{Master's Thesis in Language Technology}}%
    \addto\captionsenglish{\renewcommand*\bachelorprogramname{Language Technology Programme}}%
    \addto\captionsenglish{\renewcommand*\bachelorthesisname{Bachelor's Thesis in Language Technology}}%
    \addto\captionsenglish{\renewcommand*\supervisorname{Supervisor}}%
    \addto\captionsenglish{\renewcommand*\supervisorsname{Supervisors}}%
    \addto\captionsenglish{\renewcommand*\creditsname{\textsc{ects} credits}}%
  }{}
}

\iftoggle{thesis}{%
  %%% thesis: titlepage
  \renewcommand\maketitle{%
    \thispagestyle{empty}%
    \bgroup%
    \parindent=0pt
    \vglue-\headheight\vglue-\headsep\vglue-\topmargin\vglue-1in%
    \hglue-\oddsidemargin\hglue-1in\hglue-\parindent%
    \sffamily
    \hbox{%
      \raisebox{0pt}[20mm][0pt]{\vtop to 293mm{%
          \hbox{\includegraphics{UU_logo_pc_2f_42}}%
          \vfil
          \hbox{\includegraphics[width=42mm]{UU_marginalsigill_5Svart}}}}%
      % \raisebox{42mm}[0pt][0pt]{\vrule depth \paperheight}%
      \raisebox{44mm}[0pt][0pt]{\vrule depth \paperheight}%
      \hspace{8mm}%
      \raisebox{0mm}[0pt][0pt]{%
        \vtop to 25mm{%
          \hsize=110mm            % 111 yields overfull box
          \vskip 40\p@
          \begin{flushleft}
            \fontsize{25}{30}\selectfont\textbf{\@title} \par
            \ifx\@subtitle\undefined
            \else
            \vskip 6mm
            \fontsize{17}{22}\selectfont\textit{\@subtitle}
            \fi
            \vskip 14mm
            \fontsize{17}{22}\selectfont\@author\par
          \end{flushleft}%
          \vfil
          \fontsize{11}{13.6}\selectfont
          % (Include the name of the university since it's only
          % in Swedish in the logo.)
          \univname\\
          \deptname\\
          \iftoggle{bachelor}{
            \bachelorprogramname\\
            \bachelorthesisname%
          }{%
            \masterprogramname\\
            \masterthesisname%
          }%
          \ifx\@credits\undefined
          \else
          , \@credits\,\creditsname
          \fi
          \\[1ex]
          \@date
          \vskip 3mm
          \ifx\@supervisors\undefined
          \ifx\@supervisor\undefined
          \else
          \par
          \supervisorname: \\
          \@supervisor
          \fi
          \else
          \par
          \supervisorsname: \\
          \@supervisors
          \fi
        }}}%
    \egroup
    \rmfamily
    \clearpage
  }
  
  %%% thesis: abstract
  
  \RequirePackage{abstract}
  
  % Abstract:
  
  % This is @bstr@ctlist from abstract.sty (version 1.2a), with
  % three changes:
  % * Add \thispagestyle{empty}
  % * Set zero \itemindent instead of \listparindent.
  % (= Don't indent first paragraph.)
  % * Do \bigskip afterwards (in case there are several abstracts)
  
  \renewenvironment{@bstr@ctlist}{%
    \list{}{%
      \thispagestyle{empty}
      %% \topsep        \z@
      \partopsep     \z@
      \listparindent \absparindent
      %%% \itemindent    \listparindent
      \itemindent	 \z@
      \leftmargin    \absleftindent
      \rightmargin   \absrightindent
      \parsep        \absparsep}%
  \item\relax}
  {\endlist\bigskip}

  \newcommand{\supervisor}[1]{\gdef\@supervisor{#1}}
  \newcommand{\supervisors}[1]{\gdef\@supervisors{#1}}
  \newcommand{\credits}[1]{\gdef\@credits{#1}}
  \iftoggle{bachelor}{%
    \credits{15}%
  }{%
    \credits{30}%
  }
}{%
  % Not thesis
  \renewcommand{\@maketitle}{%
    \thispagestyle{empty}%
    \bgroup%
    \parindent=0pt
    \parskip=0pt
    \vglue-\headheight\vglue-\headsep\vglue-\topmargin\vglue-1in%
    % \hglue-\oddsidemargin\hglue-1in\hglue-\parindent%
    \sffamily
    \begin{flushleft}
      \ifdefempty{\@titlehead}
      {}
      {{\usekomafont{titlehead}{\strut\@titlehead\par}}%
        \hrule\bigskip}
      {\usekomafont{title}{\huge\strut\@title\par}}%
      \ifdefempty{\@subtitle}
      {}
      {\smallskip
        {\usekomafont{subtitle}{\strut\@subtitle\par}}}%
      \bigskip
      \ifdefempty{\@author}
      {}
      {{\usekomafont{author}\strut\@author\par}}
      \medskip
      \usekomafont{date}{\@date\par}
      \ifdefempty{\@publishers}{}
      {\medskip
        {\usekomafont{publishers}\strut\@publishers}}
      \bigskip
    \end{flushleft}%
    \egroup
    % \rmfamily
    \FloatBarrier
  }

  % Don't indent after title
  % (In case there is text before the first heading)
  \appto{\@maketitle}{%
    \aftergroup\@afterindentfalse
    \aftergroup\@afterheading
  }
}

\addtokomafont{caption}{\small\sffamily}
\addtokomafont{captionlabel}{\sffamily\bfseries}
\addtokomafont{disposition}{\mdseries\sffamily} % \color{cluu@titlecolor}}

\setkomafont{title}{\bfseries}
\setkomafont{subtitle}{\itshape\large}
\setkomafont{author}{\Large}


% Don't indent after title
% (In case there is text before the first heading)
\appto{\@maketitle}{%
  \aftergroup\@afterindentfalse
  \aftergroup\@afterheading
}

% Don't indent abstract
\patchcmd{\abstract}%
  {\quotation}{\quotation\noindent\ignorespaces}{}{}

% And don't indent after abstract
% (In case there is text before the first heading)
\pretocmd{\abstract}{\begingroup}{}{}
\apptocmd{\endabstract}{\aftergroup\@afterheading\endgroup}

% TODO: In twocolumn mode, add some space after the abstract,
% in case there is no header there.

% as stpthesis:
% \aliaspagestyle{title}{empty}

%%% \maxsecnumdepth{subsection}

% \renewcommand{\secheadstyle}{\LARGE\sffamily\raggedright}
% \renewcommand{\subsecheadstyle}{\Large\sffamily\raggedright}
% \renewcommand{\subsubsecheadstyle}{\large\sffamily\bfseries\raggedright}

%  \makepagestyle{cluu}
%  \if@twoside
%  \copypagestyle{cluu}{headings}
%  \else
%  % \makeoddhead{cluu}{\slshape\rightmark}{}{}
%  % \makeoddfoot{cluu}{}{\thepage}{}
%  \copypagestyle{cluu}{plain}
%  \fi
%  \pagestyle{cluu}

% === Page layout ===

% Default for columnsep is 10pt, but let it depend on font size.
% http://tex.stackexchange.com/questions/69809/is-there-a-rule-of-thumb-to-set-the-space-between-columns
\setlength{\columnsep}{1em}

% Default for marginparsep is 1cc = 12dd, but let it depend on font
% size.
\setlength{\marginparsep}{0.8em}

% Determine good line length as "typearea" does it, but use it
% differently.
\newlength{\cluu@goodwidth}
\ta@temp@goodwidth % sets \ta@temp to width of 66 small letters + 3 capitals
% Let's allow a little bit wider by default
\setlength{\cluu@goodwidth}{1.8\ta@temp}

\iftoggle{xwide}{
  \setlength{\cluu@goodwidth}{1.5\cluu@goodwidth}
}{\iftoggle{wide}{
  \setlength{\cluu@goodwidth}{1.5\cluu@goodwidth}
}}

\if@twocolumn
  \addtolength{\cluu@goodwidth}{\cluu@goodwidth}%
  \addtolength{\cluu@goodwidth}{\columnsep}%
\fi

% Use that width if there is room for it.
\newlength{\cluu@minfromedge}
\setlength{\cluu@minfromedge}{17mm}

\newlength{\cluu@temp}
\newlength{\cluu@tempb}
\newlength{\cluu@smallmarg}
\newlength{\cluu@leftmarg}

\newlength{\cluu@room}
\setlength{\cluu@room}{\paperwidth}
\addtolength{\cluu@room}{-\cluu@goodwidth}
% Remove twice, because we want at least this space
% outside of the marg text.
\addtolength{\cluu@room}{-2\cluu@minfromedge}
\ifdim\cluu@minmarg = 0pt
  % Then don't need to make room for marginparsep
\else
  \addtolength{\cluu@room}{-\marginparsep}
  \addtolength{\cluu@room}{-\cluu@minmarg}
  \if@twocolumn
    % Then the other marg as well
    \addtolength{\cluu@room}{-\marginparsep}
    \addtolength{\cluu@room}{-\cluu@minmarg}
  \fi
\fi

% Did everything fit?
\ifdim\cluu@room <0pt
  % No. Then we have to decrease the textwidth.
  \setlength{\textwidth}{\cluu@goodwidth}
  \addtolength{\textwidth}{\cluu@room}
  \setlength{\marginparwidth}{\cluu@minmarg}
  \if@twocolumn
    \setlength{\cluu@smallmarg}{\cluu@minfromedge}
    \setlength{\cluu@leftmarg}{\cluu@smallmarg}
    \addtolength{\cluu@leftmarg}{\cluu@minmarg}
    \addtolength{\cluu@leftmarg}{\marginparsep}
  \else
    \setlength{\cluu@smallmarg}{\cluu@minfromedge}
    \setlength{\cluu@leftmarg}{\cluu@smallmarg}
  \fi
\else
  % There is room for everything.
  \setlength{\textwidth}{\cluu@goodwidth}
  \if@twocolumn
    % We have room to spare. Increase both sides the same amount.
    \setlength{\cluu@temp}{\cluu@room}
    \divide\cluu@temp by2
    \setlength{\cluu@smallmarg}{\cluu@minfromedge}
    \setlength{\cluu@leftmarg}{\cluu@smallmarg}
    \addtolength{\cluu@leftmarg}{\cluu@minmarg}
    \addtolength{\cluu@leftmarg}{\marginparsep}
    \addtolength{\cluu@leftmarg}{\cluu@temp}
    \setlength{\marginparwidth}{\cluu@minmarg}
    \addtolength{\marginparwidth}{\cluu@temp}
    %%\addtokomafont{disposition}{\color{red}}
  \else
    \ifdim\cluu@minmarg >0pt
      % Make room for that margin by using most of the extra space
      % for that, and only a small part to increase the small margin.
      \setlength{\cluu@temp}{\cluu@room}
      % Use 1/4 (arbitrarily) to increase the small margin
      \setlength{\cluu@tempb}{\cluu@temp}
      \divide\cluu@tempb by4
      \addtolength{\cluu@temp}{-\cluu@tempb}
      \setlength{\cluu@smallmarg}{\cluu@minfromedge}
      \addtolength{\cluu@smallmarg}{\cluu@tempb}
      \setlength{\cluu@leftmarg}{\cluu@smallmarg}
      % And the rest to increase margin notes
      \setlength{\marginparwidth}{\cluu@minmarg}
      \addtolength{\marginparwidth}{\cluu@temp}
    \else
      \setlength{\cluu@temp}{\cluu@room}
      \divide\cluu@temp by2
      \setlength{\cluu@smallmarg}{\cluu@minfromedge}
      \setlength{\cluu@leftmarg}{\cluu@smallmarg}
      %\addtolength{\cluu@leftmarg}{\cluu@minmarg}
      %\addtolength{\cluu@leftmarg}{\marginparsep}
      \addtolength{\cluu@leftmarg}{\cluu@temp}
      %\setlength{\marginparwidth}{\cluu@minmarg}
      %\addtolength{\marginparwidth}{\cluu@temp}
    \fi
  \fi
\fi    

% That "small margin" is used as inner and top margins.
% Bottom margin was set with vmarginratio=2:3, but sometimes
% it's too small, so calculate it explicitly instead.
\newlength{\cluu@bottommarg}
\setlength{\cluu@bottommarg}{1.4\cluu@smallmarg}
\setlength{\cluu@temp}{\footskip}
\addtolength{\cluu@temp}{\cluu@minfromedge}
\ifdim\cluu@temp >\cluu@bottommarg
  \setlength{\cluu@bottommarg}{\cluu@temp}
\fi

\RequirePackage[
  % a4paper,
  width=\textwidth,
  marginparwidth=\marginparwidth,
  left=\cluu@leftmarg,
  top=\cluu@smallmarg,
  % vmarginratio=1:2,
  bottom=\cluu@bottommarg,
  heightrounded,
  showframe=false,
  % hmarginratio=\value{m1}:\value{m2},
  % hmarginratio=1:2,
  % nohead,
  ]{geometry}
