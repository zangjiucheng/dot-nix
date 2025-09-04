# UW NoteStyle

My LaTeX styles for University of Waterloo (3A term, v2). Two different style systems available.

## Usage

**Assignment style (single package):**
```latex
\usepackage{assignmentstyle}    % or [nogeometry] to skip geometry
```

**Note style (modular system):**
```latex
\usepackage{notestyle-all}      % load all modules, or [nolayout] to skip geometry
```

**Pick note style components:**
```latex
\usepackage{notestyle-base}     % required first
\usepackage{notestyle-boxes}    % theorems, proofs, definitions
\usepackage{notestyle-math}     % math shortcuts
% + others: layout, sections, code, quotes, tikz, colors
```

## Install

```sh
bash install.sh                # install to local texmf
bash install.sh --uninstall    # remove
bash install.sh --help         # more options
```
