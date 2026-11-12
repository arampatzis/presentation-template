# Talks: common tasks. A talk is given by folder name, e.g. `just build example`.
# The theme and the logos are found through TEXINPUTS, so a talk folder needs no copies of them.

texinputs := justfile_directory() + "//:"

# List the available recipes
default:
    @just --list

# Build the slides and the notes version of a talk
all n fmt="": (build n fmt) (notes n fmt)

# Build the slides (two passes, for page numbers); fmt=43 gives the standard format
build n fmt="": figures
    @just _compile {{n}} {{n}} "{{fmt}}"

# Build the notes version (slides left, notes right)
notes n fmt="": figures
    @just _compile {{n}} {{n}}-notes "{{fmt}}"

# Compile <folder>/<file>.tex twice into <folder>/build; a format sets \aspect and the PDF name
_compile n file fmt:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{n}}"
    mkdir -p build
    fmt="{{fmt}}"
    f="{{file}}"
    job="{{file}}${fmt:+-$fmt}"
    pre=""
    [ -n "$fmt" ] && pre="\\def\\aspect{$fmt}"
    for i in 1 2; do
        TEXINPUTS="{{texinputs}}" lualatex -interaction=nonstopmode -halt-on-error \
            -output-directory=build -jobname="$job" "$pre\\input{$f.tex}" > /dev/null \
            || { grep -A5 "^!" "build/$job.log"; exit 1; }
    done
    echo "built {{n}}/build/$job.pdf"
    grep "Overfull" "build/$job.log" || true

# Compile the TikZ figures whose PDF is missing or older than the source
figures:
    #!/usr/bin/env bash
    set -euo pipefail
    cd tikz
    for f in *.tex; do
        [ "$f" = tikz-preamble.tex ] && continue
        pdf="${f%.tex}.pdf"
        if [ ! -f "$pdf" ] || [ "$f" -nt "$pdf" ] || [ tikz-preamble.tex -nt "$pdf" ]; then
            lualatex -interaction=nonstopmode -halt-on-error "$f" > /dev/null \
                || { grep -A5 "^!" "${f%.tex}.log"; exit 1; }
            rm -f "${f%.tex}".{aux,log}
            echo "compiled tikz/$pdf"
        fi
    done

# Start a new talk folder from the example
new n:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -e {{n}} ] && { echo "{{n}} exists"; exit 1; }
    mkdir {{n}}
    cp example/example.tex {{n}}/{{n}}.tex
    sed 's/example/{{n}}/g' example/example-notes.tex > {{n}}/{{n}}-notes.tex
    echo "created {{n}}/{{n}}.tex"

# Present with pdfpc (notes on your screen)
present n:
    pdfpc --notes=right {{n}}/build/{{n}}-notes.pdf

# Make the theme available to every LaTeX document on this machine
install:
    mkdir -p ~/Library/texmf/tex/latex
    ln -sfn "{{justfile_directory()}}" ~/Library/texmf/tex/latex/uoc-beamer
    @echo "linked ~/Library/texmf/tex/latex/uoc-beamer"
