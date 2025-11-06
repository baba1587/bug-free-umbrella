# latexmk configuration for the LaTeX tutorial project

$pdf_mode = 1;
$pdflatex = 'xelatex -interaction=nonstopmode -synctex=1 %O %S';
$bibtex_use = 1;
$out_dir = 'build';
$aux_dir = 'build';

@default_files = ('main.tex');
