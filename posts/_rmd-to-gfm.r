# utility function for knitting rmd files; 
# source: eeholmes.github.io

# get cwd to replace absolute filenames from figure filenames in md file (this is a hack)
# cwd = get_wd()
wd = '/Users/vanAmsterdam/git/vanamsterdam.github.io'
wd = paste0(cwd, '/') 

rmd_to_gfm = function(filename, pdf=FALSE, cwd='/Users/vanAmsterda/git/vanamsterdam.github.io'){
  require(here); require(knitr); require(stringr)
  inFile =  here("posts", "Rmd", filename)
  outFile = sub("Rmd", "md", filename)
  outPath = here("_posts", outFile)
  figDir =  paste0(here("posts", "figures", sub("[.]Rmd", 
                                               "", filename)), "/")
  opts_chunk$set(fig.path = figDir)
  knit(inFile, output = outFile)
  file.rename(outFile, outPath)
  # postprocess figure filenames (this is a hack)
  f  <- readLines(outPath)
  f2 <- str_replace_all(f, cwd, "")
  writeLines(f2, con=outPath)

  pdfDir = here("posts", "pdfs")
  if (pdf) {
    stop('not implemented yet, need to manage the filenaming blizzard')
    render(inFile, output_format = "pdf_document", output_dir = pdfDir, 
           clean = TRUE)
  }
} 