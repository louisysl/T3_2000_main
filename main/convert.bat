:: PANDOC.exe PATH LAPTOP: "C:\Users\a798583\AppData\Local\Programs\Python\Python310\Scripts\pandoc-fignos.exe"
pandoc "C:\Users\a798583\OneDrive - Atos\Desktop\PA2022\main\PA2022.md" -f markdown -t latex --template "C:\Users\a798583\OneDrive - Atos\Desktop\PA2022\main\tex\template.tex" --filter "C:\Users\a798583\AppData\Local\Programs\Python\Python310\Scripts\pandoc-fignos.exe" --toc --toc-depth=6 -N --citeproc --bibliography "C:\Users\a798583\OneDrive - Atos\Desktop\PA2022\main\t3_2000.bib" --csl "C:\Users\a798583\OneDrive - Atos\Desktop\PA2022\main\tex\thieme-german.csl" --pdf-engine=xelatex --mathjax 
if %errorlevel% neq 0 exit /b %errorlevel% 
"Projektarbeit.pdf"

:: pdf open (edit in pandoc line) -o "Projektarbeit.pdf"