# UW NoteStyle

My note style for University of Waterloo (3A term, v2). Modular LaTeX components.

## Usage

**Load everything:**
```latex
\usepackage{notestyle-all}      % or [nolayout] to skip geometry
```

**Pick components:**
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
