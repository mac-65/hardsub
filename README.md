# hardsub.sh

This is a simple command line shell script to hardsub
a subtitle track onto a video.

It is being developed under Fedora 34 linux, and should be portable to other
linux distros, Apple, and possibly Windows with the proper support toolbox.

This script is buggy, not well documented (yet), and under active development --
use at your own risk.

#### Rational
I want to watch some media on my olde Samsung TV.
It can barely handle SubRip subtitles and has no knowledge of Substation *anything*!
Also, it (as far as I know) can't play FLAC or anything above yuv420p for x264.

#### Design Philosophy
The script is meant to run as simply as possible without setting a lot of
command line options to get anything to work.  For most use cases, no options
or very few options are needed.  The idea is that this script can be used in
a "batch" mode with many different types of source videos to produce a
reasonable batch of output files in a unified video container.
I'm going for a *plug-n-play* type of application.

The script is 100% <code>/bin/bash</code> with lots of help from additional
utilities to do much of the heavy lifting (<code>ffmpeg</code>,
<code>mkvtoolnix</code>, and <code>jq</code> to name a few).
Bash should be widely available and
should be universally understood, so users should have no problems
adding any customizations to suit their needs.

As this script nears completion, I'll add examples to illustrate
the basic (and maybe some more advanced) functionality.

## Getting Started
For now, until *real* help is written, just execute <code>./hardsub</code>
to get a simple command line snippet to run --<br>
```
./hardsub.sh
USAGE ::
 ls *.flv *.avi *.mkv *.mp4 *.MP4 *.webm *.ts *.mpg *.vob *.VOB 2>/dev/null | while read yy ; do ./hardsub.sh "${yy}" ; done
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
Two types of *standard* subtitles are supported:
SubRip (SRT) and Advanced Substation Alpha (ASS).<br>

If a video contains an embedded subtitle *track*, the script can perform
edits on the script before passing it along to <code>ffmpeg</code>.

Generally, for a *lyrical* subtitle, you probably would NOT want to
make any changes (and it doesn't), but for other types of subtitles,
changing the font, its size, and/or it colour can really improve
the readability of the text.<br>
Some of these text attributes are configurable on the command line
(e.g. <code>--font-size=</code>), and
more complex changes will have to be made in the script (for now).

### Transcript Subtitle Feature (alpha)
The script has basic support for burning a transcript file as a subtitle.
This follows the same convention for external subtitle files by putting the
transcript file (except using a <code>.txt</code> filename extension) in
the <code>C_SUBTITLE_IN_DIR</code> which defaults to <code>'./IN SUBs'</code>.

It's a little klunky and not super-robust, but there's a real use for this
feature.  What I've found is that there are some neat videos in other languages
that have a translation transcript.  This allows for offline viewing.

#### Transcript Text Editing w/sed

Additionally, if a <code>sed</code> script is provided
(the basename of the video + '<b>.sed</b>' extension),
the <code>sed</code> script will be run on each line of the <code>Text</code>
field of the subtitle line.  While all of this adds processing cost,
the overall time is significantly shorter that <code>ffmpeg</code>'s run time and
the convenience makes up for that.

The goal is to support (say) up to three transcripts for a video.
This would be useful for Japanese music video where there are transcripts for:<br>
- the English translation;
- the rōmaji; and
- the Japanese language itself.

Of course, fancy lyrical text effects are way, way beyond the scope of this script
(and my current skill set as well 🤩).<br>

## Prerequisites and Required Tools

These are the tools needed to run this script.
The script (right now) assumes their installation and will probably just
die if anything is missing.

- ffmpeg
- mkvtoolnix
- sed + pcre2 (the library)
- coreutils -- <code>basename</code>, <code>cut</code>, <code>head</code>,
    <code>sort</code>, <code>tail</code>, <code>tee</code>, et. al.
- util-linux - <code>getopt</code> (not bash's <code>getopts()</code>)
- grep, egrep
- bc - for (re-)calculating font sizes (<code>--srt-font-size</code>)
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
