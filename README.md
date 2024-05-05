# Website of Wouter van Amsterdam

built with quarto

instruction to self:

- make a post in posts like the others
- commit and push to branch (for backup)
- run `quarto publish gh-pages` to update webpage

## basic requirements

need these for rendering pptx to quarto: 

- imagemagic (for morgrify)
- pdftk
- python3

## rendering pptx presentations

1. save slides.pptx in a subdir of talks
2. split each animation to separate slide with ppsplit
  - ppsplit source is in resources dir, otherwise use [download link](https://github.com/maxonthegit/PPspliT/raw/master/src/PPT12%2B/PPspliT.ppam)
  - [installing](https://github.com/maxonthegit/PPspliT?tab=readme-ov-file#manual-installation)
  - [usage](https://github.com/maxonthegit/PPspliT?tab=readme-ov-file#usage)
3. save as `slides.pdf`
4. write a custom header with title and date info in a file called  \_quartoheader.qmd
5. run `make render-talks-pdf`
6. add the created index.qmd and png files in pngslides to git (and possibly the pdf)
