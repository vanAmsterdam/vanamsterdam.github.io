# utility function for knitting rmd files; 
# source: eeholmes.github.io

rmd_to_gfm = function(filename, pdf=FALSE){
  require(here); require(knitr)
  inFile = paste0(here("posts", "Rmd"), "/", filename)
  outFile = paste0(here("_posts"), "/", sub("Rmd", "md", filename))
  figDir = paste0(here("posts", "figures"), "/", sub("[.]Rmd", 
                                                     "", filename), "/")
  opts_chunk$set(fig.path = figDir)
  knit(inFile, output = outFile)
  opts_chunk$set(fig.path = "figure/")
  pdfDir = here("posts", "pdfs")
  if (pdf) 
    render(inFile, output_format = "pdf_document", output_dir = pdfDir, 
           clean = TRUE)
}