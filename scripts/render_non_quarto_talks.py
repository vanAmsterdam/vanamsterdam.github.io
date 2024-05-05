
"""
render_non_quarto_talks.py

This script is used to render non-quarto talks into image-based talks. It takes PDF files as input and converts them into individual slide images. It also creates a dummy quarto presentation file with the individual slide images as pages.

Usage:
    python render_non_quarto_talks.py [-v] [-f]

Options:
    -v, --verbose   Run in verbose mode.
    -f, --force     Re-render slides even if separate PNG slides exist.

Dependencies:
    - pdftk: Used to burst PDF files into individual slides.
    - mogrify: Used to convert PDF slides to PNG format.

"""

import subprocess, os, shutil
from pathlib import Path
import logging as log
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('-v', '--verbose', action='store_true', help="run in verbose mode")
parser.add_argument('-f', "--force", action='store_true', help="re render slides even if separate png slides exist")


def render_pdf(p: Path, force=False):
    """
    Renders a PDF file into individual slide images and creates a dummy quarto presentation file.

    Args:
        p (Path): The path to the PDF file.
        force (bool, optional): If True, forces the rendering process even if the slide images already exist. 
                                Defaults to False.
    """
    log.info(p)
    
    # burst pdf into slides
    _burst_pdf(p, force)

    # write a dummy quarto presentation file with just the individual slide images as pages
    _create_dummy_quarto(p)

def _burst_pdf(p: Path, force=False):
    """
    Burst a PDF file into individual slides and convert them to PNG format.

    Args:
        p (Path): The path to the PDF file.
        force (bool, optional): If True, force the burst and conversion even if the slides already exist. Defaults to False.
    """
    
    pdfdir = p.parent / "pdfslides"
    pngdir = p.parent / "pngslides"
    pngs_exists = False
    pdfs_exists = False
    if pngdir.exists():
        if len(list(pngdir.glob("page_*.png"))) > 0:
            pngs_exists = True
    else:
        os.mkdir(pngdir)

    if pdfdir.exists():
        pdfpaths = list(pdfdir.glob("page_*.pdf"))
        if len(pdfpaths) > 0:
            pdfs_exists = True
    else:
        os.mkdir(pdfdir)

    # split to pdf slides
    if force or (not pdfs_exists):
        log.info("bursting pdf to individual slides")
        outformat = f"{pdfdir}/page_%03d.pdf"
        subprocess.call(["pdftk", str(p), "burst" ,"output", outformat])
    
    # convert to pngs
    if force or (not pngs_exists):
        log.info("converting pdf slides to png")
        _cwd = os.getcwd()
        os.chdir(pdfdir)
        subprocess.call(["mogrify", "-format", "png", "-density", "300", "*.pdf"])
        os.chdir(_cwd)

        # move pngs
        pngpaths = pdfdir.glob("page*.png")
        for pngp in pngpaths:
            pngp.rename(pngdir / pngp.name)


def _create_dummy_quarto(p: Path):
    """
    Create a dummy Quarto file for rendering non-Quarto talks.

    Args:
        p (Path): The path to the file.

    Returns:
        None
    """
    d = p.parent
    _cwd = os.getcwd()
    os.chdir(d)
    try:
        pngpaths = list((Path() / "pngslides").glob("page_*.png"))
        assert len(pngpaths) > 0, f"pngslides subdirectory has no slides, something is wrong, {p}"
        # sort the pngpaths by ascending filename
        sortedpngpaths = sorted(pngpaths, key = lambda x: x.name)
        qpath = Path("index.qmd")
        if qpath.exists():
            log.info(f"quarto file {qpath} exists, overwriting")
            qpath.unlink()

        # check if there are custom headerlines, or create them
        if Path("_quartoheader.qmd").exists():
            shutil.copy(Path("_quartoheader.qmd"), qpath)
        else:
            qpath.touch()

            headerlines = [
                "---",
                """footer: "" """,
                    "output: revealjs",
                    "---",
                    ""]

            with open(qpath, "a") as f:
                f.write("\n".join(headerlines))
        
        # write individual lines for all png slides
        with open(qpath, "a") as f:
            for pngp in sortedpngpaths:
                f.write(f"\n## {{background-image={pngp} background-size=contain background-repeat=no-repeat}}")
        
    finally:
        os.chdir(_cwd)

if __name__ == "__main__":
    args = parser.parse_args()

    if args.verbose:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
    else:
        log.basicConfig(format="%(levelname)s: %(message)s")
    log.info("rendering non-quarto talks for slides in subdirs of talks/")

    # check all talk subdirs
    talkdirs = [d for d in Path("talks").glob("*") if d.is_dir()]

    # check which have a slides.pdf
    pdfpaths = [d / "slides.pdf" for d in talkdirs]
    pdfpaths = [p for p in pdfpaths if p.exists()]

    for p in pdfpaths:
        render_pdf(p, args.force)