# hardsub.sh

###############################################################################<br>
This is a simple command line shell script to hardsub
a subtitle track onto a video.

It is being developed under Fedora 34 linux, and should be portable to other
linux distros, Apple, and possibly Windows with the proper support toolbox.

This script is buggy, not well documented (yet), and under active development --
use at your own risk.

#### Rational
I want to watch some media on my olde Samsung TV.
It can barely handle SRT subtitles and has no knowlegde of Substation *anything*!
Also, it (as far as I know) can't play flac or anything above yuv420p for x264.

#### Design Philosophy
The script is meant to run as simply as possible without setting a lot of
command line options to get anything to work.  For most use cases, no options
or very few options are needed.  The idea is that this script can be used in
a "batch" mode with many different types of source videos to produce a
reasonable batch of output files in a unified video container.

## Getting Started
For now, until *real* help is written, just execute <code>./hardsub</code>
to get a simple command line snippet to run --<br>
```
./hardsub.sh
USAGE ::
 ls *.flv *.avi *.mkv *.mp4 *.webm *.ts *.mpg *.vob 2>/dev/null | while read yy ; do ./hardsub.sh "${yy}" ; done
```

It uses the <strong>MP4</strong> video container for the re-encoded video and
saves the video in the directory specified by the <code>G_VIDEO_OUT_DIR</code>.

Some directories need to be built --
look through the script (for now) to see which ones:
```
G_VIDEO_OUT_DIR='OUT DIR' ; # --out-dir=
C_SUBTITLE_OUT_DIR='./SUBs' ;
C_FONTS_DIR="${HOME}/.fonts" ;
C_SUBTITLE_IN_DIR='IN SUBs' ;
```

## Subtitles
Two types of subtitles are supported:
SubRip (SRT) and Advanced Substation Alpha (ASS).<br>

If a video contains a subtitle *track*, the script can perform edits on the
script before passing it along to <code>ffmpeg</code>.
Generally, for a *lyrical* subtitle, you probably would NOT make any changes
(and it doesn't), but for other types of subtitles, changing the font,
its size, and/or it colour can really improve the readability of the text.<br>
Some of these text attributes are configurable on the command line
(e.g. <code>--font-size=</code>), and
more complex changes will have to be made in the script (for now).

## Prerequisites and Required Tools

These are the tools needed to run this script.
The script (right now) assumes their installation and will probably just
die if anything is missing.

- ffmpeg
- mkvtoolnix
- sed + pcre2 (the library)
- coreutils -- basename, cut, head, et. al.
- grep, egrep
- jq  (developed and tested with version 1.6)
- dos2unix
- bash shell - unless you're going with a really old distro, the version of
    bash installed is probably modern enough for this script.<br>
    No special advanced bash features are intentionally used in
    this script (except for array append, but that 1st appeared
    in 3.1x or thereabouts).  This script used bash-5.1.0 in
    its development.
- exiftool - used in this script to get/copy metadata from the source
    video to the re-encoded video.
    exiftool is a perl script, so (obviously) <strong>perl</strong> needs to be
    installed along with any additional supporting libraries.
- agrep + libtre - used to help identify if a garbage title was encoded in the
    original source video (still in development).
    Recent Fedora distros have an 'agrep' package which links
    with 'libtre' and can be optionally installed; other distros
    may require building from source.<br>
    https://github.com/Wikinaut/agrep
 
Most of the above are probably installed in the distro's base installation.
