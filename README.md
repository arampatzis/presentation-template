# Presentation template

Beamer theme `uoc` for talks. It is the Metropolis theme restyled in navy and teal (the style of
the SciML course slides), with the University of Crete and FORTH logos on the title page and at the
bottom of every content slide. Talks are built with LuaLaTeX and `just`.

## Contents

| Path                        | What it is                                                         |
| --------------------------- | ------------------------------------------------------------------ |
| `beamerthemeuoc.sty`        | The theme: layout, fonts, colors, logos, helpers, presenter notes. |
| `logos/`                    | University of Crete (horizontal and seal) and FORTH logos.         |
| `tikz/`                     | Standalone TikZ figures and their shared `tikz-preamble.tex`.      |
| `example/example.tex`       | Example talk that uses every feature of the theme.                 |
| `example/example-notes.tex` | Notes version of the example (slide left, notes right).            |
| `justfile`                  | Build recipes.                                                     |

Compiled output goes to `<talk>/build/`, which git ignores.

## Requirements

- A TeX Live installation with LuaLaTeX, `beamertheme-metropolis`, `kpfonts-otf`, and `adjustbox`.
- [`just`](https://github.com/casey/just), to run the recipes (`brew install just`).
- Optional: [`pdfpc`](https://pdfpc.github.io), to present with notes on a second screen.

## Quick start

```sh
just new my-talk          # copy the example into my-talk/
# edit my-talk/my-talk.tex
just build my-talk        # my-talk/build/my-talk.pdf
just notes my-talk        # my-talk/build/my-talk-notes.pdf
just present my-talk      # pdfpc with the notes on your screen
```

The recipes set `TEXINPUTS` to this folder, so a talk folder needs no copy of the theme or the
logos. A talk folder must therefore sit inside this repository.

## Recipes

| Recipe                    | What it does                                                          |
| ------------------------- | --------------------------------------------------------------------- |
| `just new <talk>`         | Create `<talk>/<talk>.tex` and `<talk>/<talk>-notes.tex` from the example. |
| `just build <talk> [43]`  | Build the slides (two LuaLaTeX passes, for page numbers) and list overfull boxes. |
| `just notes <talk> [43]`  | Build the notes version.                                              |
| `just all <talk> [43]`    | Build both.                                                           |
| `just figures`            | Compile the TikZ figures whose PDF is missing or older than its source. `build` and `notes` run it first. |
| `just present <talk>`     | Open the notes version in pdfpc.                                      |
| `just install`            | Optional: link this folder into `~/Library/texmf/tex/latex/uoc-beamer`, so `\usetheme{uoc}` works for a talk anywhere on this machine. |

The optional `43` builds the standard format into `<talk>-43.pdf` (see the next section).

## Format: wide or standard

The class option sets the format. The theme uses lengths that are absolute or relative to
`\textwidth`, so it works with both formats unchanged.

```latex
\documentclass[aspectratio=169, 10pt]{beamer}  % wide, 16:9
\documentclass[aspectratio=43,  10pt]{beamer}  % standard, 4:3
```

The example writes the ratio as `\aspect`, with default `169`:

```latex
\providecommand{\aspect}{169}
\documentclass[aspectratio=\aspect, 10pt]{beamer}
```

To change the default of a talk, change `169` to `43` in that line. To build the other format once,
without editing the file, run `just build <talk> 43`: the recipe defines `\aspect` before the file
is read.

A figure drawn for 16:9 can be wider than a 4:3 slide. Include figures with
`\includegraphics[max width=\textwidth]{...}`: the figure keeps its natural size when it fits, and
is shrunk to the text width otherwise.

## Writing a talk

### Preamble

```latex
\providecommand{\aspect}{169}
\documentclass[aspectratio=\aspect, 10pt]{beamer}
\usetheme{uoc}
\ifdefined\shownotes                 % set by <talk>-notes.tex
  \usepackage{pgfpages}
  \setbeameroption{show notes on second screen=right}
\fi
\graphicspath{{../tikz/}}

\title{Title of the talk}
\subtitle{Venue or occasion}         % teal, under the title
\author{Georgios Arampatzis}
\institute{Department of Mathematics \& Applied Mathematics, University of Crete\\
  Institute of Applied \& Computational Mathematics, FORTH}
\date{\today}
```

Any of `\subtitle`, `\author`, `\institute`, and `\date` may be left empty; the title page then
omits that line.

### Theme option

`\usetheme[nofooterlogos]{uoc}` removes the logos from the bottom of the content slides. The title
page keeps them.

### Slides

- `\maketitle`: title page with both logos along the bottom.
- `\section{...}`: section page with a large two-digit number above the section title.
- `\begin{frame}{Title} ... \end{frame}`: content is top-aligned. Use `\begin{frame}[c]` for a
  frame that is mostly a figure.
- `\begin{frame}[fragile]`: needed for code listings (see the example for the `listings` style).
- `\begin{frame}[standout] ... \end{frame}`: navy slide for a closing message, without logos.
- `block` and `alertblock`: teal and orange boxes, for a theorem or a key result.

### Helpers

| Command           | Use                                                             |
| ----------------- | --------------------------------------------------------------- |
| `\term{...}`      | A key term at its definition: teal, bold.                       |
| `\alert{...}`     | The one thing not to miss: orange.                              |
| `\source{...}`    | Small gray line under a figure, table, or theorem: caption or source. |
| `\calc{...}`      | Supporting calculation right under a bullet: smaller, muted blue. |
| `\var{...}`       | A variable or data set name: teal monospace.                    |
| `\hlrow`          | At the start of a table row: highlights the row. Tables use `booktabs`. |

Logos inside a slide: `\uoclogo{<height>}`, `\uocseal{<height>}`, and `\forthlogo{<height>}`.

Colors defined by the theme, for text and figures: `navy`, `teal`, `teallight`, `accent` (orange),
`softgray`, and `calc`.

### Presenter notes

Write the notes after the frame they belong to:

```latex
\begin{frame}{Outline}
  ...
\end{frame}
\note[itemize]{
  \item What to say about this slide.
  \item \nextslide what comes next.
}
```

`\note{...}` takes plain text; `\note[itemize]{...}` takes `\item`s and spaces them out.
`\nextslide` prints a teal "Next:" label. The notes appear only in the notes version
(`<talk>-notes.tex`, which defines `\shownotes` and inputs the talk).

## Figures

Each TikZ figure is a standalone file in `tikz/` that starts with

```latex
\documentclass[tikz,border=2pt]{standalone}
\input{tikz-preamble}
```

`tikz-preamble.tex` loads the same fonts as the theme (`kpfonts-otf`), so labels match the slide
text. It also defines the node styles of the example figures (`inputnode`, `opnode`, `outputnode`,
`statenode`, `gatenode`, `opcircle`, `edge`, `backedge`, ...) and the symbols they use (`\bm`,
`\Real`, `\W`). Add a figure by writing `tikz/<name>.tex`; `just build` compiles it to
`tikz/<name>.pdf`. The PDFs are committed, so a fresh clone builds without recompiling them.

Include a figure at natural size, so its fonts keep the size of the text:

```latex
\begin{frame}[c]{Title}
  \centering
  \includegraphics[max width=\textwidth]{name}
  \source{What the figure shows.}
\end{frame}
```

The example figures come from the SciML lecture notes: reverse-mode automatic differentiation on a
small graph, an LSTM cell, a DeepONet, and a Fourier neural operator.

## Changing the theme

- Colors: the `\definecolor` lines under "Colors" in `beamerthemeuoc.sty`.
- Fonts: `\usepackage{kpfonts-otf}` under "Fonts"; change `tikz/tikz-preamble.tex` to match and
  run `just figures` after touching the preamble.
- Logos: replace the files in `logos/`, keeping their names, or change `\uoclogo`, `\uocseal`, and
  `\forthlogo` under "Logos". Their sizes on the title page and in the footer are set in the
  `title page` and `frame footer` templates in the same section.
