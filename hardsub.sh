#! /bin/bash

shopt -s lastpipe ; # Needed for 'while read XXX ; do' loops

# 🇭 🇦 🇷 🇩 🇸 🇺 🇧 🔹 🇸 🇭
###############################################################################
# At some point I'd like to incorporate this logic as command line parameters.
#
if false ; then
  cd /avm1/NO_RSYNC/MVs ; cd 'OUT DIR' ; ls *.mp4 \
    | egrep -v 'NO_METADATA|RESTORE_ME' \
    | while read yy ; do echo -n "${yy} ." ; set +x ;
      if [ -s "/run/media/${USER}/2TBBlue3/MVs/${yy}" ] ; then
        TIMESTAMP_SRC=$(stat -c '%y' "${yy}" | cut -c 1-23) ;
        TIMESTAMP_DST=$(stat -c '%y' "/run/media/${USER}/2TBBlue3/MVs/${yy}" | cut -c 1-23) ;
        echo -n '.' ;
        if [[ $? -ne 0 || "${TIMESTAMP_SRC}" > "${TIMESTAMP_DST}" ]] ; then
          /bin/cp -p "${yy}" "/run/media/${USER}/2TBBlue3/MVs/${yy}" ;
          echo -n ". $(tput bold; tput setaf 5)UPDATED" ;
        else
          echo -n ".. $(tput bold; tput setaf 2)COMPLETED" ;
        fi
      else
        echo -n '.' ;
        /bin/cp -p "${yy}" "/run/media/${USER}/2TBBlue3/MVs/${yy}" ;
        echo -n ". $(tput bold; tput blink; tput setaf 3)NEW, COPY" ;
      fi ;
      tput sgr0 ; echo ;
    done ; cd /avm1/NO_RSYNC/MVs ;

    ###########################################################################

  ls *.flv *.avi *.mkv *.mp4 *.webm *.ts *.mpg *.vob 2>/dev/null \
    | while read yy ; do
      ./hardsub.sh --out-dir=ZTE --mono --preset=ZTE --srt-font-size-percent=135% "${yy}" ;
  done
fi

if false ; then
for yy in * ; do
  if [ ! -d "${yy}" -a -s "${yy}" ] ; then
    echo "${yy}" ;
    exiftool "${yy}" \
      | egrep 'Artist|Title|Album|Genre' ;
  fi ;
done ;
fi

###############################################################################
###############################################################################
# License: GPL v2
# Copyright (C) 2022
#
# This file is part of hardsub.sh
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
###############################################################################
###############################################################################


###############################################################################
# NOTE + TODO:
# - Is this what's happening to the older videos?
#   https://forum.videohelp.com/threads/397242-FFMPEG-Interlaced-MPEG2-video-to-x264-Issue
#
# - for transcripts -- doesn't tell user that ASS file is already there
#   (okay, but would like to see a message)
#
# - minor :: display the font's use-name when extracting the font file.
#
# ☻ It'd be really fun to add a title card to videos w/transcript file.  The
#   user could could specify the background image and duration.  The duration
#   would be added to all of the timestamps (of course) and libass could
#   annimate the title on the title card (or whatever).  WISHLIST
#
#  > I've tried what poisondeathray suggested! And it works!  It gives me the
#    impression it lost or it loses a a little bit of quality compared to the
#    result I got when I used only (-c: v libx264 -crf) without
#    "-flags +ilme+ildct -x264opts tff=1" which the quality was exactly than
#    original. However using "-flags +ilme+ildct -x264opts tff=1" the quality
#    is totally acceptable.
# - option to copy the audio track instead of re-encoding it as MP3
# - option to copy the video track instead of re-encoding it, or re-encode
#   the video track as something different.  For some reason, some re-encodes
#   don't play well on the Samsung but I can't see the different in VLC, e.g.
#   "/avm1/NO_RSYNC/MVs/3 Doors Down - It's Not My Time (CrawDad).mpg".
#
# - My Samsung can only handle 8-bit, but ffmpeg __can__ encode x264 @ 10 bits.
#   https://video.stackexchange.com/questions/13164/encoding-422-in-10-bit-with-libx264
#   Supported pixel formats: yuv420p yuvj420p yuv422p yuvj422p yuv444p yuvj444p
#                            nv12 nv16 nv21 yuv420p10le yuv422p10le yuv444p10le
#                            nv20le gray gray10le
#
###############################################################################
#
# https://askubuntu.com/questions/366103/saving-more-corsor-positions-with-tput-in-bash-terminal
#   Interesting way to capture the cursor position.
# https://unix.stackexchange.com/questions/88490/how-do-you-use-output-redirection-in-combination-with-here-documents-and-cat
#
# Can I use yuvj420p instead?
# https://www.eoshd.com/comments/topic/20799-what-is-the-difference-between-yuvj420p-and-yuv420p/
# "My understanding is yuv420p uses color values from 16-235 whereas yuvj420p
#  uses color values from 0-255."
# --> Maybe not...
#     [swscaler @ 0x560320a39780] deprecated pixel format used, make sure you did set range correctly
# > The ’net seems to say that this warning can be ignored.  What I don't know
#   is if using 'yuvj420p' over 'yuv420p' makes a difference.  Will there be
#   less banding in the shaded parts of a scene?
#
#
# ls ; read MKV_FILE ; mkvmerge -i -F json "${MKV_FILE}" | jq '.container' | jq -r '[.properties.title]|@sh' ;
# ls * | while read MKV_FILE ; do echo -n "${MKV_FILE} -> " ; mkvmerge -i -F json "${MKV_FILE}" | jq '.container' | jq -r '[.properties.title]|@sh' ; done
#
###############################################################################
# TODO + FEATURES:
#  - https://www.youtube.com/watch?v=F0B7HDiY-10
#    Convert these to burn-able subtitles; Korean at the TOP, ENG on bottom.
#


###############################################################################
# How to extract the title from an MKV container, if it's there.  I might want
# to add this as an argument to use instead of defaulting to just the input
# filename (which will be the default fallback if it's not in the video).
#
# Note, sometimes 'track_name' is used in the tracks container, for example ->
# '[PV-SAVE] Aimer - Akane Sasu [1920x732.x264.FLAC][Multi.Subs][Dual.Audio][HQ][7E6D8D2A].mkv'
#
# See 'HS_FONTs/HS-config-2022_07_Summer.sh' for example of this snippet.
#   "tracks": [
#       {
#         "codec": "AVC/H.264/MPEG-4p10",
#         "id": 0,
#         "properties": {
#           ...  ...  ...
#           "track_name": "[PV-SAVE] Aimer - Akanesasu",
#     ...  ...  ...
#
if false ; then
  ls ; read MKV_FILE ; \
    mkvmerge -i -F json "${MKV_FILE}" \
      | jq '.container' \
      | jq -r '[.properties.title]|@sh' ;

  ls ; read MKV_FILE ; \
    mkvmerge -i -F json "${MKV_FILE}" \
      | jq '.tracks[]' \
      | jq -r '[.id, .type, .properties.codec_id, .properties.track_name, .properties.language]|@sh' ;
fi


###############################################################################
###############################################################################
# I cheated 'cause I didn't know how to just get the file's extension ...
#
# https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
#
export ATTR_OFF="`tput sgr0`" ;
export ATTR_BOLD="`tput bold`" ;
export ATTR_UNDL="`tput smul`" ;
export ATTR_BLINK="`tput blink`" ;
export ATTR_CLR_BOLD="${ATTR_OFF}${ATTR_BOLD}" ;
export ATTR_RED="${ATTR_OFF}`tput setaf 1`" ;
export ATTR_RED_BOLD="${ATTR_RED}${ATTR_BOLD}" ;
export ATTR_GREEN="${ATTR_OFF}`tput setaf 2;`" ;
export ATTR_GREEN_BOLD="${ATTR_GREEN}${ATTR_BOLD}" ;
export ATTR_YELLOW="${ATTR_OFF}`tput setaf 3`" ;
export ATTR_YELLOW_BOLD="${ATTR_YELLOW}${ATTR_BOLD}" ;
export ATTR_BLUE="${ATTR_OFF}`tput setaf 4`" ;
export ATTR_BLUE_BOLD="${ATTR_BLUE}${ATTR_BOLD}" ;
export ATTR_MAGENTA="${ATTR_OFF}`tput setaf 5`" ;
export ATTR_MAGENTA_BOLD="${ATTR_MAGENTA}${ATTR_BOLD}" ;
export ATTR_CYAN="${ATTR_OFF}`tput setaf 6`" ;
export ATTR_CYAN_BOLD="${ATTR_CYAN}${ATTR_BOLD}" ;
export ATTR_BROWN="${ATTR_OFF}`tput setaf 94`" ;
export ATTR_BROWN_BOLD="${ATTR_BROWN}${ATTR_BOLD}" ;
export ATTR_OLIVE_BOLD="`tput setaf 64`${ATTR_BOLD}" ;
export ATTR_ORANGE_BOLD="`tput setaf 208`${ATTR_BOLD}" ;
export ATTR_LTBLUE_BOLD="`tput setaf 33`${ATTR_BOLD}" ;
OPEN_TIC='‘' ;
export ATTR_OPEN_TIC="${ATTR_CLR_BOLD}${OPEN_TIC}" ;
CLOSE_TIC='’' ;
export ATTR_CLOSE_TIC="${ATTR_CLR_BOLD}${CLOSE_TIC}${ATTR_OFF}" ;
export FB_CHAR='█' ;

# TODO :: I want to standardize more of these message templates.
export ATTR_ERROR="${ATTR_RED_BOLD}ERROR -${ATTR_OFF}" ;
export ATTR_NOTE="${ATTR_OFF}`tput bold; tput setaf 11`NOTE -${ATTR_OFF}";
export ATTR_TODO="${ATTR_OFF}`tput setaf 11; tput blink`TODO -${ATTR_OFF}";
export ATTR_TOOL="${ATTR_GREEN_BOLD}" ;

export ATTR_SETTING="`tput bold; tput setaf 184`SETTING" ;
export ATTR_DISABLE="`tput bold; tput setaf 172`DISABLING" ;
export ATTR_PRESET="`tput bold; tput setaf 51`SETTING" ;
export ATTR_USING="`tput bold; tput setaf 93`USING" ;
export ATTR_TRYING="`tput bold; tput setaf 93`TRYING" ;
export ATTR_NOTICE="`tput bold; tput setaf 44`NOTICE" ;
export ATTR_NOT_FOUND="`tput bold; tput setaf 198`NOT FOUND" ;
export ATTR_FFMPEG="`tput bold; tput setaf 196`FFMPEG" ;

HS1_CHARACTERS_QUOTES='‘’∕“”…' ;

export G_SED_FILE='' ;

###############################################################################
###############################################################################
# Ctl-C, signals and exit handler stuff ...
# > To avoid the ‘stty: 'standard input': Inappropriate ioctl for device’
#   message, we need to "protect" the ‘stty -echoctl’ command.
#
if [[ -t 0 ]] ; then
  stty -echoctl ;       # hide '^C' on the terminal output
fi
export HARDSUB_PID=$$ ; # I did NOT know about this one trick to exit :) ...

abort() {
   { set +x ; } >/dev/null 2>&1 ;

   my_func="$1" ; shift ;
   my_lineno="$1" ; shift ;

   tput sgr0 ;
   printf >&2 "${ATTR_ERROR} in '`tput setaf 3`%s`tput sgr0`()', line #%s\n" "${my_func}" "${my_lineno}" ;

   kill -s SIGTERM $HARDSUB_PID ;
   exit 1 ; # I missed this the first time ...
}

exit_handler() {

  tput sgr0 ;
  [ "${G_OPTION_DEBUG}" = '' ] \
       && [ -f "${G_SED_FILE}" ] \
       && /bin/rm -f "${G_SED_FILE}" ;
}

sigterm_handler() {
  { set +x ; } >/dev/null 2>&1 ;

  MY_REASON='ABORTED' ;
  if [ $# -ne 0 ] ; then
    MY_REASON="$1" ; shift ;
  fi

  printf '\n' ;
  exit_handler ;

  tput setaf 1 ; tput bold ;
  for yy in {01..03} ; do echo -n "${MY_REASON} " ; done ;
  echo ; tput sgr0 ;

  exit 1 ;
}
trap 'sigterm_handler' HUP INT QUIT TERM ; # Don't include 'EXIT' here...
trap 'exit_handler' EXIT ;


###############################################################################
# Required tools (many of these are probably installed by default):
# - ffmpeg
# - mkvtoolnix
# - sed + pcre2 (the library)
# - coreutils   - basename, cut, head, sort, tail, tee, et. al.
# - util-linux  - getopt (not bash's getopts())
# - fontconfig  - used to validate a fontname (e.g., '--srt-default-font=...)
# - grep        - includes 'egrep' via script or hard-link to grep
# - which       - ...for finding where executables live
# - bc          - for (re-)calculating font sizes (floating point math)
# - jq          - used to parse mkvmerge's json output
#                 developed and tested with version 1.6
# - dos2unix    - ffmpeg builds a DOS file when converting SRT to ASS subtitles
# - bash + type - unless you're going with a really old distro, the version of
#                 bash installed is probably modern enough for this script.
#
#                 The script does use the [[ ]] construct, so this script is
#                 not portable to systems that only have '/bin/sh'.  However,
#                 this should __not__ be a problem on modern architectures,
#                 and bash exists for even legacy Solaris 8 systems (I used to
#                 run bash on my SunOS 4.1.3_u1 SPARC system back in the day).
#                 This script used bash-5.1.0 in its development.
# - exiftool    - used in this script to get/copy metadata from the source
#                 video to the re-encoded video.
#                 exiftool is a perl script, so (obviously) perl needs to be
#                 installed along with any additional supporting libraries.
# - agrep + libtre
#               - https://github.com/Wikinaut/agrep
#                 Recent Fedora distros have an 'agrep' package which links
#                 with 'libtre' and can be optionally installed; other distros
#                 may require building from source.
# - aspell      - used to build auto correct scripts for transcript files
# - (x264)      - for info on configuration of some ffmpeg video options
#
C_SCRIPT_NAME="`basename \"$0\"`" ;
DBG='' ;
DBG=':' ;

  #############################################################################
  # If ffmpeg is run in a script w/o the '-nostdin' option, some very strange
  # things and errors can randomly happen ...
  #
G_FFMPEG_OPT='-y -nostdin -hide_banner' ;

MKVMERGE='/usr/bin/mkvmerge' ;
MKVEXTRACT='/usr/bin/mkvextract' ;
DOS2UNIX='/bin/dos2unix --force' ;
FC_MATCH='/usr/bin/fc-match' ;
FC_LIST='/usr/bin/fc-list' ;
FC_SCAN='/usr/bin/fc-scan' ;
DATE='/usr/bin/date' ;
DATE_FORMAT='' ;
DATE_FORMAT='+%A, %B %e, %Y %X' ;
GREP='/usr/bin/grep' ;
GREP_OPTS='--text --colour=never' ; # saves the embarrassing "binary file matches"
EGREP='/usr/bin/grep -E --text --colour=never'
TEE='/usr/bin/tee' ;
AGREP='/usr/bin/agrep' ;
AGREP_FUZZY_ITERS=6 ;  # Number of agrep passes to make
AGREP_FUZZY_ERRORS=2 ; # This value is arbitrary and was arrived at by testing.
                       # This is the number of 'agrep' "failures" we'll count
                       # to determine if the Title in the video is NOT usable
                       # based on comparing it with the filename of the video.
SED='/usr/bin/sed' ;
CUT='/usr/bin/cut' ;
TAIL='/usr/bin/tail' ;
CP='/usr/bin/cp' ;
FOLD='/usr/bin/fold' ;
HEAD='/usr/bin/head' ;
BC='/usr/bin/bc' ;
WC='/usr/bin/wc' ;
STAT='/usr/bin/stat --printf="%s"' ;
ASPELL='/usr/bin/aspell list --mode=none' ;
EXIFTOOL='/usr/bin/exiftool' ;

  #############################################################################
  # We need a "special" character, one that would NOT normally appear in a
  # Title so that we can know if a title can be split into Atrist / Title.
  # TODO -- maybe this isn't really needed to...
  #
CUT_DELIM=

C_SCRIPT_NAME="$(basename "$0" '.sh')" ;

###############################################################################
# Some ffmpeg encoding constants.  Tweak as necessary to your preference.
# These are chosen to the "least common denominator" for the playback device
# (e.g. my TV can't playback FLAC audio or h265 video streams).
#
C_FFMPEG_CRF_DBG=24 ;            # Fast, used for batch script --debug testing
C_FFMPEG_PRESET_DBG='superfast'; # Fast, used for batch script --debug testing

C_FFMPEG_CRF_NOR=20 ;            # Good quality w/good compression
C_FFMPEG_PRESET_NOR='veryslow' ; # Good quality w/good compression
C_FFMPEG_MP3_BITS=320 ;         # We'll convert the audio track to MP3
C_FFMPEG_PIXEL_FORMAT='yuvj420p'; # If it does NOT work, go back to 'yuv420p'.
                                # https://news.ycombinator.com/item?id=20036710

# TODO :: Only build the directories that are actually needed by the re-encode
C_SUBTITLE_OUT_DIR='./SUBs' ;   # Where to save the extracted subtitle
G_FONTS_DIR="${HOME}/.fonts" ;  # Where to save the font attachments

G_OPTION_DRY_RUN='' ;           # Don't run ffmpeg, exit w/a code ...
G_OPTION_NO_SUBS='' ;           # set to 'y' if '--no-subs' is specified
G_OPTION_NO_MODIFY_SRT='' ;     # for an SRT subtitle, don't apply any sed
                                # scripts to the generated ASS subtitle if
                                # this is set to 'y'.
                                # This flag's use should be pretty rare since
                                # ffmpeg's default conversion is pretty basic.
G_ALLOW_EMBEDDED_OPTIONS=1 ;    # search for embedded options
G_OPTION_NO_MODIFY_ASS='' ;     # TODO write_me + getopt
G_OPTION_ASS_SCRIPT=''    ;     # TODO write_me + getopt
G_OPTION_FFMPEG_TUNE='film' ;   # default for ffmpeg's -tune option

G_OPTION_SUBTITLE_TRACK='first' ; # This is the default subtitle track to burn
G_OPTION_SUBTITLE_TRACK_TYPE=0; # (tightly coupled w/G_OPTION_SUBTITLE_TRACK)
G_OPTION_SUBTITLE_TRACK_NUM=-1; # (tightly coupled w/G_OPTION_SUBTITLE_TRACK)
G_OPTION_SUBTITLE_TRACK_SET=0 ; # (tightly coupled w/G_OPTION_SUBTITLE_TRACK)

G_OPTION_AUDIO_STREAM='first' ; # default audio stream to encode
G_OPTION_AUDIO_STREAM_TYPE=0 ;  # (tightly coupled w/G_OPTION_AUDIO_STREAM)
G_OPTION_AUDIO_STREAM_NUM=0 ;   # (tightly coupled w/G_OPTION_AUDIO_STREAM)
G_OPTION_AUDIO_STREAM_SET=0 ;   # (tightly coupled w/G_OPTION_AUDIO_STREAM)

G_OPTION_NO_FUZZY='' ;          # if set to 'y', then do't use 'agrep' to test
                                # the Title in the video file.
G_OPTION_VERBOSE='' ;           # set to 'y' if '--verbose' is specified to
                                # display a little bit more status of the run
G_OPTION_DEBUG='' ;             # set to 'y' if '--debug' is specified to
                                # preserve some temporary files, etc.
G_OPTION_NO_METADATA='' ;       # Do NOT add any metadata in the re-encoding
                                # process.  This script typically adds: title,
                                # artist, genre, and comment metadata fields
                                # to the video.
                                # NOTE :: this implies '--no-comment'.
G_OPTION_NO_COMMENT='' ;        # Do NOT write a '-metadata comment='.  Other
                                # metadata will be written if appropriate.

G_OPTION_SRT_FONT_SIZE=39 ;     # The Default font size for SRT subtitles
G_OPTION_SRT_DEFAULT_FONT_NAME='NimbusRoman-Regular' ; # The font for SubRip subtitles
                                                       # from fc-match 'times'
    ###########################################################################
    # TODO :: Don't assume any default fonts exist on all linux distros;
    #         use 'check_font_name()' to verify.
    #
G_OPTION_SRT_DEFAULT_FONT_NAME='Open Sans'           ; # ANOTHER TEST
G_OPTION_SRT_DEFAULT_FONT_NAME='Open Sans Semibold'  ; # 4 SubRip subtitles
G_OPTION_SRT_ITALICS_FONT_NAME="${G_OPTION_SRT_DEFAULT_FONT_NAME}" ;

G_OPTION_TRN_DEFAULT_FONT_NAME='Open Sans Semibold'  ; # Font for Transcript subtitles
G_OPTION_TRN_FONT_SIZE=46 ;     # The font size for Transcript subtitles
G_OPTION_TRN_PRIMARYCOLOR='6000F8FF' ; # The PrimaryColor spec for Transcript subtitles
G_OPTION_TRN_OUTLINECOLOR='00101010' ; # The OutlineColor spec for Transcript subtitles
G_OPTION_TRN_OUTLINE_WEIGHT='2.75' ;   # The outline's weight, 0 "disables" the outline
G_OPTION_TRN_MARGIN=100 ;       # The default left and right text margin
G_OPTION_TRN_MARGINV=12 ;       # The default vertical margin
G_OPTION_TRN_TEXT_OFFSET_MS=0;  # subtitle text timing offset, --trn-delay-ms
# TODO FIXME 'Open Sans Semibold' does not exist on blackshed, should print a warning

  #############################################################################
  # https://www.alt-codes.net/music_note_alt_codes.php
  #
  # I was going to support this with a distinct CLI option, but then realized
  # that this can be easily implemented using the existing sed script
  # functionality written into 'hardsub.sh'.
  #
  # Here's 2 very basic examples:
  #   s/^/♪ /
  #   s/$/ ♫/
  #  This will add '♪ ' to the beginning of each line, and ' ♫' to the end of
  #  each line.
  #
  # Example #2 - suppose you wanted to mix up the end of each line a bit -->
  #   s/\([aeiouy]\)$/\1 ♫/
  #   s/\([^♫]\)$/\1 ♪/
  #  Lines ending in a vowel will get ' ♫'; the remaining lines will get ' ♪'.
  #
  # NOTEs:  libass does not render emoji characters.  Using emoji may not work
  #         at all or may get mapped to their "legacy" monochrome character(s).
  #       - https://github.com/mpv-player/mpv/issues/9073
  #       - https://github.com/eosrei/twemoji-color-font
  #       - https://en.wikipedia.org/wiki/Musical_Symbols_(Unicode_block)
  #       > Finally, the Fedora 34 linux distro system that I use is UTF-8.
  #         I don't know how all of this will work in other encodings.
  #
G_MUSIC_CHARS='♩♪♫♭♮♯𝄞𝄢';       # (only here as a reference for copy/paste),
G_OPTION_TRN_WC_THRESHOLD=22 ;  # If the line is less than 22 words, we'll re-time
                                # the 'End' for the line.  Along with the tuning
                                # provided by 'trn-word-time-ms', this does a
                                # decent job of calculating the 'End' value of
                                # a subtitle's text.
G_OPTION_TRN_WORD_TIME=375 ;    # We'll pick the shorter of the two times:
                                # - the implied time, and
                                # - # of words spoken multiplied by this value.
                                # TODO default the GENRE to 'Transcript' if it's
                                #      not provided on the command line.
G_TRN_WORD_TIME_MIN=150 ;       # The minimum value allowed for 'G_OPTION_TRN_WORD_TIME'
G_OPTION_TRN_SED_SCRIPT_DISABLE=0 ; # if 1, don't run any transcript sed script
G_OPTION_TRN_LANGUAGE='English' ; # default to English, or '--trn-language='
G_OPTION_TRN_AMERICAN_ENGLISH=1 ; # ...things like Dr., Mr., and Mrs. and so on
G_OPTION_TITLE='' ;
G_OPTION_ARTIST='' ;
G_OPTION_GENRE='' ;

export G_HAVE_TOOL_ASPELL=1 ;   # = 1 if we have a working aspell

G_VIDEO_OUT_DIR='OUT DIR' ;     # the re-encoded video's save location
C_SUBTITLE_IN_DIR='IN SUBs' ;   # location for manually added subtitles

  #############################################################################
  # Tags which are used in transcript files: O, optional tag; R, required tag.
  #
    ###########################################################################
    # This identifies lines that define an ASS style to copy-through to the
    # .ass subtitle file.  I haven't done a lot of testing on pruning these.
    #
    # IOWs, is a 'Style:'s definition defined by the triplet lines:
    # “[V4+ Styles]”, “Format:”, and “Style:”?  Or after “[V4+ Styles]” and
    # “Format:” are parsed, can additional styles be defined __after__ another
    # "line descriptor" is read by simply adding its “Style:” line descriptor?
    # Since “Format:” is used multiple times as a "keyword", it seems to be
    # tightly coupled to the "ini section" preceding it.
    #
    # ∴ It looks like a “Style:” needs just the triplet described above, and
    #   the “[Events]” section does NOT need to be repeated for “Dialogue:”.
    #   But, just to be sure, you should include the “[Events]” section along
    #   with its “Format:” to ensure that “Dialogue:” works on your system.
    #
    # Substation Alpha (V4+) provides quite a bit of ingenious flexibility.
    # It's pretty easy to change some rendering characteristics about the text
    # using the available style overrides, e.g.: \i, \b, \u, \fs, \fn, \c, etc.
    # For example -->
    #   Dialogue: 0,00:01:25.00,00:01:31.00,Default,,0,0,0,,Alaska's {\i1}long and broken{\i0} coastline ...
    # will render the phrase “long and broken” in italics.
    #
    # \k displays the selection in the SecondaryColour for the specified
    # duration (in hundredths of seconds) ({\k100}) before switching to
    # the PrimaryColour of the “Dislogue:” stlye.
    #
    # If more complicated text "edits" are needed, defining a new “Style:”
    # can be used instead.  This condenses a series of {\i1}{\b1} ... as a
    # style name, for example -->
    #   Dialogue: 0,00:01:25.00,00:01:31.00,Default,,0,0,0,,Alaska's {\rNew Style}long and broken{\r} coastline ...
    # Things like this can easily be automated with an appropriate sed snippet
    # in one of the transcript's sed scripts.
    #
    # I don't have any knowledge of how to get the “Picture:” event to render.
    #   “This is a "picture" event, which means SSA will display the specified
    #   .bmp, .jpg, .gif, .ico or .wmf graphic.”
    #
    # REF :: moodub.free.fr/video/ass-specs.doc
    ###########################################################################
    #
C_TRN_TAG_ASS_SCRIPT='#S' ;
C_TRN_TAG_LANGUAGE='#L' ;       # O, Language tag for spell correction
C_TRN_TAG_EMBEDDED_CLI='#C' ;
C_EMBEDDED_SUFFIX='.cli' ;
#-- C_TRN_TAG_TITLE='#T ' ;     # Video's title if different than filename
#-- C_TRN_TAG_CHANNEL='#U ' ;   # U-tube channel
export C_TRN_TAG_ASS_SCRIPT C_TRN_TAG_LANGUAGE C_TRN_TAG_EMBEDDED_CLI ;

  #############################################################################
  # Video filter setup area ...  Still rough around the edges.
  # TODO :: Should I roll up the 'C_VIDEO_PAD_FILTER_FIX' filter here?
  #
G_PRE_VIDEO_FILTER='' ;
G_POST_VIDEO_FILTER='' ;
G_ZTE_FIX_FILENAMES=0 ; # Filter special character(s) from the filename (':').
G_SMART_SCALING=0 ;     # A marker for a future improvement to scale a video
                        # differently depending on the presence of subtitles.
G_FLAC_PASSTHRU=0 ;     # Some devices support FLAC, so if the source is FLAC,
                        # tell ffmpeg to pass it through (using '-c:a copy').
G_OPTION_MONO=0 ;       # Down sample the audio to mono.

  #############################################################################
  # We'll re-encode the video to h264.
  #
  # BUT h264 has some size constraints that we have to “fix” from the input
  # video (something about a odd number of rows or columns -- I don't remember
  # the exact error message).  The easiest fix is to always apply the “fix”
  # since on "correct" input videos, the fix will not have a negative effect.
  #
  # This usually happens when re-sizing a video, but and original video may
  # have a size not h264 compatible.
  #
C_VIDEO_PAD_FILTER_FIX='pad=width=ceil(iw/2)*2:height=ceil(ih/2)*2' ;

unset SED_SCRIPT_ARRAY ;
declare -a SED_SCRIPT_ARRAY=(); # There's some question if this is global if
                                # declared in an initializer function.

  #############################################################################
  # We'll encode the input video using a MP4 container.  According to
  # https://write.corbpie.com/adding-metadata-to-a-video-or-audio-file-with-ffmpeg/
  # (also https://kodi.wiki/view/Video_file_tagging)
  # the following metadata tags are supported in the MP4 container format:
  #   “title”, “author”, “album_artist”, “album”, “grouping”, “composer”,
  #   “year”, “track”, “comment”, “genre”, “copyright”, “description”,
  #   “synopsis”, “show”, “episode_id”, “network”, and “lyrics”.
  # ADDITIONALLY (from kodi.wiki) “artist”.
  #
  # It was straightforward to automate “title” and “genre” in this script, but
  # other tags could be added through some clever scripting automation as well.
  #
  # exiftool seems to provide the most comprehensive view of a file's metadata.
  #
  # The VLC media player can show a video's metadata with some of the more
  # common tags displayed in the "Current Media Information" dialogue window.
  #
  # MPV.  Looks like metadata display can be provided by some lua scripts.
  # https://www.reddit.com/r/mpv/comments/tx1yp8/is_there_a_way_for_mpv_to_show_me_data_like_album/
  # https://github.com/vc-01/metadata-osd
  #
  # ffplay, xine, mplayer, et. al.  Dunno.
  #
  # Of course, the purpose of this script is to build a media file that is
  # watchable on a technologically lesser device than one's personal computer
  # (e.g. an old TV), so any metadata is probably limited to simple tags,
  # if at all.
  #############################################################################
  # Metadata is kinda tricky and depends on the source container format.
  # ffmpeg seems to/will copy any metadata from the source video that is not
  # overridden by an explicient '-metadata tag=...' on the command line.
  # Also, there doesn't seem to be a way to easily remove all metadata from
  # a video during the re-encoding process.
  #
C_DEFAULT_GENRE='Music Video' ;  # '-metadata genre=' tag default for the video
C_METADATA_COMMENT='' ;          # Search for this to modify what is included
                                 # when the default comment is built.  The
                                 # default comment includes the encoding flags,
                                 # ffmpeg's version, kernel version, and the
                                 # date the video was encoded.

###############################################################################
# FIXME :: documentation spot for this info -->
# Additional video filters should be added here if needed IAW ffmpeg's syntax
# (that is, don't worry about escaping any shell special characters here).
# Notes:
#  ffmpeg applies filters in the order specified, so if a video has subtitles,
#  the subtitle filter is applied __last__.  Suppose you wanted to unsharp,
#  denoise, etc., you probably don't want those applied to the subtitles.
# https://stackoverflow.com/questions/6195872/applying-multiple-filters-at-once-with-ffmpeg
# https://www.makeuseof.com/tag/avi-mkv-mp4-video-filetypes-explained-compared/
#
C_OUTPUT_CONTAINER='avi' ; # Some older TVs may be able to read MKV files...
C_OUTPUT_CONTAINER='mkv' ; # Some older TVs may be able to read MKV files...
C_OUTPUT_CONTAINER='mp4' ; # Some older TVs may be able to read MKV files...

###############################################################################
# C O N T A I N E R   M E T A D A T A   D I F F E R E N C E S   I N   V L C
# ==> vlc-3.0.17.2, Under the "Tools" -> "Media Information" -> "General" tab
# -----------------------------------------------------------------------------
#                 AVI       (ffmpeg)   MP4                  MKV
#                 -------------------  -------------------  -------------------
#   Title         title      (INAM)    title                title
#   Artist        artist     (IART)    artist               --
#   Album         --                   album                album
#   Genre         genre      (IGNR)    genre                genre
#   Now Playing   --                   --
#   Publisher     --                   --                   publisher
#   Copyright     copyright  (ICOP)    --                   copyright
#   Encoded by    --                   "Lavf58.76.100"      --
#   Comments      comment    (ICMT)    comment              comment
# -----------------------------------------------------------------------------
# Under the "Tools" -> "Media Information" -> "Metadata" tab
# AVI ::
#   Software :: (ISFT) :: "Lavf58.76.100"
#   Product  :: (IPRD) :: the data from ffmpeg's "album" metadata tag
# MP4 ::
#   --  no metadata tags are shown in this tab
# MKV :: these additional tags, if set, can appear under this tab:
#   tag name        ffmpeg metadata tag name (when known)
#   ------------ || -------------------------------------
#   SHOW         :: show
#   ALBUM_ARTIST :: album_artist
#   AUTHOR       :: author
#   YEAR         :: year
#   NETWORK      :: network
#   DURATION     :: (copied from source by ffmpeg)
#   HANDLER_NAME :: "...produced by Google..." (copied from source by ffmpeg)
#   ENCODER      :: "Lavf58.76.100"
#   PRODUCER     :: producer
#

G_SUBTITLE_PATHNAME='' ; # Built by this script

###############################################################################
###############################################################################
###############################################################################
#   ######
#   #      #    #  #    #   ####   #####   #    ####   #    #   ####
#   #      #    #  ##   #  #    #    #     #   #    #  ##   #  #
#   ####   #    #  # #  #  #         #     #   #    #  # #  #   ####
#   #      #    #  #  # #  #         #     #   #    #  #  # #       #
#   #      #    #  #   ##  #    #    #     #   #    #  #   ##  #    #
#   #       ####   #    #   ####     #     #    ####   #    #   ####
#
my_usage() {
  local L_RC=$1 ; shift ;

  tput sgr0 ;
  echo "USAGE ::" ; # TODO :: add some help text
  echo -n ' ls *.flv *.avi *.mkv *.mp4 *.MP4 *.webm *.ts *.mpg *.vob *.VOB *.m2ts 2>/dev/null '
  echo    '| while read yy ; do '$0' "${yy}" ; done' ;

  exit $L_RC ;
}


###############################################################################
# Check_max_video_width(input_video, max_video_width)
#
# Checks the width of the input video.  If the width is greater than the
# 'max_video_width' argument, will build the appropriate ffmpeg video filter
# option to limit the size of the video during its re-encoding.
#
# RETURNS :: G_STRING
#   We use a global for the return value so that we can add to the
#   G_OPTION_MESSAGES in scope.
#
check_max_video_width() {
  local input_video="$1" ; shift ;
  local max_video_width=$1 ; shift ;

    ###########################################################################
    # We'll __only__ scale down this video if we detect that it is over a
    # specific size threshold.  Some devices will NOT scale down a video if it
    # is too big.  Otherise, we won't change the video resolution.
    #
    # We'll only check the width - that should be enough.
    #
  local video_width="$("${G_FFMPEG_BIN}" ${G_FFMPEG_OPT} -i "${input_video}" 2>&1 \
        | "${GREP}" ${GREP_OPTS} 'Stream.*Video' \
        | "${GREP}" ${GREP_OPTS} -o '[1-9][0-9]*x[1-9][0-9]* ' \
        | "${CUT}" -dx -f1)" ;

  G_STRING='' ;
  if [ "${video_width}" != '' ] ; then  # {
    if [ ${video_width} -gt ${max_video_width} ] ; then  # {
      G_STRING="$(printf 'scale=%d:-1' ${max_video_width})" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_NOTE} ${ATTR_BOLD}limiting video’s " ;
          printf "encoding to a maximum width of “%d” pixels.\\\n" \
                 ${max_video_width})" ;
    fi  # }
  else  # }{
    : ; # TODO :: is this an ERROR?
  fi  # }

  return ;
}


###############################################################################
# Configure_preset(input_video, preset_name)
#
# Configure a preset.
#
# A "preset" is a static set of configuration(s) that you may want to always
# apply to a specific playback device.  Examples might include always scaling
# the video to the device's screen size, or other re-encoding attributes.
#
configure_preset() {
  local input_video="$1" ; shift ;
  local my_preset="$1" ; shift ;


  if [ "${my_preset}" = '' ] ; then  # {
    return 0 ;
  fi  # }

  G_PRE_VIDEO_FILTER='' ;
  G_POST_VIDEO_FILTER='' ;
  G_SMART_SCALING=0 ;     # TODO :: A marker for a future improvement.
  G_ZTE_FIX_FILENAMES=0 ; # TODO :: A marker for future improvement(s).

    ###########################################################################
    # Set the message here, if there's an ERROR we'll abort anyway ...
    #
  G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
      printf "  ${ATTR_PRESET} video’s encoding preset configuration to " ;
      printf "${ATTR_CLR_BOLD}“${ATTR_GREEN_BOLD}%s${ATTR_CLR_BOLD}”.\\\n" \
             "${my_preset}")" ;

  while : ; do  # {
    case "${my_preset}" in  # {
    linkII|ZTE|zte)
        #######################################################################
        # This device has no auto-rotation capability, so we have to orient
        # the video ourselves to get the best screen utilization.
        #
        # The rotation is the __last__ filter applied, which is why we scale
        # its __width__ to a multiple of the ZTE screen's __height__.
        #
      G_POST_VIDEO_FILTER='transpose=2' ;
        #######################################################################
        # Why use 640 when the phone is 2.8” (240x320)/1.7 (128x160)” TFT LCD?
        # It has to do with the font scaling.  The font rendering at small
        # point sizes is rough - it seems I get better results applying a font
        # to a larger image and then letting the phone's HW scaler fit it to
        # the display.  Downsides: larger file size and larger file size for
        # videos w/o subtitles.
        #
        # A possible solution is to smart-scale the video,
        # if is there a subtitle, scale it larger.  Otherwise, scale it to the
        # device's native display size (which would be 320:-1 in this case).
        #
      G_PRE_VIDEO_FILTER='scale=640:-1' ;
      G_SMART_SCALING=1 ; # TODO :: A marker for a future improvement.
        #######################################################################
        # Some filenames do NOT copy to the phone.  Not a lot of info about the
        # exact filesystem on the phone, I suspect some version of NTFS?  Looks
        # like a ':' in the filename breaks the copy (no useful error message).
        #
      G_ZTE_FIX_FILENAMES=1 ; # TODO :: A marker for future improvement(s).
      ;;
    Samsung|1920|1080p)
        #######################################################################
        # We'll __only__ scale down a video if we detect that it is over a
        # specific size threshold.  Some devices will NOT scale down a video
        # if it is too big (e.g., my Samsung TV).
        #
        # Otherise, we won't change the video resolution.
        #
      check_max_video_width "${input_video}" 1920 ;
      G_PRE_VIDEO_FILTER="${G_STRING}" ;
      ;;
    tablet|1280|720p)
      check_max_video_width "${input_video}" 1280 ;
      G_PRE_VIDEO_FILTER="${G_STRING}" ;
      ;;
    *)
      echo "${ATTR_ERROR} ${ATTR_BOLD}unrecognized “preset='${my_preset}'”" ;
      break ;
      ;;
    esac  # }

    return 0;
  done ;  # }

  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# check_ffmpeg_binary(my_option, my_directory)
#
# DOES NOT return if there was an error.
#
check_ffmpeg_binary() {
  local my_option="$1" ; shift ;
  local my_ffmpeg="$1" ; shift ;


  while : ; do  # {
    if [ "${my_ffmpeg}" = '' ] ; then  # Pedantic, I know ...
      echo "${ATTR_ERROR} ‘${my_option}’ requires a valid ffmpeg executable." >&2 ;
      break ;
    fi

      #########################################################################
      # Use 'which' to get a complete pathname of the ffmpeg executable, and
      # it also ensures that the file __is__ executable.
      #
      which "${my_ffmpeg}" >/dev/null 2>&1 ; RC=$? ;
      (( RC )) && { \
         printf >&2 "${ATTR_ERROR} ${ATTR_CLR_BOLD}The ‘${ATTR_YELLOW}%s${ATTR_CLR_BOLD}’\n" \
                    "${my_ffmpeg}" ;
         printf >&2 "        executable was not found by ‘which’.\n"
         break ; }

      local which_ffmpeg="$(which "${my_ffmpeg}")" ;

      #########################################################################
      # SUCCESS :: return directory's name as required.
      #
    printf '%s' "${which_ffmpeg}" ;
    return 0;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# check_directory(my_option, my_directory)
#
# We use this to check those CLI options which require a directcory pathname.
#
# If successful, we return the directory’s name.
# DOES NOT return if there was an error.
#
check_directory() {
  local my_option="$1" ; shift ;
  local my_directory="$1" ; shift ;

  ${DBG} echo "OPTION = ‘${my_option}’, DIR = ‘${my_directory}’" >&2 ;

  while : ; do  # {
    if [ "${my_directory}" = '' ] ; then  # Pedantic, I know ...
      echo "${ATTR_ERROR} ‘${my_option}’ requires a directory path." >&2 ;
      break ;
    fi

      #########################################################################
      # SUCCESS :: return directory's name as required.
      #
    printf '%s' "${my_directory}" ;
    return 0;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# Validate and build a directory.
#
# If successful, we return the directory’s name if an OPTION was specified.
#
# We use this to check those options and to validate the default directories
# used by this script for access, etc.  DOES NOT return if there was an error.
#
# It *look* like we call this twice for options which require a directory, but
# the first call is the “Pedantic” test for the option, and the second call is
# to validate the selected directory (redundant) or its default value.
#
check_and_build_directory() {
  local my_option="$1" ; shift ;
  local my_directory="$1" ; shift ;

  ${DBG} echo "OPTION = '${my_option}', DIR = '${my_directory}'" >&2 ;

  while : ; do  # {
    if [ "${my_directory}" = '' ] ; then  # Pedantic, I know ...
      echo "${ATTR_ERROR} '${my_option}' requires a directory path." >&2 ;
      break ;
    fi

    ###########################################################################
    # mkdir rolls up a bunch of validity checking for us ...
    #
    err_msg="$(mkdir -p "${my_directory}" 2>&1)" ; RC=$? ;
    if [ ${RC} -ne 0 ] ; then  # {
      echo -n "${ATTR_ERROR} " ;
      if [ "${my_option}" != '' ] ; then
        echo    "${my_option}='${ATTR_YELLOW}${my_directory}${ATTR_OFF}'," >&2 ;
      fi
      echo "${err_msg}" >&2 ;
      break ;
    fi  # }

      #########################################################################
      # SUCCESS :: return (echo) the successfully built directory as required.
      #
    [ "${my_option}" != '' ] && echo "${my_directory}" ;
    return 0;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# check_font_name  unused  option  font_name_to_test  no_message_if_1
#
# This function checks to see if the provided font is valid (as best it can).
#   G_OPTION_SRT_DEFAULT_FONT_NAME="$(check_font_name "${G_OPTION_SRT_DEFAULT_FONT_NAME}" "$1" "$2" 0)" ;
#
check_font_name() {
  local old_font_name="$1" ; shift ;  # UNUSED
  local my_option="$1" ; shift ;
  local new_font_name="$1" ; shift ;
  local no_message="$1" ; shift ; # if 1, then don't log any message

  local rc=0 ;

  while : ; do  # {
    if [ "${new_font_name}" = '' ] ; then  # Pedantic, I know ...
      { echo -n "${ATTR_ERROR} '${ATTR_YELLOW_BOLD}${my_option}${ATTR_OFF}' " ;
        echo    'requires a font name.' ; } >&2 ;
      break ;
    fi

    ###########################################################################
    # 1. Get the font's filename and the font's name returned from 'fc-match'.
    #    We go through all of this effort to make it easy for the user to
    #    specify a font name more casually, e.g. 'times' for a 'Times'-like
    #    font that on Fedora linux is actually 'Nimbus Roman'.  Likewise,
    #    'bookman' might return "URW Bookman" "Light" depending on what fonts
    #    are installed with the distribution or by the user, etc.
    #
    local fc_match="$(${FC_MATCH} "${new_font_name}")" ;
    if [ "${fc_match}" = "${G_INVALID_FONT_NAME}" ] ; then  # {
      rc=1 ;
      if [ "${no_message}" -eq 0 ] ; then  # {
        {
          echo -n "${ATTR_YELLOW_BOLD}`tput blink`WARNING - `tput sgr0; tput bold`" ;
          echo -n "Unknown font name = '${ATTR_CYAN}${new_font_name}"
          echo -ne "`tput sgr0; tput bold`',\n          "
          echo    "${ATTR_MAGENTA}fontconfig may select some system default.`tput sgr0`"
        } >&2 ;
      fi  # }
    fi  # }
    local font_filename="$(echo "${fc_match}" | cut -d':' -f1)" ;
    local font_name="$(echo "${fc_match}" \
                     | "${SED}" -e 's/^.*: "//' -e 's/".*$//')" ;

    ###########################################################################
    # 2. Get the pathname for the font file that is returned from 'fc-list'.
    #    It's possible there could be more than 1 copy so we limit the result
    #    to just the first record using 'head'.
    #
    local font_pathname="$(${FC_LIST} "${font_name}"  \
                         | "${GREP}" ${GREP_OPTS} "${font_filename}" \
                         | head -1                    \
                         | cut -d':' -f1)" ;

    ###########################################################################
    # 3. Finally, get the 'fullname:' from the font's pathname from 'fc-scan'.
    #    This __could__ match exactly what the user provided (and that's okay)
    #    and gives some extra versatility to getting a working font name for
    #    a subtitle script.  A user could specify "times" or "serif".
    #   - If the font can't be matched through ffmpeg -> libass -> fontconfig,
    #     rendering for those styles will NOT happen, so it's important to get
    #     the exact font name for the Style in the Substation Alpha script.
    #
    new_font_name="$(${FC_SCAN} "${font_pathname}" \
                   | "${GREP}" ${GREP_OPTS} 'fullname:' \
                   | "${SED}" -e 's/^.*: "//' -e 's/".*$//')" ;
    echo "${new_font_name}" ;

    return ${rc} ;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO}; # We'll only see for a bug in this script.
}


###############################################################################
# This function takes a number and applies a percentage to it and returns the
# new value as a string.
#
# This is a general purpose function that is mainly used to recalculate the
# new size of a font based on a percentage.  This seems like a reasonable and
# simple way to specify a new value as a percentage allows up to go above or
# below the original value w/o having to worry about negative numbers.
#
apply_percentage() {
  local my_option="$1" ; shift ;
  local in_percentage="$1" ; shift ;
  local in_number="$1" ; shift ;
  local my_scale="$1" ; shift ; # number of digits right of the decimal point

  ${DBG} echo >&2 "OPTION = '${my_option}', PERCENTAGE = '${in_percentage}'" ;

  while : ; do  # {
    if [ "${in_percentage}" = '' ] ; then  # Pedantic, I know ...
      echo >&2 "${ATTR_ERROR} '${my_option}' requires a percentage value." ;
      break ;
    fi

    local my_regex='^[0-9]+([.][0-9]+)?$' ;
    if ! [[ "${in_percentage}" =~ $my_regex ]] ; then
      echo >&2 "${ATTR_ERROR} '${my_option}=${in_percentage}' is not a number" ;
      break ;
    fi

    echo "scale=${my_scale};${in_number} * (${in_percentage} / 100)" | ${BC} ;

    return 0;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO};
}

###############################################################################
# add_option_directory_message(my_desc, olde_value, new_value)
#
add_option_directory_message() {
  my_desc="$1" ; shift ;
  olde_value="$1" ; shift ;
  new_value="$1" ; shift ;

  G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
    printf '%s' "  ${ATTR_SETTING} ${my_desc} directory from " ;
    printf '%s' "${ATTR_CLR_BOLD}“${ATTR_MAGENTA_BOLD}${olde_value}${ATTR_CLR_BOLD}” " ;
    printf '%s' "to “${ATTR_GREEN_BOLD}${new_value}" ;
    printf "${ATTR_CLR_BOLD}”${ATTR_YELLOW_BOLD}.${ATTR_OFF}\\\n")" ;
}


###############################################################################
# build_colour(value, prefix_str, fb_char)
#
# I like code-bling ...
# TODO :: add a note that this is an approximate color (via this RC and looked
#         at by caller).
#
build_colour() {
  value="$1" ; shift ;
  prefix_str="$1" ; shift ;
  fb_char="$1" ; shift ;

  if [ "${TERM}" != 'xterm-256color' ] ; then printf '' ; return 0; fi ;

  RGB_RED="${value:6:2}" ;
  RGB_GREEN="${value:4:2}" ;
  RGB_BLUE="${value:2:2}" ;
  printf '%s“\033[38;2;%d;%d;%dm%s%s”' ${ATTR_CLR_BOLD}"${prefix_str}" \
     $(( 16#${RGB_RED} )) $(( 16#${RGB_GREEN} )) $(( 16#${RGB_BLUE} )) \
     "${fb_char}${fb_char}${fb_char}" "${ATTR_CLR_BOLD}" ;

  return 0 ;
}


###############################################################################
# get_decimal_number(option, value, minimum, maximum)
#
get_decimal_number() {
  local my_option="$1" ; shift ;
  local in_value="$1" ; shift ;
  local in_minimum="$1" ; shift ;
  local in_maximum="$1" ; shift ;


  local my_regex='^[0-9]+(\.[0-9]+)?$' ;
  while : ; do  # { # NOTE, 1st regex catches an EMPTY (missing) argument too.
    if ! [[ "${in_value}" =~ $my_regex ]]                   \
      || (( $(echo "$in_value < $in_minimum" | ${BC} -l) )) \
      || (( $(echo "$in_value > $in_maximum" | ${BC} -l) )) \
    ; then  # {
      echo >&2 -n "${ATTR_ERROR} '${my_option}=${in_value}' "
      echo >&2 -n "requires a decimal value in the range of " ;
      echo >&2    "‘${in_minimum}’ to ‘${in_maximum}.’" ;
      break ;
    fi  # }

    printf '%s' "${in_value}" ;
    return 0;
  done  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# get_color_spec(option, value)
#
get_color_spec() {
  local my_option="$1" ; shift ;
  local in_value="$1" ; shift ;

  local my_regex='^[0-9a-fA-F]{8}$' ;

  while : ; do  # { # NOTE, this regex catches an EMPTY (missing) argument too.
    if ! [[ "${in_value}" =~ $my_regex ]] ; then  # {
      echo >&2 -n "${ATTR_ERROR} '${my_option}=${in_value}' "
      echo >&2    "requires an 8-digit hexadecimal value in the format of ‘TTBBGGRR.’" ;
      break ;
    fi  # }

    printf '%s' "${in_value}" ;
    return 0;
  done  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# get_option_integer(option, value, minimum, [maximum])
#
get_option_integer() {
  local my_option="$1" ; shift ;
  local in_value="$1" ; shift ;
  local in_minimum_value="$1" ; shift ;
  local in_maximum_value=100000 ;
  if [ $# -eq 1 ] ; then
    in_maximum_value="$1" ; shift ;
  fi


  while : ; do  # {
    if [ "${in_value}" = '' ] ; then  #  { Pedantic, I know ...
      printf >&2 "${ATTR_ERROR} '%s' requires an integer " "${my_option}" ;
      printf >&2 'between %d and %d.\n' ${in_minimum_value} ${in_maximum_value} ;
      break ;
    fi  # }

    local re='^[+-]{0,1}[1-9][0-9]*$|^[+-]{0,1}[0-9]$' ; # Gawd, I love regular expressions!
    if ! [[ $in_value =~ $re ]] ; then  # {
      echo >&2 "${ATTR_ERROR} '${my_option}=${in_value}' is not an integer." ;
      break ;
    fi  # }

    (( in_value += 0 )) ; # (remove possible '+' character)

    if [[ $in_value -lt $in_minimum_value ]] ; then  # {
      echo >&2 "${ATTR_ERROR} '${my_option}=${in_value}', value is too small." ;
      break ;
    fi  # }

    if [[ $in_value -gt $in_maximum_value ]] ; then  # {
      echo >&2 "${ATTR_ERROR} '${my_option}=${in_value}', value is too large." ;
      break ;
    fi  # }

    printf "%s" "${in_value}" ;
    return 0;
  done  # }

    ###########################################################################
    # FAILURE :: exit; print the allowed range for this option.
    #
  printf >&2 "%s%sExpected value should be between %s and %s inclusive.%s\n" \
             "        " \
             "${ATTR_CLR_BOLD}" \
             "${ATTR_BLUE_BOLD}${in_minimum_value}${ATTR_CLR_BOLD}" \
             "${ATTR_BLUE_BOLD}${in_maximum_value}${ATTR_YELLOW}" \
             "${ATTR_OFF}" ;
  abort ${FUNCNAME[0]} ${LINENO};
}


###############################################################################
# Get_option_track_or_stream(option, value)
#
# Get an option's track specification, either the subtitle or audio stream.
#
# We won't be able to validate this until we actually look at the tracks
# using mkvmerge (that is, if the user specifies track 1 for the subtitle,
# that track must be a text subtitle, not a video or audio track).
#
get_option_track_or_stream() {
  local my_option="$1" ; shift ;
  local in_value="$1" ; shift ;


  if [ "${in_value}" = '' ] ; then  #  { Pedantic, I know ...
    echo >&2 -n "${ATTR_ERROR} '${my_option}' requires: a number; "
    echo >&2    "‘first’ or ‘last’; or a simple regx pattern." ;
    abort ${FUNCNAME[0]} $LINENO ;
  fi  # }

  local rc=0 ;
  local re='^[0-9]{1,2}$' ; # Simple way to check if string is an integer

  if [[ $in_value = 'first' || $in_value = 'last' ]] ; then  # {
    :
  elif [[ $in_value =~ $re ]] ; then  # }{
    in_value="$(printf '%d' "$((10#$in_value))")" ;
    rc=1 ;
  else  # }{
    rc=2 ;
  fi  # }

  printf '%s' "${in_value}" ;
  return $rc ;
}


###############################################################################
# get_option_string(option, value)
#
# Get an option's simple string argument.
#
get_option_string() {
  local my_option="$1" ; shift ;
  local in_string="$1" ; shift ;

  while : ; do  # {
    if [ "${in_string}" = '' ] ; then  #  { Pedantic, I know ...
      echo >&2 "${ATTR_ERROR} ‘${my_option}’ requires a string." ;
      (( err_lineno = $LINENO - 1 ));
      break ;
    fi  # }

    printf "%s" "${in_string}" ;
    return 0;
  done  # }

    ###########################################################################
    # FAILURE :: exit; we've already printed an appropriate error message above
    #
  abort ${FUNCNAME[0]} ${err_lineno} ;
}


###############################################################################
# Select_subtitle_track_number(in_video, track_type, track_spec)
#
# Get the track number of the subtitle specified.
#
select_subtitle_track_number() {
  local in_video="$1" ; shift ;
  local track_type="$1" ; shift ; # 0, 1, or 2
  local track_spec="$1" ; shift ;

  case ${track_type} in  # {

  0) # 'first' or 'last', 'auto-detect' is used internally to indicate a retry ...
    case "${track_spec}" in  # {
      auto-detect|first) which_cmd='head -1' ; ;;
      last)              which_cmd='tail -1' ; ;;
    esac  # }
    track_desc="$(${MKVMERGE} -i "${in_video}"   \
              | "${GREP}" ${GREP_OPTS} 'subtitles' \
              | ${which_cmd})" ;
    track_num="$(echo "${track_desc}" | "${CUT}" -d: -f1 | "${CUT}" -d' ' -f3)" ;
    # FIXME :: if "${track_spec}" = 'auto-detect' and track_num = '', then
    # TODO  :: add a message that video doesn't contain desired subtitle track.
    #          (This may still miss the '--subs-track=first' case, but do we care?)
    ;;

  1) # An integer track # < 255 (hopefully!)
    track_num=${track_spec} ;
    track_found="$(${MKVMERGE} -i -F json "${in_video}" \
          | jq -r "[.tracks[${track_num}].properties.codec_id, \
                    .tracks[${track_num}].properties.track_name]|@sh")" ;
    printf '%s' "${track_found}" | "${GREP}" ${GREP_OPTS} 'S_TEXT' ; rc=$? ;
    if [ $rc -ne 0 ] ; then
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_NOTICE} ${ATTR_CLR_BOLD}subtitle track ‘%s’, " "#${track_num}" ;
          printf "“${ATTR_YELLOW}%s${ATTR_CLR_BOLD}” is not a " "${track_found}" ;
          printf "‘${ATTR_MAGENTA_BOLD}%s${ATTR_CLR_BOLD}’ codec.${ATTR_OFF}\\\n" 'S_TEXT')" ;
      select_subtitle_track_number "${in_video}" 0 'auto-detect' ; rc=$? ;
      return $rc ;
    fi
    ;;

  2) # An egrep regx
    which_cmd='head -1' ; # WISH ... someday, configurable?
    track_found="$(${MKVMERGE} -i -F json "${in_video}" \
        | jq '.tracks[]' \
        | jq -r "[.id, .type, .properties.codec_id, \
                  .properties.track_name, .properties.language]|@sh" \
        | "${GREP}" ${GREP_OPTS} "'subtitles'" \
        | "${GREP}" -E ${GREP_OPTS} "${track_spec}" \
        | ${which_cmd})" ;

    ${DBG} printf "  ${ATTR_RED}%s${ATTR_OFF}\n" "${track_found}"

    track_num="$(printf '%s' "${track_found}" | "${CUT}" -d' ' -f1)" ;
    if [ "${track_num}" = '' ] ; then
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_NOTICE} ${ATTR_CLR_BOLD}subtitle track "
          printf "“${ATTR_YELLOW}%s${ATTR_CLR_BOLD}” " "${track_spec}" ;
          printf "was NOT found.${ATTR_OFF}\\\n")" ;
      select_subtitle_track_number "${in_video}" 0 'auto-detect' ; rc=$? ;
      return $rc ;
    fi
    printf '%s' "${track_found}" | "${GREP}" ${GREP_OPTS} 'S_TEXT' ; rc=$? ;
    if [ $rc -ne 0 ] ; then
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_NOTICE} ${ATTR_CLR_BOLD}subtitle track ‘%s’, " \
                 "#${track_num}" ;
          printf "“${ATTR_YELLOW}%s${ATTR_CLR_BOLD}” is not a " \
                 "$(printf '%s' "${track_found}" | "${CUT}" -d' ' -f2-3)" ;
          printf "‘${ATTR_MAGENTA_BOLD}%s${ATTR_CLR_BOLD}’ codec.${ATTR_OFF}\\\n" \
                 'S_TEXT')" ;
      select_subtitle_track_number "${in_video}" 0 'auto-detect' ; rc=$? ;
      return $rc ;
    fi
    ;;
  *)
    abort ${FUNCNAME[0]} ${err_lineno} ;
    ;;
  esac  # }

    ###########################################################################
    # Right now, this logic __only__ supports 'S_TEXT' subtitles (no PGS).
    #
  if [ "${track_spec}" = 'auto-detect' ] ; then  # {
     message_tag="${ATTR_TRYING}" ;
  else  # }{
     message_tag="${ATTR_USING}" ;
  fi  # }

  if [ "${track_num}" != '' ] ; then  # {
    rc=${track_num} ;
    track_details="$(${MKVMERGE} -i -F json "${in_video}" \
        | jq -r "[.tracks[${track_num}].properties.codec_id,   \
                  .tracks[${track_num}].properties.track_name, \
                  .tracks[${track_num}].properties.encoding,   \
                  .tracks[${track_num}].properties.language]|@sh")" ;

    G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
    printf "  ${message_tag} ${ATTR_CLR_BOLD}subtitle track [%d], “${ATTR_YELLOW}%s${ATTR_CLR_BOLD}” " \
           ${track_num} "${track_spec}" ;
    printf "is “${ATTR_GREEN}%s${ATTR_CLR_BOLD}”" "${track_details}" ;
    printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
  else  # }{
    rc=-1 ; # (actually this is converted to an unsigned byte == 255.)
  fi  # }

  return ${rc} ;
}


###############################################################################
# probe_video(video_file)
#
# Perform a probe of the video file tracks.  Typical output may look like -->
#
# TRACKS OF 'video-file.mkv':
#   0 'video' 'AVC/H.264/MPEG-4p10' '1280x720' 'V_MPEG4/ISO/AVC' 'track-title'
#   1 'audio' 'FLAC' 'A_FLAC' 2 16 48000 'Japanese 2.0' 'jpn'
#   2 'subtitles' 'SubStationAlpha' 'S_TEXT/ASS' 'UTF-8' null 'eng'
#
# This info may be needed to correctly select the:
#   - correct or desired subtitle __track__, and/or
#   - desired audio __stream__.
#   - (in the future?) desired video __track__.
#
probe_video() {
  local video_file="$1" ; shift ;

  G_OPTION_GLOBAL_MESSAGES="${G_OPTION_GLOBAL_MESSAGES}$(\
    printf "  ${ATTR_YELLOW_BOLD}TRACKS OF ${ATTR_CLR_BOLD}'${ATTR_YELLOW}%s%s\n" \
           "${video_file}" \
           "${ATTR_CLR_BOLD}':" ;
    { ${MKVMERGE} -i -F json "${video_file}" \
        | jq '.tracks[]'         \
        | jq -r "[.id, .type, .codec, .properties.display_dimensions, \
                  .properties.codec_id, .properties.track_name]|@sh" \
          | "${GREP}" ${GREP_OPTS} "'video'" ;  \
      ${MKVMERGE} -i -F json "${video_file}" \
        | jq '.tracks[]'           \
        | jq -r "[.id, .type, .codec, .properties.codec_id, \
                  .properties.audio_channels, \
                  .properties.audio_bits_per_sample, \
                  .properties.audio_sampling_frequency, \
                  .properties.track_name, .properties.language]|@sh" \
          | "${GREP}" ${GREP_OPTS} "'audio'" ; \
      ${MKVMERGE} -i -F json "${video_file}" \
        | jq '.tracks[]'           \
        | jq -r "[.id, .type, .codec, .properties.codec_id, \
                  .properties.encoding, \
                  .properties.track_name, .properties.language]|@sh" \
          | "${GREP}" ${GREP_OPTS} "'subtitles'" ; \
        } \
        | sed -e "s/video/${ATTR_YELLOW_BOLD}video${ATTR_CLR_BOLD}/" \
              -e "s/audio/${ATTR_BLUE_BOLD}audio${ATTR_CLR_BOLD}/" \
              -e "s/subtitles/${ATTR_GREEN}subtitles${ATTR_CLR_BOLD}/" \
              -e 's/^/    /'
      )\\n" ;
}


###############################################################################
# If not disabled, then echo out any other command line options which affect
# the video's encoding (e.g., changing the font face and/or size) for the
# video's metadata comment.
#
add_other_commandline_options() {

  printf '' ;
  #echo '-srt-font-size-percent=130%' ;
}


###############################################################################
# initialize_variables()
#
initialize_variables() {

  G_FFMPEG_BIN="$(check_ffmpeg_binary '' 'ffmpeg')" ;

  G_OPTION_NO_SUBS='' ;
  G_OPTION_VERBOSE='' ;

    ###########################################################################
    # Every distro / installation could return a different value for the
    # "best font available."  So, we capture it here ...
    #
  G_INVALID_FONT_NAME="$(${FC_MATCH} '')" ;

  G_SCRIPT_RUN_DATE="$(${DATE} "${DATE_FORMAT}")" ; # Do this just ONCE per/run.

  G_OPTION_MESSAGES='' ;
  G_OPTION_GLOBAL_MESSAGES='' ; # Show these messages last on the console
}


if [ $# -eq 0 ] ; then

  my_usage 2; # FIXME -- is this still needed?
fi


###############################################################################
###############################################################################
###############################################################################
# Check_getopt(is_cli, ...)
#
# TODO :: add a "special" option to indicate that this call is for embedded
#         options (something that's not easily typed on the keyboard).
#
# Setup and use getopt() for the command line arguments.
# Stuff the parsed options back into the arg[] list (quotes are essential)...
# (You know, I don't remember why I originally chose this particular method.)
#
# As a stylistic choice, I want to enforce *long options* which require an
# argument to use the '--option=argument' syntax.  To do this, I set those
# option's arguments as __optional__.  This causes 'getopt' to only consider
# an option as having an argument when it is preceded by the '=' character.
# That is, it always returns an argument for the option and if the argument
# is an EMPTY string (''), then an "optional" argument was NOT provided.
# I think this makes the command line easier to read and less error prone.
#
# FIXME ::
#  trn-no-words -- needed for non-English transcripts which do NOT have word
#                  spacing (we can't count words, we'll have to count chars
#                  using ‘wc -m’).
# TODO :: IDEA ::
#  Setting an option which requires an argument as "--option=?" will print a
#  help block about the option and force G_OPTION_DRY_RUN=2 to exit the script
#  immedaitely after displaying the help (multiple options can be done at once).
#
check_getopt() {
  local do_probe=0 ;
  local option_preset='' ;

  local is_cli=$1 ; shift ;

##?? G_OPTION_GLOBAL_MESSAGES='' ; # reset for each call to 'check_getopt()'

  HS_OPTIONS=`getopt -o dpt::h::vc:f:yq: \
      --long help::,verbose,config:,copy-to:,quality:,\
dry-run,\
debug,\
no-subs,\
no-comment,\
no-metadata,\
no-modify-srt,\
no-fuzzy,\
probe,\
probe-only,\
ffmpeg::,\
cli::,\
title::,\
artist::,\
genre::,\
tune::,\
preset::,\
out-dir::,\
video-out-dir::,\
subs-out-dir::,\
subs-in-dir::,\
trn-delay-ms::,\
trn-word-time-ms::,\
trn-word-time-percent::,\
trn-no-words,\
trn-text-margin::,\
trn-text-margin-vertical::,\
trn-font-primarycolor::,\
trn-font-outlinecolor::,\
trn-font-outlineweight::,\
trn-font-size-percent::,\
trn-words-threshold::,\
trn-language::,\
trn-disable-sed,\
srt-default-font::,\
srt-italics-font::,\
srt-font-size-percent::,\
subs-track::,\
audio-stream::,\
mono,\
fonts-directory::,\
font-check:: \
    -n "${ATTR_ERROR} ${ATTR_BLUE_BOLD}${C_SCRIPT_NAME}${ATTR_YELLOW}" -- "$@"` ;

  if [ $? != 0 ] ; then
     my_usage 1 ;
  fi

  eval set -- "${HS_OPTIONS}" ;
  while true ; do  # {
    case "$1" in  # {
    --mono)
      G_OPTION_MONO=1 ; shift ;
      ;;
    --no-subs)
      G_OPTION_NO_SUBS='y' ; shift ;
      ;;
    --no-modify-srt)
      G_OPTION_NO_MODIFY_SRT='y' ; shift ;
      ;;
  # --mux-subs)   # If there are subtitles, then also MUX them into the video
  #   ;;
    -p|--probe|--probe-only)
      if (( is_cli )) ; then  # {
        G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_NOTICE} ${ATTR_CLR_BOLD}‘%s’ %s\\\n" \
                 "$1" 'is ignored in a CLI option file.')" ;
      elif [ "$1" = '--probe-only' ] ; then # }{
        do_probe=2 ;
      else  # }{
        do_probe=1 ;
      fi  # }
      shift ;
      ;;
    --ffmpeg)
        G_FFMPEG_BIN="$(check_ffmpeg_binary "$1" "$2")" ;
        G_OPTION_GLOBAL_MESSAGES="${G_OPTION_GLOBAL_MESSAGES}$(\
          printf "  ${ATTR_FFMPEG}${ATTR_CLR_BOLD} ‘%s’.\\\n"  \
                 "${G_FFMPEG_BIN}")" ;
      shift 2 ;
      ;;
    -d|--dry-run)
      if ! [ "${G_OPTION_DRY_RUN}" = 'y' ] ; then  # {
        G_OPTION_GLOBAL_MESSAGES="${G_OPTION_GLOBAL_MESSAGES}$(\
          printf "  ${ATTR_LTBLUE_BOLD}DRY RUN ${ATTR_CLR_BOLD}%s\\\n" \
                 'ffmpeg will NOT be run after the video’s preprocessing')" ;
      fi  # }
      G_OPTION_DRY_RUN='y' ; shift ;
      ;;
    --debug)
      if ! [ "${G_OPTION_DEBUG}" = 'y' ] ; then  # {
        G_OPTION_GLOBAL_MESSAGES="${G_OPTION_GLOBAL_MESSAGES}$(\
          printf "  ${ATTR_YELLOW_BOLD}DEBUG RUN - ${ATTR_CLR_BOLD}%s${ATTR_OFF}\\\n" \
                 'ffmpeg encoding set to very fast, low quality settings.')" ;
      fi  # }
      G_OPTION_DEBUG='y' ; shift ;
      ;;
    --no-metadata)
      G_OPTION_NO_METADATA='y' ; shift ;
      ;;
    --no-comment)
      G_OPTION_NO_COMMENT='y' ; shift ;
      ;;
    --no-fuzzy)
      G_OPTION_NO_FUZZY='y' ; shift ;
      ;;
    --out-dir|--video-out-dir) # '--video-out-dir' is preferred except I keep forgetting!
      new_value="$(check_directory "$1" "$2")" ;
      add_option_directory_message 'video’s output' "${G_VIDEO_OUT_DIR}" "${new_value}" ;
      G_VIDEO_OUT_DIR="${new_value}" ;
      shift 2;
      ;;
    --subs-out-dir)
      new_value="$(check_directory "$1" "$2")" ;
      add_option_directory_message 'subtitle save' "${C_SUBTITLE_OUT_DIR}" "${new_value}" ;
      C_SUBTITLE_OUT_DIR="${new_value}" ;
      shift 2;
      ;;
    --subs-in-dir)
      # TODO :: don't allow this option in an embedded CLI
      new_value="$(check_directory "$1" "$2")" ;
      add_option_directory_message 'support∕subtitle' "${C_SUBTITLE_IN_DIR}" "${new_value}" ;
      C_SUBTITLE_IN_DIR="${new_value}" ;
      shift 2;
      ;;
    --fonts-directory)
      new_value="$(check_directory "$1" "$2")" ;
      add_option_directory_message 'ffmpeg font’s directory' "${C_SUBTITLE_IN_DIR}" "${new_value}" ;
      G_FONTS_DIR="${new_value}" ;
      shift 2;
      ;;
    --font-check)
      font_check_name="$(check_font_name '' "$1" "$2" 0)" ; RC=$? ;
      if [ ${RC} -eq 0 -o ${RC} -eq 2 ] ; then  # {
        if [ "${font_check_name}" = "$2" ] ; then  # {
          printf "  ${ATTR_GREEN_BOLD}FONT CHECK - ${ATTR_OFF}" ;
          printf "‘${ATTR_GREEN}%s${ATTR_CLR_BOLD}’ is an exact match " "$2" ;
          printf "for the Style's font name\n" ;
        else  # }{
          printf "  ${ATTR_BROWN_BOLD}FONT CHECK - ${ATTR_OFF}" ;
          printf "‘${ATTR_YELLOW}%s${ATTR_OFF}’ found; use " "$2" ;
          printf "‘${ATTR_YELLOW}%s${ATTR_OFF}’ as the Style’s font name\n" \
                 "${font_check_name}" ;
        fi  # }
      fi  # }
      shift 2;
      ;;
    --srt-default-font)
      G_OPTION_SRT_DEFAULT_FONT_NAME="$(check_font_name "${G_OPTION_SRT_DEFAULT_FONT_NAME}" "$1" "$2" 0)" ;
      echo "  NEW 'Default' FONT = '${G_OPTION_SRT_DEFAULT_FONT_NAME}'" ;
      shift 2;
      ;;
    --srt-italics-font)
      G_OPTION_SRT_ITALICS_FONT_NAME="$(check_font_name "${G_OPTION_SRT_ITALICS_FONT_NAME}" "$1" "$2" 0)" ;
      echo "  NEW 'Italics' FONT = '${G_OPTION_SRT_ITALICS_FONT_NAME}'" ;
      shift 2;
      ;;
    --srt-font-size-percent)
      olde_value="${G_OPTION_SRT_FONT_SIZE}" ;
      clean_arg="$(echo "$2" | "${SED}" -e 's/%[ ]*$//')"
      G_OPTION_SRT_FONT_SIZE="$(apply_percentage "$1" "${clean_arg}" "${olde_value}" 1)" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} SubRip’s font size ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_SRT_FONT_SIZE}" ;
          printf '%s\\n' "${ATTR_CLR_BOLD} (${clean_arg}%).${ATTR_OFF}")" ;
        # TODO :: add a note about this to the comments IF the video really has SubRip subtitles
      shift 2;
      ;;
    --audio-stream)
      olde_value="${G_OPTION_AUDIO_STREAM}" ;
      G_OPTION_AUDIO_STREAM="$(get_option_track_or_stream "$1" "$2")" ; RC=$? ;
      G_OPTION_AUDIO_STREAM_TYPE=${RC} ;
      G_OPTION_AUDIO_STREAM_SET=1 ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} audio stream # filter ${ATTR_CLR_BOLD}" ;
          echo -n "(from “${ATTR_OLIVE_BOLD}${olde_value}${ATTR_CLR_BOLD}”)"
          echo -n " ${ATTR_YELLOW_BOLD}to “${ATTR_GREEN_BOLD}${G_OPTION_AUDIO_STREAM}" ;
          printf    "${ATTR_YELLOW_BOLD}”${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --subs-track)
      olde_value="${G_OPTION_SUBTITLE_TRACK}" ;
      G_OPTION_SUBTITLE_TRACK="$(get_option_track_or_stream "$1" "$2")" ; RC=$? ;
      G_OPTION_SUBTITLE_TRACK_TYPE=${RC} ;
      G_OPTION_SUBTITLE_TRACK_SET=1 ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} subtitle track filter ${ATTR_CLR_BOLD}" ;
          echo -n "(from “${ATTR_OLIVE_BOLD}${olde_value}${ATTR_CLR_BOLD}”)"
          echo -n " ${ATTR_YELLOW_BOLD}to “${ATTR_GREEN_BOLD}${G_OPTION_SUBTITLE_TRACK}" ;
          printf    "${ATTR_YELLOW_BOLD}”${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-text-margin)
      olde_value="${G_OPTION_TRN_MARGIN}" ;
      G_OPTION_TRN_MARGIN="$(get_option_integer "$1" "$2" 15 250)" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s left and right margin ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_TRN_MARGIN}" ;
          printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-text-margin-vertical)
      olde_value="${G_OPTION_TRN_MARGINV}" ;
      G_OPTION_TRN_MARGINV="$(get_option_integer "$1" "$2" 0 80)" ; # You'd probably never want to go to 0
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s vertical margin ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_TRN_MARGINV}" ;
          printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-font-primarycolor)
      olde_value="${G_OPTION_TRN_PRIMARYCOLOR}" ;
      G_OPTION_TRN_PRIMARYCOLOR="$(get_color_spec "$1" "$2" "${olde_value}")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s PrimaryColor ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value}$(build_colour ${olde_value} ', ' "${FB_CHAR}"))${ATTR_OFF} "
          echo -n "${ATTR_CLR_BOLD}to ${G_OPTION_TRN_PRIMARYCOLOR}" ;
          echo -n "$(build_colour $2 ', ' "${FB_CHAR}")" ;
          printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-font-outlinecolor)
      olde_value="${G_OPTION_TRN_OUTLINECOLOR}" ;
      G_OPTION_TRN_OUTLINECOLOR="$(get_color_spec "$1" "$2" "${olde_value}")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s OutlineColor ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value}$(build_colour ${olde_value} ', ' "${FB_CHAR}"))${ATTR_OFF} "
          echo -n "${ATTR_CLR_BOLD}to ${G_OPTION_TRN_OUTLINECOLOR}" ;
          echo -n "$(build_colour $2 ', ' "${FB_CHAR}")" ;
          printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-font-outlineweight)
      olde_value="${G_OPTION_TRN_OUTLINE_WEIGHT}" ;
      G_OPTION_TRN_OUTLINE_WEIGHT="$(get_decimal_number "$1" "$2" '0.0' '25.0')" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s outline weight ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}$2" ;
          printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-font-size-percent)
      olde_value="${G_OPTION_TRN_FONT_SIZE}" ;
      clean_arg="$(echo "$2" | "${SED}" -e 's/%[ ]*$//')"
      G_OPTION_TRN_FONT_SIZE="$(apply_percentage "$1" "${clean_arg}" "${olde_value}" 1)" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s font size ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_TRN_FONT_SIZE}" ;
          printf '%s\\n' "${ATTR_CLR_BOLD} (${clean_arg}%).${ATTR_OFF}")" ;
        # TODO :: add a note about this to the comments IF the video really has a transcript
      shift 2;
      ;;
    --trn-delay-ms)
        #######################################################################
        # Transcripts have a 1 second resolution and the text is usually early
        # with the audio.  A lot can happen in 1 second and it's noticeable
        # when the text appears too early with the audio.
        #
        # This allows the user to uniformly apply an adjustment in milliseconds
        # to the starting time of each line in the transcript (and of course,
        # the ending time will change accordingly).  I thought of limiting to
        # ±1000 milliseconds but, for whatever, will allow ±5000 milliseconds.
        #
        # It'd be really kool to have a tool that could indicate a timestamp
        # when speech starts around each line's timestamp since the error
        # varies from line to line.  I dunno if there are Linux CLI tools that
        # can seamlessly do something like that ...
        #
      olde_value="${G_OPTION_TRN_TEXT_OFFSET_MS}" ;
      G_OPTION_TRN_TEXT_OFFSET_MS="$(get_option_integer "$1" "$2" -5000 5000)" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s subtitle delay ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value}ms) to ${ATTR_GREEN_BOLD}$2" ;
          printf    "${ATTR_CLR_BOLD}ms.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-word-time-percent)
      olde_value="${G_OPTION_TRN_WORD_TIME}" ;
      clean_arg="$(echo "$2" | "${SED}" -e 's/%[ ]*$//')"
      G_OPTION_TRN_WORD_TIME="$(apply_percentage "$1" "${clean_arg}" "${olde_value}" 1)" ;
        #######################################################################
        # TODO :: FIXME :: The following is a "hack" as the functions that use
        # 'G_OPTION_TRN_WORD_TIME' do NOT handle a decimal number correctly.
        # This should be fixed __there__ in those functions.
        #
      G_OPTION_TRN_WORD_TIME=${G_OPTION_TRN_WORD_TIME%.*} ; # truncate F.P. #
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s per/word time ${ATTR_CLR_BOLD}" ;
          echo -n "(from ${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_TRN_WORD_TIME}" ;
          printf '%s\\n' "${ATTR_CLR_BOLD} (${clean_arg}%).${ATTR_OFF}")" ;
        # TODO :: add a note about this to the comments IF the video really has a transcript
        # TODO :: As with 'G_OPTION_MESSAGES', add a COMMENT "collector" variable for
        #         each type of (say) input.  So, transcript override CLI options
        #         would be collected in this variable and __only__ written to the
        #         comments if the encoding was a transcript driver video.  Neat.
      shift 2;
      ;;
    --trn-word-time-ms)
      olde_value="${G_OPTION_TRN_WORD_TIME}" ;
      G_OPTION_TRN_WORD_TIME="$(get_option_integer "$1" "$2" ${G_TRN_WORD_TIME_MIN})" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s per/word time ${ATTR_CLR_BOLD}" ;
          echo -n "(${olde_value})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_TRN_WORD_TIME}" ;
          printf    "${ATTR_CLR_BOLD}.${ATTR_OFF}\\\n")" ;
      shift 2;
      ;;
    --trn-words-threshold)
      olde_value="${G_OPTION_TRN_WC_THRESHOLD}" ;
      G_OPTION_TRN_WC_THRESHOLD="$(get_option_integer "$1" "$2" 2 40)" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          echo -n "  ${ATTR_SETTING} transcript’s word count threshold "
          echo -n "for End time recalculation${ATTR_CLR_BOLD} " ;
          echo -n "(${olde_value})${ATTR_OFF} to " ;
          printf "${ATTR_GREEN_BOLD}%d${ATTR_CLR_BOLD} words.${ATTR_OFF}\\\n"\
                 "${G_OPTION_TRN_WC_THRESHOLD}")" ;
      shift 2;
      ;;
    --trn-language)
      G_OPTION_TRN_LANGUAGE="$(get_option_string "$1" "$2")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_SETTING} transcript’s spell check language to " ;
          printf "${ATTR_CLR_BOLD}'${ATTR_GREEN_BOLD}%s${ATTR_CLR_BOLD}'.\\\n" \
                 "${G_OPTION_TRN_LANGUAGE}")" ;
      shift 2;
      ;;
    --trn-disable-sed)
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_DISABLE} transcript’s sed scripts.${ATTR_OFF}\\\n")" ;
      G_OPTION_TRN_SED_SCRIPT_DISABLE=1 ; shift ;
      ;;
    --preset)
      if [ "${option_preset}" = '' ] ; then  # {
        option_preset="$(get_option_string "$1" "$2")" ;
      else  # }{
        : ; # FIXME :: FLAG AS A WARNING, and IGNORE
            # NOTE :: an embedded CLI file will replace a '--preset' option
      fi  # }
      shift 2;
      ;;
    --genre)
      G_OPTION_GENRE="$(get_option_string "$1" "$2")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_SETTING} video’s metadata genre to " ;
          printf "${ATTR_CLR_BOLD}'${ATTR_GREEN_BOLD}%s${ATTR_CLR_BOLD}'.\\\n" \
                 "$2")" ;
      shift 2;
      ;;
    --title|-t)
      G_OPTION_TITLE="$(get_option_string "$1" "$2")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_SETTING} video’s metadata “title” to " ;
          printf "${ATTR_CLR_BOLD}'${ATTR_GREEN_BOLD}%s${ATTR_CLR_BOLD}'.\\\n" \
                 "$2")" ;
      shift 2;
      ;;
    --artist)
      G_OPTION_ARTIST="$(get_option_string "$1" "$2")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_SETTING} video’s metadata “artist” to " ;
          printf "${ATTR_CLR_BOLD}'${ATTR_GREEN_BOLD}%s${ATTR_CLR_BOLD}'.\\\n" \
                 "$2")" ;
      shift 2;
      ;;
    --tune)
      G_OPTION_FFMPEG_TUNE="$(get_option_string "$1" "$2")" ;
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_SETTING} ffmpeg’s “-tune” to " ;
          printf "${ATTR_CLR_BOLD}'${ATTR_GREEN_BOLD}%s${ATTR_CLR_BOLD}'.\\\n" \
                 "$2")" ;
      shift 2;
      ;;
    -v|--verbose)
      G_OPTION_VERBOSE='y' ; shift ;
      ;;
    -h|--help)
      # TODO allow help arg to be an option in which detailed option help is displayed
      case "$2" in
       '')     my_usage 0 ;        ;;
       'full') my_usage 0 "'$2'" ; ;;
       *)      my_usage 1 "'$2'" ; ;;
      esac
      ;;
    --)
      shift ;
      break ;
      ;;
    *)
      echo -n "${ATTR_ERROR} fatal script error - option handler for " ;
      echo    "'${ATTR_YELLOW_BOLD}$1${ATTR_OFF}' not written!!!" ;
      echo    "${ATTR_YELLOW_BOLD}Terminating...${ATTR_OFF}" >&2 ; exit 5 ;
      ;;
    esac  # }
  done ;  # }

    ###########################################################################
    # Okay, see if we're expecting a video filename ...
    #
  if [ "${G_IN_VIDEO_FILE}" = '' ] ; then  # {
    if [ $# -eq 0 ] ; then  # {
      printf "${ATTR_ERROR} no input filename was specified\n" $# ;
      abort ${FUNCNAME[0]} ${LINENO};
    elif [ $# -ne 1 ] ; then  # }{
      printf "${ATTR_ERROR} extra arguments∕filenames were specified (argc = %d)\n" $# ;
      abort ${FUNCNAME[0]} ${LINENO};
    fi  # }

    G_IN_VIDEO_FILE="$1" ; shift ;

  else  # }{

      #########################################################################
      # (You can't specify ∕ change the video filename in a CLI aux script ☻.)
      #
    if [ $# -ne 0 ] ; then  # {
      printf "${ATTR_ERROR} extra arguments∕filenames were specified (argc = %d)\n" $# ;
      abort ${FUNCNAME[0]} ${LINENO};
    fi  # }
  fi  # }

    ###########################################################################
    # If we make it this far, “G_IN_VIDEO_FILE” is __always__ set, let's:
    # - ensure that it's not an EMPTY file, and
    # - see if the user wants to probe its tracks ...
    #
  if ! [ -s "${G_IN_VIDEO_FILE}" ] ; then
    printf "${ATTR_ERROR} ${ATTR_BOLD}‘${ATTR_YELLOW}%s${ATTR_CLR_BOLD}’\n" \
           "${G_IN_VIDEO_FILE}" ;
    printf "        ${ATTR_RED_BOLD}%s${ATTR_OFF}\n" \
           'Is not there, is an EMPTY file, or is a broken link.' ;
    abort ${FUNCNAME[0]} ${LINENO};
  fi

    ###########################################################################
    # Some options require a valid input video, which we'll have now.
    # NOTE :: an embedded '--preset' will replace an existing preset (designed)
    #
  configure_preset "${G_IN_VIDEO_FILE}" "${option_preset}" ;

  return ${do_probe} ;
}


###############################################################################
# Check_embedded_options(in_video)
#
# Look for an embedded CLI in one of two places (in this order):
# 1. The basename of the dirname of the video + ‘C_EMBEDDED_SUFFIX’ with one
#    or more “#C” line(s);
#  AND/OR
# 2. The basename of the video + ‘C_EMBEDDED_SUFFIX’ with with one or more
#    “#C” line(s).  This file will be in the ‘C_SUBTITLE_IN_DIR’ and shares
#    functionality with a transcript.
#
# Let's start with 2. as that's the simplest to provide a use-case for.
#
# Case 1 is provided for batching a group of input videos.
#
# QQQQ :: TODO :: check for other '#Options' here (e.g. #H) ..?
#
check_embedded_options() {
  local cli_file="$1" ; shift ;
  local cli_source=$1 ; shift ; # 0 = .cli file; 1 is from a transcript file

  if false ; then  # {
    : # TODO :: also allow a '.cli' file to be specified on the command line ..?
  fi  # }

  if [ -s "${cli_file}" -a -r "${cli_file}" ] ; then  # {

    local cli_options='' ; # We also allow trailing comments on the lines.
    "${GREP}" ${GREP_OPTS} "^${C_TRN_TAG_EMBEDDED_CLI}[ ]" "${cli_file}" \
      | "${SED}" -e "s/^${C_TRN_TAG_EMBEDDED_CLI}[ ]//" \
                 -e 's/[ \t][ \t]*#.*$//'               \
      | while read cli_line ; do  # {
 
         cli_options="${cli_options} ${cli_line}" ;

         # QQQQ :: TODO :: check for other '#Options' here (e.g. #H) ..?

      done  # }
      ${DBG} printf 'DEBUG :: ‘%s’\n' "${cli_options}" ;

    if [ "${cli_options}" != '' ] ; then  # {
      G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
        printf "  ${ATTR_ORANGE_BOLD}FOUND -${ATTR_CLR_BOLD} embedded CLI options in " ;
        printf "‘${ATTR_YELLOW}%s${ATTR_CLR_BOLD}’ ...${ATTR_OFF}\\\n" "${cli_file}")" ;

        #######################################################################
        # If we can't 'eval' the string, the best we can do is quit the script.
        #
        # This usually happens if an option's argument is not properly escaped.
        # And example might be --title="This is a "test"".  It needs to appear
        # as --title="this is a \\\"test\\\"".  If the option's argument is
        # enclosed in single quotes, then no escaping is required, e.g. -->
        # --title='this is a "test"'.
        #
        # I don't think there's an easy to auto-escape this quoting process as
        # it'd be difficult to tell when a character needs escaping given how
        # the eval string is built from the transcript file.  An inconvenience.
        #
      eval set -- "${cli_options}" ;
        if [ $? -ne 0 ] ; then abort ${FUNCNAME[0]} ${LINENO}; fi ;
      check_getopt 1 "$@" ; # NOTE :: '--do_probe' is effectively ignored
    else  # }{
      : ; # if it's EMPTY, make a note in G_OPTION_MESSAGES only
          # if it was a '.cli' file (and not a transcript file).
    fi  # }
  fi  # }

  if false ; then  # {
    : # TODO :: check in 'C_SUBTITLE_IN_DIR'
  fi  # }

  { set +x ; } >/dev/null 2>&1
}


###############################################################################
# Check_transcript_embedded_options(transcript_files ...)
#
check_transcript_embedded_options() {
    ###########################################################################
    #
    #
  while [ $# -gt 0 ] ; do  # {
    local transcript_file_in="$1" ; shift ;

    check_embedded_options "${transcript_file_in}" 1 ;
  done ;  # }
}


###############################################################################
# check_installed_tools()
#
# Check to ensure we have all of the necessary tools installed, Abort the
# script if something important is missing, otherwise disable said feature.
#
check_installed_tools() {

    ###########################################################################
    # ASPELL
    #
  local cmd_base="$(printf '%s' "${ASPELL}" | cut -d' ' -f1)" ;
  MSG="$(type "${cmd_base}" 2>&1)" ; RC=$? ;
  if [ ${RC} -eq 0 ] ; then  # {

    MSG="$(printf '%s' "${G_OPTION_TRN_LANGUAGE}" | ${ASPELL} 2>&1)" ;

    if [ "${MSG}" = "${G_OPTION_TRN_LANGUAGE}" ] ; then  # {
      MSG="${ATTR_CLR_BOLD}The word ${ATTR_MAGENTA_BOLD}'${G_OPTION_TRN_LANGUAGE}'" ;
      MSG="${MSG}${ATTR_CLR_BOLD} was NOT found by '${cmd_base}'." ;
      printf "  ${ATTR_NOTE} ${ATTR_CLR_BOLD}%s\n" "${MSG}" ;
      printf "         ${ATTR_YELLOW}%s\n" \
             "Spell and auto correction of the transcript may NOT work as expected." ;
    fi  # }
  else  # }{
    printf "  ${ATTR_NOTE} ${ATTR_CLR_BOLD}%s\n" "${MSG}" ;
    printf "         ${ATTR_RED_BOLD}%s\n" \
           "Spell and auto correction of the transcript will be disabled." ;
    G_HAVE_TOOL_ASPELL=0 ;
  fi  # }

  { set +x ; } >/dev/null 2>&1
  tput sgr0 ;
}


###############################################################################
# get_video_title()
#
# The *way* ffmpeg seems to work (probably documented somewhere) is that if a
# metadata tag is __set__ in the source, then that metadata is copied to the
# output file.  I haven't tested to see if there's any filtering done in this
# process (e.g. coping a video specific tag to an audio only output file), but
# since this script doesn't do those types of conversions, I'll skip it 4 now.
#
# TODO :: return codes : 0 = SUCCESS.
#                        1 = ERROR
#                        2 = Artist is available.  Artist is built from parsing
#                            the "Artist - Title" and only if there is NO 'Artist'
#                            already set in the video.  So call again to get the
#                            cached 'Artist' string.
#
# So, basically if it's set in the video's source, don't override it:
# - If 'in_title' is set (by the user), then use that for the video's title;
# - if the video contains a title, then use that title (by returning an EMPTY
#   string in which case ffmpeg will copy the title during re-encoding);
#
# !! IN all cases, we'll escape the title that is returned from this function.
#    Single quotes (') in a video's filename or title were quite the challenge.
#    The solution looks really messy and gnarly but works ...
#
# | "${SED}" -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
#
get_video_title() {
  local in_filename="$1" ; shift ;
  local in_title="$1" ; shift ;
  local in_video_basename="$1" ; shift ;

  local out_title='' ; # The default if 'Title' IS set in the video

  if [ "${in_title}" != '' ] ; then  # {

    out_title="${in_title}" ; # The title is explicitly set by the user

  else  # }{
    local title_in_video="$(${EXIFTOOL} "${in_filename}" \
                     | "${GREP}" ${GREP_OPTS} '^Title' \
                     | "${SED}" -e 's/^.*: //')" ;
    if [ "${title_in_video}" = '' ] ; then  # {
        #######################################################################
        # There is no Title in the video, so make one from the filename.
        # TODO :: use a simple rule-base algorithm to split the name into the
        #         Artist and song Title if there's a hyphen in the filename.
        #         If the split is successful, then cleanup the artist-title by
        #         removing […]s everywhere & (…) from the front of the Artist.
        # ALSO :: if the file is a webm type (say from U-tube), assume the
        #         'Title' field, if present, is always the best video title.
        #
        ## FIXME -- I should do this filtering cleanup elsewhere ...
      out_title="$(echo "${in_video_basename}" \
                 | "${SED}" -e 's/[_+]/ /g')" ;
    elif [ "${G_OPTION_NO_FUZZY}" = '' ] ; then  # }{
        #######################################################################
        # Okay, the source video has a 'Title' metadata tag set.  If the user
        # does NOT want to fuzzy compare it with the video's filename, then
        # we'll return '' and ffmpeg will copy the source 'Title' metadata.
        #
        # We're going to see if the 'Title' field in the source video has any
        # compatibility with the filename of the video.  If it's compatible,
        # then we assume the 'Title' field in the source video is a good name.
        # Otherwise, we'll try to build the video's title from its filename.
        #
        # This crazy method of testing / comparing the 2 strings seems to be
        # the most reliable for detecting a garbage Title string in the source
        # video.  Honestly, I dunno if this is the “proper” way to use agrep.
        #
      local fuzzy_errors=0 ;
      for (( fuzz=1; fuzz <= ${AGREP_FUZZY_ITERS}; fuzz++ )); do  # {
        echo "${in_filename}" \
          | ${AGREP} -${fuzz} -k -i -q "${title_in_video}" ;
        (( fuzzy_errors += $? )) ;
      done  # }
      if [ ${fuzzy_errors} -ge ${AGREP_FUZZY_ERRORS} ] ; then  # {

          ## FIXME -- I should do this filtering cleanup elsewhere ...
        out_title="$(echo "${in_video_basename}" \
                     | "${SED}" -e 's/[_+]/ /g')" ;
      fi  # }
    fi  # }
  fi  # }

  #############################################################################
  # Ensure that any single quotes are escaped.
  # FIXME :: should this  apostrophe fix be done elsewhere?
  ## 'title=The Byrd'"'"'s - Turn! Turn! Turn! (2nafish)'
  #
  echo "$(echo "${out_title}" | "${SED}" -e 's#\([\x27]\)#\1"\1"\1#g')" ;
}


###############################################################################
###############################################################################
#
get_video_genre() {
  local in_filename="$1" ; shift ;
  local in_genre="$1" ; shift ;
  local in_default_genre="$1" ; shift ;

  local out_genre='' ; # The default if 'Genre' IS set in the video

  if [ "${in_genre}" != '' ] ; then  # {

    out_genre="${in_genre}" ; # The genre is explicitly set by the user

  else  # }{

    local genre_in_video="$(${EXIFTOOL} "${in_filename}" \
                     | "${GREP}" ${GREP_OPTS} '^Genre' \
                     | "${SED}" -e 's/^.*: //')" ;
    if [ "${genre_in_video}" = '' ] ; then  # {
        #######################################################################
        # There is no Genre in the video, so use the default.
        #
      out_genre="${in_default_genre}" ;
    else  # }{
        #######################################################################
      : # The Genre IS set in the video, ffmpeg will copy it while re-encoding.
        #
    fi  # }
  fi  # }

  #############################################################################
  # Ensure that any single quotes are escaped.  FIXME should be done elsewhere?
  # TODO :: Do I also need to escape any ',' character(s) in the genre?
  #
  echo "$(echo "${out_genre}" | "${SED}" -e 's#\([\x27]\)#\1"\1"\1#g')" ;
}


###############################################################################
###############################################################################
#
get_video_artist() {
  local in_filename="$1" ; shift ;
  local in_artist="$1" ; shift ;
  local in_default_artist="$1" ; shift ;

  local out_artist='' ; # The default if 'Artist' IS set in the video

  if [ "${in_artist}" != '' ] ; then  # {

    out_artist="${in_artist}" ; # The artist is explicitly set by the user

  else  # }{

    # TODO :: See if the '^Title' contains the Artist FIXME
    #         ALSO, will need to patch-up 'get_video_title()' for same changes
    local artist_in_video="$(${EXIFTOOL} "${in_filename}" \
                     | "${GREP}" ${GREP_OPTS} '^Artist' \
                     | "${SED}" -e 's/^.*: //')" ;
    if [ "${artist_in_video}" = '' ] ; then  # {
        #######################################################################
        # There is no Artist in the video, so use the default.
        #
      out_artist="${in_default_artist}" ; # TODO :: do something different?
    else  # }{
        #######################################################################
      : # Artist IS set in the video, ffmpeg will copy it while re-encoding.
        #
    fi  # }
  fi  # }

  #############################################################################
  # Ensure that any single quotes are escaped.  FIXME should be done elsewhere?
  # TODO :: Do I also need to escape any ',' character(s) in the genre?
  #
  echo "$(echo "${out_artist}" | "${SED}" -e 's#\([\x27]\)#\1"\1"\1#g')" ;
}


###############################################################################
###############################################################################
#   ######
#   #       ####   #    #   #####   ####
#   #      #    #  ##   #     #    #
#   ####   #    #  # #  #     #     ####
#   #      #    #  #  # #     #         #
#   #      #    #  #   ##     #    #    #   ###   ###   ###
#   #       ####   #    #     #     ####    ###   ###   ###
###############################################################################
# Extract and install any font attachments that are in the INPUT file.
#
# NOTE -- NO FONT will ever be overwritten by this function.
#
# WISH :: Since we extracted the subtitle first, we could scan the subtitle
#         file for all referenced fonts, then see if they exist in the video.
#         This is probably way out-of-scope for this script for a couple of
#         reasons:
#       - it's very rare to have a missing font in the video file; and
#       - it's non-trivial to see if the font's filename matches the font
#         name in the ASS subtitle file.  So, probably not gonna happen ...
#
extract_font_attachments() {

  local in_video="$1" ; shift ;
  local attachments_dir="$1" ; shift ; # save location for the font attachments
  local ignore_no_attachments="$1" ; shift ; # no font attachments are OKAY

  echo    "  ${ATTR_BOLD}GETTING FONTS FOR VIDEO ..." ;

  local attachment_line='' ;
  local attachment_list='' ;
  local pad_spaces='    ' ;

  ERR_MKVMERGE=0; # Nuttin's EASY -- font attachment identifiers, is there
                  #                  a comprehensive list somewhere ...?
                  # I have: truetype, opentype, font.ttf, and font.otf.

  local have_font_attachments='' ;

  ${MKVMERGE} -i "${in_video}" | egrep 'truetype|opentype|font.ttf|font.otf' \
                               | while read attachment_line ; do # {

    have_font_attachments='Y' ;

      #########################################################################
      # Attachment IDs are NOT always sequential, so we need to capture each
      # attachment's ID.  Also, attachment names may have embedded SPACEs.
      #
    local attachment_ID=`echo "${attachment_line}" \
                        | "${SED}" -e 's/Attachment ID \([0-9][0-9]*\):.*$/\1/'` ;
    local attachment_file=`echo "${attachment_line}" \
                        | "${CUT}" -d' ' -f 11- \
                        | "${SED}" -e "s/'//g"` ;

    local font_pathname="${attachments_dir}/${attachment_file}" ;

    if [ ! -f "${font_pathname}" ] ; then # {
      attachment_list="${attachment_list}${attachment_ID}:${font_pathname} " ;
      MSG="`${MKVEXTRACT} attachments \"${in_video}\" \"${attachment_ID}:${font_pathname}\"`" ;
      if [ $? -eq 0 ] ; then  # {
        echo    "${MSG}" \
          | "${SED}" -e "s/.*is written to \(.*\).$/${pad_spaces}<< ${ATTR_BLUE_BOLD}EXTRACTING ${ATTR_CLR_BOLD}${attachment_ID}:${attachment_file}${ATTR_OFF} to ${ATTR_CYAN_BOLD}\1${ATTR_OFF}. >>/" \
          | "${SED}" -e "s#${HOME}#\\\${HOME}#g" ;
      else  # }{
        ERR_MKVMERGE=1;
        MSG="`echo -n \"${MSG}\" | "${TAIL}" -1 | cut -d' ' -f2-`" ;
        echo    "${ATTR_ERROR} ${MSG}" ;
      fi  # }
    else # }{
      echo -n "${pad_spaces}<< ${ATTR_YELLOW}SKIPPING ALREADY INSTALLED " ;
      echo    "${ATTR_MAGENTA}${attachment_ID}:${attachment_file}${ATTR_OFF}. >>" ;
    fi ; # }

  done ; # }

  if [ "${have_font_attachments}" = 'Y' ] ; then # {
    if [ "${attachment_list}" != '' -a ${ERR_MKVMERGE} -eq 0 ] ; then # {
      if [ false -a "${HS_FC_CACHE}" != '' ] ; then

        #######################################################################
        # - Note that this sctipt WILL NOT overwrite the font __file__ if it
        #   already exists in the 'attachments_dir'.
        # - NOTE :: adding fonts from some videos can sometimes mess with the
        #   system-installed fonts if the 'attachments_dir' is locally visible
        #   to the 'fontconfig' system installed on your computer (solution --
        #   simply set 'attachments_dir' to something else, maybe local to the
        #   video to re-encode).
        #
        echo "${ATTR_YELLOW_BOLD}Adding new FONTs using '${HS_FC_CACHE}' ${ATTR_OFF}..." ;
        ${HS_FC_CACHE} "${attachments_dir}" ;
      fi
    else  # }{
      echo -n "${ATTR_BOLD}${pad_spaces}Note - there were " ;
      [ ${ERR_MKVMERGE} -ne 0 ] && echo -n "${ATTR_RED_BOLD}errors adding fonts or " ;
      echo "${ATTR_YELLOW_BOLD}no NEW fonts found${ATTR_OFF}." ;
    fi # }

  elif [ ${ignore_no_attachments} -eq 0 ] ; then  # }{

      #########################################################################
      # I have seen videos (although rare) that contain a subtitle track, but
      # do not have the referenced font(s) in the subtitle as attachments.
      # ffmpeg will not "see" this and it seems libass won't indicate the loss.
      # It's hard to tell how these subtitles will render (either nothing at
      # all or libass will perform a font substitution with lackluster results,
      # or the font is already installed on the system and is rendered fine).
      #
      # So we'll warn the user of this situation UNLESS it's an SRT subtitle
      # in which case this is the expected condition.
      #
    echo -n "${pad_spaces}${ATTR_YELLOW_BOLD}${ATTR_BLINK}" ;
    echo -n "NOTE${ATTR_OFF}${ATTR_YELLOW}, " ;
    echo    "this video file contains no FONT attachments.${ATTR_OFF}" ;
  fi # }

}


###############################################################################
###############################################################################
# extract_subtitle_track()
#
# Extract the subtitle specified by the 'subtitle_track' argument and save it
# to 'save_to_file'.  The subtile can be an ASS or SRT subtitle.
#
# Note, this is only called to perform an initial extraction.  If the subtitle
# is already in 'save_to_file', an different code path is take and this
# function is not called.
#
extract_subtitle_track() {
  local in_video="$1" ; shift ;
  local save_to_file="$1" ; shift ;
  local track_ID="$1" ; shift ;


  echo -n "   ${ATTR_CYAN_BOLD}Track ${ATTR_CLR_BOLD}${track_ID} ==> " ;
  echo    "${ATTR_YELLOW}'$(basename "${save_to_file}")' ${ATTR_OFF}..." ;

  ${MKVEXTRACT} tracks "${in_video}" "${track_ID}:${save_to_file}" \
    >/dev/null 2>&1 ;
}


###############################################################################
###############################################################################
# apply_script_to_srt_subtitles()
#
# SRT subtitles are always converted to ASS subtitles using ffmpeg as it
# provides quite a bit of versatility.
# This function provides a way to edit those subtitles, if desired.
#
# This applies some simple enhancements to the ASS script built by ffmpeg.
# Usually SRT subtitles are kinda bland and this makes them a little better.
#
apply_script_to_srt_subtitles() {

  local L_SKIP_OPTION="$1" ; shift ;
  local ASS_SRC="$1" ; shift ;
  local ASS_DST="$1" ; shift ;

  if [ "${L_SKIP_OPTION}" = 'y' ] ; then
    echo 'SKIPPING SED EDITS ON SRT SUBTITLE' ;
    ${CP} "${ASS_SRC}" "${ASS_DST}" ; # Don't use '-p' to preserve this copy
    return ;
  fi

  #############################################################################
  # There might be better / more elegant ways to do this ...
  #
  # So, the editing is done using an array of PAIRs of sed regexs which are
  # fed to a sed ‘s///’ expression.  The first part of the pair is the search
  # regex, and the 2nd part is the replacement string for the match.
  #
  # The best way to see how this works is to look at the expression pairs --
  # I've included a couple of commented out more complicated examples of what
  # can be done.
  #
  # Because libass allows for and provides complex control over the subtitles,
  # breaking up the sed command was the easiest way to manage all of the
  # complex shell escaping necessary for it to all work smoothly.  There are
  # quite a few special character collisions that have to be handled and I
  # think I've handled the ones I'm aware.  There might still be cases that
  # I missed (most probably), but I think this is pretty robust as it stands.
  #
  SED_SCRIPT_ARRAY=(
    '^Format: Name,.*'
      'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding%%%x0aStyle: Italics,'"${G_OPTION_SRT_ITALICS_FONT_NAME}"','"${G_OPTION_SRT_FONT_SIZE}"',&H30FF00DD,&H000000FF,&H00101010,&H20A0A0A0,0,1,0,0,100,100,0,0,1,2.2,0,2,105,105,11,1'
      #########################################################################
      # Normally, these are already specified correctly for an 'ASS' subtitle.
      # These are here for the cases where ffmpeg is used to convert a 'SRT'
      # subtitle to an 'ASS' subtitle where the default value ffmpeg chooses
      # is incorrect for the video that is being encoded.
      #
    '^PlayResX:.*'       # Note - differences for PlayResX / PlayResY affect
        'PlayResX: 848'  #        the Fontsize and Outline values, and the
    '^PlayResY:.*'       #        drawing position of items in each frame.
        'PlayResY: 480'

    'Style: Default,.*'
        'Style: Default,'"${G_OPTION_SRT_DEFAULT_FONT_NAME}"','"${G_OPTION_SRT_FONT_SIZE}"',&H6000F8FF,&H000000FF,&H00101010,&H50A0A0A0,-1,0,0,0,100,100,0,0,1,2.75,0,2,100,100,12,1'
      #########################################################################
      # - Note that the necessary _replacement_ escapes are added by the MAIN
      #   script, i.e., the '&' character does not need to be and should NOT
      #   be escaped in the replacement part.
      # - Because some libass directives are preceded by a '\' character, e.g.
      #   '{\pos(13,80)}'.  This makes using the '\' character a little tricky
      #   Consider the following sed script pair (from a converted SRT file):
      #
    '^Dialogue: \(.*\),Default,\(.*\),{\\i1}\(.*\){\\i[0]*}$'
        'Dialogue: %%%1,Italics,%%%2,%%%3'
      #
      #   Its purpose is to detect a line that is all italic, and select a
      #   different style for that Dialogue line keeping everything else the
      #   same.  In this case, the \1, \2, and \3 capture buffer specifiers
      #   are represented as %%%1, %%%2, and %%%3 in the replacement string.
      #   Ugly, I know.
  ) ;

  # https://unix.stackexchange.com/questions/181937/how-create-a-temporary-file-in-shell-script
  G_SED_FILE="$(mktemp "/tmp/${C_SCRIPT_NAME}-sed.XXXXXX")" ;
# exec 3>"${G_SED_FILE}" ;
# exec 4<"${G_SED_FILE}" ;
# /bin/rm -f "${G_SED_FILE}" ;

  { # (I'm not going to bother adjusting the indent for this block ...)
  local ido=0 ;
  local idx=0 ;

  while [ "${SED_SCRIPT_ARRAY[$idx]}" != '' ] ; do  # {

    (( ido = (idx / 2) + 1 )) ; # A temp for displaying the regex index
    printf "${ATTR_BROWN_BOLD}%.2d${ATTR_OFF}." ${ido} ;

      #########################################################################
      # Insane shell escape sequences - also, the sed '-e' ordering is
      # important.  This is because some .ASS directives are preceded by a
      # '\', e.g. {\pos(13,80)}.  Note, regex captures are complicated to code
      # -- I ended up using '%%%' to represent the '\' character to simplify
      # the scripting.
      #
    "${GREP}" ${GREP_OPTS} -q "${SED_SCRIPT_ARRAY[$idx]}" "${ASS_SRC}" ; RC=$? ;
    if [ ${RC} -eq 0 ] ; then  # {
      echo -n "${ATTR_GREEN_BOLD}." ;
      (( ido = idx + 1 )) ;
      REPLACEMENT_STR=`echo "${SED_SCRIPT_ARRAY[$ido]}" \
          | "${SED}" -e 's#\\\#\\\\\\\#g'   \
                     -e 's/,&H/,\\\\\&H/g'  \
                     -e 's/%%%/\\\/g'`;
      echo -n '! ' ;

      echo "s#${SED_SCRIPT_ARRAY[$idx]}#${REPLACEMENT_STR}#" \
        >> "${G_SED_FILE}" ;

    else  # }{  Yeah, I know I made this way too fancy ...
      echo -n "${ATTR_YELLOW_BOLD}.. " ;
    fi  # }
    echo -n "${ATTR_OFF}" ;

    (( idx += 2 )) ;
  done  # }

  #############################################################################
  # Note, if you want to use '--regexp-extended' then some of the expressions
  # need to be redone because of the syntax difference between the two modes.
  # It just might be better to include another sed script here instead.
  #
  # Note, sometimes we may generate an EMPTY script -- it's okay, we'll run
  # sed anyway since it's just easier to do and no error results ...
  #
  echo -n 'DOS..'
  cat "${ASS_SRC}"  \
      | ${DOS2UNIX} \
      | "${SED}" "--file=${G_SED_FILE}" \
    > "${ASS_DST}" ;
  echo ".${ATTR_OFF}" ;

    ###########################################################################
    # This had me going for a bit -- fold seems to count all characters,
    # including the invisible terminal control codes!  So I had to guesstimate
    # a bit about the correct width to use.  It's a hack to keep the display
    # width to about 76 __visible__ columns ...
    #
  } | ${FOLD} --width=360 --spaces \
    | sed -e 's/^/    /' ;
}


###############################################################################
###############################################################################
# This applies some simple enhancements to the ASS script built by ffmpeg.
#
apply_script_to_ass_subtitles() {  # input_pathname  output_pathname

  local L_SKIP_OPTION="$1" ; shift ;
  local ASS_SRC="$1" ; shift ;
  local ASS_DST="$1" ; shift ;
  local ASS_SCRIPT="$1" ; shift ; # If = '', then we'll use a "default"

  if [ "${L_SKIP_OPTION}" = 'y' ] ; then
    echo 'SKIPPING SED EDITS ON ASS SUBTITLE' ;
    ${CP} "${ASS_SRC}" "${ASS_DST}" ; # Don't use '-p' to preserve this copy
    return ;
  fi


  #############################################################################
  # There might be better / more elegant ways to do this ...
  #
  # So, the editing is done using an array of PAIRs of sed regexs which are
  # fed to a sed ‘s///’ expression.  The first part of the pair is the search
  # regex, and the 2nd part is the replacement string for the match.
  #
  # The best way to see how this works is to look at the expression pairs --
  # I've included a couple of commented out more complicated examples of what
  # can be done.
  #
  # Because libass allows for and provides complex control over the subtitles,
  # breaking up the sed command was the easiest way to manage all of the
  # complex shell escaping necessary for it to all work smoothly.  There are
  # quite a few special character collisions that have to be handled and I
  # think I've handled the ones I'm aware.  There might still be cases that
  # I missed (most probably), but I think this is pretty robust as it stands.
  #
  SED_SCRIPT_ARRAY=(
#   '^Format: Name,.*'
#     'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding'

    ###########################################################################
    # Here are a few common ‘Default’ ASS subtitle styles ...
    # TODO :: A cli to add these pairs as needed by the user.
    #
    '^Style: Default,Roboto Medium,.*'
       'Style: Default,Roboto Medium,24,&H4820FAFF,&H000000FF,&H13102810,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,2,100,100,14,0'
    '^Style: Default,Fontin Sans Rg,.*'
       'Style: Default,Fontin Sans Rg,46,&H30EBEFF6,&H000000FF,&H10091A04,&HBE000000,-1,0,0,0,100,100,0,0,1,2.4,1,2,90,90,14,1'
    '^Style: Default,Open Sans Semibold,.*'
       'Style: Default,Open Sans Semibold,45,&H4820FAFF,&H000000FF,&H00020713,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,2,80,80,13,1'
    '^Style: Default,Noto Sans SemBd,.*'
       'Style: Default,Noto Sans SemBd,25,&H4820FAFF,&H000000FF,&H13102810,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,2,80,80,13,1'

    ###########################################################################
    # These are some common additional stylizations ...
    # Wait -- are style names case insensitive in libass?!
    #
    '^Style: main,.*'
          'Style: main,Open Sans Semibold,28,&H58DCECEC,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,2,100,100,11,0'
    '^Style: Main,.*'
          'Style: Main,Open Sans Semibold,28,&H58DCECEC,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,2,100,100,11,0'

    '^Style: Main - Top,.*'
          'Style: Main - Top,Open Sans Semibold,28,&H5820F0F2,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,0'
    '^Style: Main Top,.*'
          'Style: Main Top,Open Sans Semibold,28,&H5820F0F2,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,0'
    '^Style: Top,.*'
          'Style: Top,Open Sans Semibold,28,&H5820F0F2,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,0'
    '^Style: Default - Top,.*'
          'Style: Default - Top,Open Sans Semibold,28,&H5820F0F2,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,0'
    '^Style: top,.*'
          'Style: top,Open Sans Semibold,28,&H5820F0F2,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,0'
    '^Style: On Top,.*'
          'Style: On Top,Open Sans Semibold,28,&H5820F0F2,&H000000FF,&H08101008,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,0'

    '^Style: italics,.*'
       'Style: italics,Open Sans Semibold,28,&H48FF9B6C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,2,100,100,11,1'
    '^Style: Italics,.*'
       'Style: Italics,Open Sans Semibold,28,&H48FF9B6C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,2,100,100,11,1'

    '^Style: Italics_top,.*'
       'Style: Italics_top,Open Sans Semibold,28,&H42FFA27C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: Italics - Top,.*'
       'Style: Italics - Top,Open Sans Semibold,28,&H42FFA27C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: Italics Top,.*'
       'Style: Italics Top,Open Sans Semibold,28,&H42FFA27C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: Top Italics,.*'
       'Style: Top Italics,Open Sans Semibold,28,&H42FFA27C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: italicstop,.*'
       'Style: italicstop,Open Sans Semibold,28,&H42FFA27C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: On Top Italics,.*'
       'Style: On Top Italics,Open Sans Semibold,27,&H42FFA27C,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'

    '^Style: flashback,.*'
     'Style: flashback,Open Sans Semibold,28,&H6000F8FF,&H000000FF,&H08101008,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,2,100,100,11,1'
    '^Style: Flashback,.*'
     'Style: Flashback,Open Sans Semibold,28,&H6000F8FF,&H000000FF,&H08101008,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,2,100,100,11,1'

    '^Style: Flashback - Top,.*'
     'Style: Flashback - Top,Open Sans Semibold,28,&H4000F8FF,&H000000FF,&H08101008,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: flashbacktop,.*'
     'Style: flashbacktop,Open Sans Semibold,28,&H4000F8FF,&H000000FF,&H08101008,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: Flashback Top,.*'
     'Style: Flashback Top,Open Sans Semibold,28,&H4000F8FF,&H000000FF,&H08101008,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,8,100,100,11,1'
    '^Style: Flashback_Italics,.*'
     'Style: Flashback_Italics,Open Sans Semibold,28,&H4000F8FF,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,2,100,100,11,1'
    '^Style: flashback italics,.*'
     'Style: flashback italics,Open Sans Semibold,28,&H4000F8FF,&H000000FF,&H08101008,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,2,100,100,11,1'

    '^Style: Overlap/Flashback,.*'
     'Style: Overlap/Flashback,Open Sans Semibold,28,&H45F2E6F2,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,2.2,0,2,20,20,11,1'

    '^Style: Narration,.*'
     'Style: Narration,Roboto Medium,27,&H38F0F0F0,&H000000FF,&H00000000,&H00000000,0,-1,0,0,100,100,0,0,1,2.2,0,8,20,20,11,1'
  ) ;

  # https://unix.stackexchange.com/questions/181937/how-create-a-temporary-file-in-shell-script
  G_SED_FILE="$(mktemp "/tmp/${C_SCRIPT_NAME}-sed.XXXXXX")" ;
# exec 3>"${G_SED_FILE}" ;
# exec 4<"${G_SED_FILE}" ;
# /bin/rm -f "${G_SED_FILE}" ;

  { # (I'm not going to bother adjusting the indent for this block ...)
  local ido=0 ;
  local idx=0 ;

  while [ "${SED_SCRIPT_ARRAY[$idx]}" != '' ] ; do  # {

    (( ido = (idx / 2) + 1 )) ; # A temp for displaying the regex index
    printf "${ATTR_BROWN_BOLD}%.2d${ATTR_OFF}." ${ido} ;

      #########################################################################
      # Insane shell escape sequences - also, the sed '-e' ordering is
      # important.  This is because some .ASS directives are preceded by a
      # '\', e.g. {\pos(13,80)}.  Note, regex captures are complicated to code
      # -- I ended up using '%%%' to represent the '\' character to simplify
      # the scripting.
      #
    "${GREP}" ${GREP_OPTS} -q "${SED_SCRIPT_ARRAY[$idx]}" "${ASS_SRC}" ; RC=$? ;
    if [ ${RC} -eq 0 ] ; then  # {
      echo -n "${ATTR_GREEN_BOLD}." ;
      (( ido = idx + 1 )) ;
      REPLACEMENT_STR=`echo "${SED_SCRIPT_ARRAY[$ido]}" \
                    | "${SED}" -e 's#\\\#\\\\\\\#g'   \
                             -e 's/,&H/,\\\\\&H/g'  \
                             -e 's/%%%/\\\/g'`;
      echo -n '! ' ;

      echo "s#${SED_SCRIPT_ARRAY[$idx]}#${REPLACEMENT_STR}#" \
        >> "${G_SED_FILE}" ;

    else  # }{  Yeah, I know I made this way too fancy ...
      echo -n "${ATTR_YELLOW_BOLD}.. " ;
    fi  # }
    echo -n "${ATTR_OFF}" ;

    (( idx += 2 )) ;
  done  # }

  #############################################################################
  # Note, if you want to use '--regexp-extended' then some of the expressions
  # need to be redone because of the syntax difference between the two modes.
  # It just might be better to include another sed script here instead.
  #
  # Note, sometimes we may generate an EMPTY script -- it's okay, we'll run
  # sed anyway since it's just easier to do and no error results ...
  #
  echo -n 'DOS..'
  cat "${ASS_SRC}"  \
      | ${DOS2UNIX} \
      | "${SED}" "--file=${G_SED_FILE}" \
    > "${ASS_DST}" ;
  echo ".${ATTR_OFF}" ;

    ###########################################################################
    # This had me going for a bit -- fold seems to count all characters,
    # including the invisible terminal control codes!  So I had to guesstimate
    # a bit about the correct width to use.  It's a hack to keep the display
    # width to about 76 __visible__ columns ...
    # TODO :: It shouldn't be too hard to dynamically calculate this value on
    #         the current terminal, amiright?
    #
  } | ${FOLD} --width=360 --spaces \
    | sed -e 's/^/    /' ;
}


###############################################################################
###############################################################################
# current_start_time="$(my_strptime ${my_state} "${current_line}")" ; RC=$? ;
#
# Working with time in shell script is a B***h at best.
# I think this solution is okay.
#
# Weird behavior -- date -d "(( skipped_lines++ ))" '+%s' is a VALID DATE, but
#                   date -d "(( skipped_lines++ )) ;" '+%s' is NOT!?
# I found this using this script as a transcript file to see what would break.
#
# Returns:
#  0 - is a valid timestamp, the seconds is returned as a string.
#  1 - not a timestamp, s/b the script
#  2 - some sort of fatal error (will I even need this?)
#
my_strptime() {

  local in_state="$1" ; shift ;
  local in_line="$1" ; shift ;
  local ts_pad='' ;

    ###########################################################################
    # We'll use grep to match the timestamp pattern, then 'date -d' with the
    # adjusted pattern to actually validate the timestamp itself.  Dunno if
    # there's a less round-about way to do this, but the 'net didn't seem to
    # have a matching solution.
    #
    # Really, the timestamp lines should be well formed, but I have to do this
    # strict matching so as to not confuse the timestamp line with a text line.
    #
    # First, we'll try the '00:00' pattern to see if there's a hit.
    #
  echo "${in_line}" | "${GREP}" ${GREP_OPTS} -q '^[0-9]\{1,2\}:[0-5][0-9]$' ; RC=$? ;
  if [ ${RC} -eq 0 ] ; then  # {

    ts_pad='00:' ; # It IS the '00:00' pattern, so add the hours prefix ...

  else  # }{

    echo "${in_line}" | "${GREP}" ${GREP_OPTS} -q '^[0-9]:[0-5][0-9]:[0-5][0-9]$' ; RC=$? ;
    [ ${RC} -ne 0 ] && { printf '' ; return ${RC} ; } ; # bail at this point

  fi  # }

  ts_seconds="$(${DATE} -d "${ts_pad}${in_line}" '+%s' 2>/dev/null)" ; RC=$? ;

  echo "${ts_seconds}" ;

  return ${RC} ;
}


###############################################################################
# build_sed_snippet(misspelt_word, transcript_language)
# RETURNS :: sed_snippet
#
# For misspelled words reported by aspell:
# 1. if the word is already capitalized, treat it as an already correct proper
#    noun that's NOT in aspell's dictionary.  In this case, we won't build a
#    sed snippet.  We probably won't see this case except through hand-editing
#    of the transcript file.
# 2. if the word ends in ‘'s’, then add it to script as a capitalized word.
#    aspell will detect “Stephen’s” but not “stephen’s”.  If capitalizing the
#    word fixes it in aspell, good (e.g. “stephen’s” ⇒ “Stephen’s”).
#    Otherwise we assume it's a proper noun that is NOT in aspell's dictionary
#    (foreign names) and the sed script will correct it; see above point.
#    . Note that because of how regex word boundaries work, we only have to
#      handle the base word of the possessive noun to correct both spellings.
#    . There's a minor flaw in this thinking in that there may be a correctly
#      spelt word that's not in aspell's dictionary, e.g. “aspell's”.
#      This would most likely happen in very technical or content with a lot
#      of foreign words.  We shouldn't see this at all since we'll only build
#      a snippet if the uppercase version passes the aspell test, but bugs ...
#      The user can use ‘--dry-run’ and edit the sed script in these cases.
# 3. Uppercase the word.  If it passes aspell, then build the snippet.
# 4. TODO :: Use the first aspell suggestion, if presented as a CLI option.
#    TODO :: re-write #2's description.  The only oddity that should happen is
#            that if a regular noun is NOT in the dictionary, the script will
#            think it's a possessive proper noun; a regular possessive noun
#            will not be made uppercase as aspell won't flag it as misspelt.
#    TODO :: build a list of uncorrectable words so that the user can easily
#            edit them if needed.  Dunno - can sed have comments in its script?
#
build_sed_snippet() {
  misspelt_word="$1" ; shift ;
  transcript_language="$1" ; shift ;

    # CASE #1
  if [[ "${misspelt_word}" =~ ^[[:upper:]] ]] ; then
    printf '' ;
    return ;
  fi

    # CASE #2
  regx="'s$" ;
  if [[ "${misspelt_word}" =~ $regx ]] ; then
    word_base="${misspelt_word%\'s}" ; # stephen's ==> stephen
    word_base_upper="${word_base^}" ; # stephen ==> Stephen
    printf 's/\<%s\>/%s/g' "${word_base}" "${word_base_upper}" ;
    return ;
  fi

    # CASE #3
  misspelt_word_upper="${misspelt_word^}" ;
  misspelt_word_correct="$(printf "${misspelt_word_upper}" | ${ASPELL})" ;
  if [ "${misspelt_word_correct}" = '' ] ; then
    printf 's/\<%s\>/%s/g' "${misspelt_word}" "${misspelt_word_upper}" ;
    return ;
  fi

  printf '' ;
}


###############################################################################
###############################################################################
# build_spell_correction_sed_script(
#   transcript_file_in,
#   transcript_language,
#   sed_dictionary_basename)
# RETURNS :: dictionary_sed_script
#
# So, the theory is that when a transcript is auto-generated, all of the words
# are correctly spelled, but without case distinction.  Some content creators
# don't edit beyond that since that's probably good enough for their purpose.
# Sentence __endings__ and punctuation doesn't exist in the few transcripts
# I've seen.
#
build_spell_correction_sed_script() {
  local transcript_file_in="$1" ; shift ;
  local transcript_language="$1" ; shift ;
  local sed_dictionary_basename="$1" ; shift ;

  local dictionary_sed_script="${sed_dictionary_basename}.${transcript_language}.sed"

    ###########################################################################
    # If the sed script "dictionary" is already there, don't touch it ...
    #
  if [ -s "${dictionary_sed_script}" ] ; then  # {
    if ! [ -r "${dictionary_sed_script}" ] ; then  # {
      printf "${ATTR_ERROR} Can't read '${ATTR_YELLOW}%s${ATTR_OFF}'\n" \
             "${dictionary_sed_script}" ;
      abort ${FUNCNAME[0]} ${LINENO};
    fi  # }
    printf '%s' "${dictionary_sed_script}" ;
    return 0 ;
  fi  # }

    ###########################################################################
    # 'touch' is good enough as we don't need an atomic operation for this ...
    #
  touch "${dictionary_sed_script}" ; RC=$? ;
  if ! [ ${RC} -eq 0 -a -w "${dictionary_sed_script}" ] ; then
    printf "${ATTR_ERROR} Can't create '${ATTR_YELLOW}%s${ATTR_OFF}'\n" \
           "${dictionary_sed_script}" ;
    abort ${FUNCNAME[0]} ${LINENO};
  fi

    ###########################################################################
    # Handle a few annoying English 'aspell' issues here:
    # - 'i' is not detected by aspell as a misspelt word, but i'd, i'm, i've,
    #   etc., are detected correctly.
    #   This one simple trick tackles all of those case because the ' (along
    #   with SPACE, the start / end of the line) are each counted as a word
    #   boundary character.  So, 'i' becomes 'I', 'i've' becomes 'I've', etc.
    #
    if [ "${transcript_language}" = 'English' ] ; then  # {
      printf '%s\n' 's/\<i\>/I/g' > "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<michaelena\>/Michaelena/g' >> "${dictionary_sed_script}" ;

      if [ ${G_OPTION_TRN_AMERICAN_ENGLISH} -eq 1 ] ; then  # {
        printf '%s\n' 's/\<dr\>/Dr./g' >> "${dictionary_sed_script}" ;
        printf '%s\n' 's/\<mr\>/Mr./g' >> "${dictionary_sed_script}" ;
        printf '%s\n' 's/\<mrs\>/Mrs./g' >> "${dictionary_sed_script}" ;
      fi  # }

        #######################################################################
        # There's no look-ahead across lines to catch compound proper nouns,
        # so this is a feeble attempt to try to get some common cases ...
        #
        # Anything beyond these U.S. states could be added to the general-
        # purpose sed script (cities, etc.)
        #
      printf '%s\n' 's/\<new hampshire\>/New Hampshire/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<new jersey\>/New Jersey/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<new mexico\>/New Mexico/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<new york\>/New York/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<north carolina\>/North Carolina/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<north dakota\>/North Dakota/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<rhode island\>/Rhode Island/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<south carolina\>/South Carolina/g' >> "${dictionary_sed_script}" ;
      printf '%s\n' 's/\<south dakota\>/South Dakota/g' >> "${dictionary_sed_script}" ;
    fi  # }

    ###########################################################################
    # I think I can do everything in a pipe ...
    # 1. find and build a sorted, unique list of all of the misspelt words
    #    using 'aspell'.
    # 2. if the language is English, then exclude the 'i' cases we've already
    #    handled above.
    # 3. We're operating under the premise that the words are correctly spelt
    #    but not uppercased correctly.  We'll uppercase the word and use aspell
    #    to check it again.  If it succeeds, then we'll __add__ it to the sed
    #    dictionary.  So 'david' will be 's/\<david\>/David/g'.
    #
    cat "${transcript_file_in}" \
      | ${ASPELL}    \
      | sort -u      \
      | if [ "${transcript_language}" = 'English' ] ; then grep -v "^i'" ; \
        else cat - ; \
        fi \
      | while read misspelt_word ; do  # {

        sed_snippet="$(build_sed_snippet "${misspelt_word}" "${transcript_language}")" ;
        if [ "${sed_snippet}" != '' ] ; then  # {
          printf '%s\n' "${sed_snippet}" >> "${dictionary_sed_script}" ;
        fi  # }
      done  # }

  { set +x ; } >/dev/null 2>&1
  printf '%s' "${dictionary_sed_script}" ;

  return 0 ;
}


###############################################################################
# TODO: add a global sed script feature for a "group" of videos in a series.
# This would probably be configured as a CLI option, or build the sed pathname
# from the basename of the directory where the video is, and look for it in
# the same location as the other sed scripts.
#
run_global_sed_script() {
  local sed_script="$1" ; shift ;

  if [ "${sed_script}" != '' ] ; then
    "${SED}" "--file=${sed_script}" ;
  else
    cat - ;
  fi
}


###############################################################################
#
run_spell_check_sed_script() {
  local sed_script="$1" ; shift ;

  if [ "${sed_script}" != '' ] ; then
    "${SED}" "--file=${sed_script}" ;
  else
    cat - ;
  fi
}


###############################################################################
#
run_user_sed_script() {
  local sed_script="$1" ; shift ;

  if [ "${sed_script}" != '' ] ; then
    "${SED}" "--file=${sed_script}" ;
  else
    cat - ;
  fi
}

###############################################################################
# write_a_subtitle_line "${subtitle_file_out}"   \
#                       transcript_sed_script    \
#                       dictionary_sed_script    \
#                       "${previous_line}"       \
#                       "${transcript_style}"    \
#                       "${previous_start_time}" \
#                       "${previous_end_time}"   \
#                       ${G_OPTION_TRN_WORD_TIME} \
#                       ${G_OPTION_TRN_WC_THRESHOLD} \
#                       ${G_OPTION_TRN_TEXT_OFFSET_MS} ;
# RETURNS:
#   0 - no timing adjustments were made;
#   1 - a timing adjustment was performed.
#
#  0:05                                    -- 8 words, IMPLIED is 8 seconds
#  hi everybody good morning how's it going today   -- just under 4 seconds
#  0:13
#  the local time is 8 48 and we will begin
#
#  46:48 -- IMPLIED duration is 7 seconds, but he speaks line in under 1500ms
#  i'll give you a second          -- 5 words @250ms (default value) = 1250ms
#  46:55
#  there it is
#
# TODO :: Add some logic for to prevent really long line 'End' durations, i.e.
#         an upper limit for how long the subtitle line is displayed (again
#         based on the number of words in the subtitle line).
#
#  18:54 <<=== speaker is done the line at 19:00ish, 19 words in 6 seconds,
#              the gap to the next line is 16 seconds; about 316ms / word.
#  now freighters coming up the inside passage from prince rupert in british \
#    columbia could be unloaded quickly and easily
#  19:10 <<=== speaker is done the line at 19:13ish, 9 words in 3 seconds,
#              the gap to the next line is 16 seconds; about 300ms / word.
#  barges could be beached and unloaded at low tide
#
write_a_subtitle_line() {
  subtitle_file_out="$1" ; shift ;
  transcript_sed_script="$1" ; shift ;
  dictionary_sed_script="$1" ; shift ;
  transcript_line="$1" ; shift ;          # The 'Text' of the 'Dialogue:' ...
  transcript_style="$1" ; shift ;
  transcript_start_time="$1" ; shift ;
  transcript_end_time="$1" ; shift ;
  transcript_word_time="$1" ; shift ;     # Not perfect, but s/b okay ...
  transcript_wc_threshold="$1" ; shift ;
  transcript_text_offset_ms="$1" ; shift ;

  local adjustment_made=0 ;

    ###########################################################################
    # See if there's a sed script and run FIRST it on the subtitle's 'Text'.
    # Note, we've already vetted the file to see if it's legitimate.
    #
    # Amazingly, this inefficient way of running sed doesn't cost too much
    # (of course, it depends on the complexity of the actual sed script)!
    #
  transcript_line="$(printf "%s" "${transcript_line}"                      \
                   | run_global_sed_script ''                              \
                   | run_user_sed_script "${transcript_sed_script}"        \
                   | run_spell_check_sed_script "${dictionary_sed_script}")" ;

  num_words="$(printf '%s' "${transcript_line}" | ${WC} -w)" ;

    ###########################################################################
    # If the line has a __few__ number of words, then re-calculate the 'End'.
    #
    # Also, (for my "test" video), the transcript lines seem to lag the audio
    # by a small amount.  My guess is that this is due to the 1 second
    # resolution of the timestamp and the algorithm not wanting to be "early".
    #
  if [ ${num_words} -lt ${transcript_wc_threshold} ] ; then  # {

    [ ${num_words} -eq 1 ] && (( num_words++ )) ;

    (( line_current_ms = (transcript_end_time - transcript_start_time) * 1000 )) ;
    (( line_estimated_ms = (num_words + 1) * transcript_word_time )) ;

    if [ ${line_estimated_ms} -lt ${line_current_ms} ] ; then  # {

        #######################################################################
        # Shell integer division always truncates and does not round up,
        # so 1999 ms / 1000 = 1, not 2.
        #
      (( end_time = (line_estimated_ms / 1000) + transcript_start_time )) ;

        #######################################################################
        # We cheat a bit in that we *know* the start time is *always* an even
        # number of seconds, so we save a little bit of math here (lazy) ...
        #
        # I'll probably do this *right* sometime and should do all of the
        # math calculations in milliseconds from the start...
        #
      end_time_decimal="$( ((uu = (line_estimated_ms % 1000) / 10 )) ; printf "%.2d" $uu)" ;
      adjustment_made=1 ;
    else  # }{
      end_time="${transcript_end_time}" ;
      end_time_decimal='00' ;
    fi  # }
  else  # }{
    end_time="${transcript_end_time}" ;
    end_time_decimal='00' ;
  fi  # }

  # Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
  # Dialogue: 0,0:00:36.54,0:00:40.92,Default,,0,0,0,,♪ Sleep alone tonight ♪

  printf "Dialogue: 0,%s.00,%s.%s,%s,,0,0,0,,%s\n"       \
         "$(${DATE} -d "@${transcript_start_time}" +%T)" \
         "$(${DATE} -d "@${end_time}" +%T)"              \
         "${end_time_decimal}"                           \
         "${transcript_style}"                           \
         "${transcript_line}" >> "${subtitle_file_out}" ;

  return ${adjustment_made} ;
}


###############################################################################
# add_transcript_text_to_subtitle()
#   transcript_file_in
#   transcript_language
#   transcript_style
#   subtitle_file_out
#   transcript_sed_script
#   dictionary_sed_script
#
# We'll use a *very* simple state machine to roll up the transcript into
# the subtitle file.  Because it's 99% script, this part is pretty expensive.
#
#   0:05
#   hi everybody good morning how's it going today
#   11:04
#   because i don't have to yell either right now
#   1:02:18
#   that's a t there's a lower plate
# TO:
#   Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
#   Dialogue: 0,0:00:36.54,0:00:40.92,Default,,0,0,0,,♪ Sleep alone tonight ♪
#
# TODO :: we don't check to ensure that the timestamps are always increasing ...
#
add_transcript_text_to_subtitle() {

  local read_option="$([ "${G_OPTION_DEBUG}" = 'y' ] && printf '%s' '-r')" ;

  local transcript_file_in="$1" ; shift ;
  local transcript_language="$1" ; shift ;
  local transcript_style="$1" ; shift ;
  local subtitle_file_out="$1" ; shift ;
  local transcript_sed_script="$1" ; shift ;
  local dictionary_sed_script="$1" ; shift ;

  local transcript_errors=0 ; # After X number of errors, we'll quit
  local transcript_lineno=0 ; # ...so the user can identify glitches
  local transcript_blank_lines=0 ; # TWO adjacent timestamps is an EMPTY line
  local transcript_adjustments=0 ; # ..statistics

  local current_line='' ;

  local previous_line='' ;
  local previous_start_time='' ;
  local previous_end_time='' ;

  local skipped_lines=0 ;
  local previous_timestamp_line='' ;
  local previous_transcript_lineno=0 ;

  local rc=0 ; # Always SUCCESS for now ...

  echo >&2 "  IN ${FUNCNAME[0]} ..." ;
  echo >&2 "  TR '${transcript_file_in}' ..." ;

  local my_state=0 ; # 0 = looking for timestamp
                     # 1 = looking for text line

    ###########################################################################
    # Walk through the transcript file:
    # - keep track of the line number in case there's an error with the line;
    # - sed to remove any "magic" lines (#S, #L, etc.);
    #   > a clever trick (discovered by accident) -->
    #     sed 's/^#[^#]*//' without the end anchor ('$') produces identical
    #     results to sed -e 's/^#[^#]*$//' -e 's/^##/#/'.
    #     My "clever" trick was borked, so I had to fix it!
    #     A line like -
    #         '#C --artist='History_S01E03' # knida like author, amiright?'
    #     only removed the 1st part leaving '# knida like author, amiright?'
    # - sed to trim the line of leading / trailing SPACEs; and
    # - skip any EMPTY lines (these are identified by adjacent timestamps).
    # - allow pass-thru comments beginning with '##', i.e. these will be
    #   treated as subtitle text (as long as they're preceded by a timestamp).
    #
    # A “feature” of read in which a backslash-newline pair, aka "line
    # continuation," that effectively joins the next line with the current
    # line, is supported.  This is really a side effect of how this script was
    # written and there is no special logic is here to support that feature.
    # So, a transcript like -->
    #   0:28
    #   when the japs bombed pearl harbor they upset our thinking \
    #   about a great many things including alaska
    # will be parsed and seen as -->
    #   0:28
    #   when the japs bombed pearl harbor they upset our thinking about a great many things including alaska
    # which is a single text line.
    #
    # The downside is that line counts will be skewed so identifying errors
    # by line number may be obfuscated.  Using '--debug' disables this in read,
    # which may help with transcript debugging.
    #
  local start_of_transcript_lineno=0 ;

  cat "${transcript_file_in}"                   \
    | "${SED}" -e 's/^#[A-Z][[:space:]].*$//'   \
               -e 's/^exit[[:space:]]*[0]*.*//' \
               -e 's/^[[:space:]]*//'           \
               -e 's/[[:space:]]*$//'           \
    | while read ${read_option} current_line ; do  # {

      (( transcript_lineno++ )) ;

      if [ "${G_OPTION_DEBUG}" = 'y' ] ; then  # {
        # TODO :: make this go to a specified DEBUG directory.
        printf '%s\n' "${current_line}" >> "${transcript_file_in%.txt}.raw" ;
      fi  # }

      if [ ${my_state} -eq 0 ] ; then  # { FIXME - this logic is NOT quite right ??
        if [ "${current_line}" = '' ] ; then  # {
          (( skipped_lines++ )) ;
          continue ;
        fi  # }
      else  # }{
        :
      fi  # }

       current_start_time="$(my_strptime ${my_state} "${current_line}")" ; RC=$? ;

       if [ ${RC} -eq 0 ] ; then  # { FOUND A TIMESTAMP LINE!
         if [ "${G_OPTION_DEBUG}" = 'y' \
            -a ${start_of_transcript_lineno} -eq 0 ] ; then  # {
           start_of_transcript_lineno=${transcript_lineno} ;
           printf '  NOTE :: transcript starts at line %d "%s" = "%s"\n' \
                  ${transcript_lineno} "${current_line}" "${current_start_time}" ;
         fi  # }

         if [ ${my_state} -ne 0 ] ; then  # { DEBUG: s/b '-ne 0'

             ##################################################################
             # Looks good - the line times for the line before the EMPTY line
             # are correct (i.e., doesn't exceed the EMPTY line's Start value).
             # TODO :: Ensure that this handles multiple EMPTY lines ...
             #
           echo >&2 -n "  ${ATTR_NOTE} Found a orphaned timestamp - assuming an EMPTY line #" ;
           echo >&2 -n "${previous_transcript_lineno}, " ;
           echo >&2    "'${ATTR_YELLOW}${previous_timestamp_line}$(tput sgr0)'" ;

           (( transcript_blank_lines++ )) ;
           previous_start_time="${current_start_time}" ;
           previous_transcript_lineno=${transcript_lineno} ;
           previous_timestamp_line="${current_line}" ;
           continue ;
         fi  # }

         previous_transcript_lineno=${transcript_lineno} ;
         previous_timestamp_line="${current_line}" ;

         if [ ${skipped_lines} -ne 0 ] ; then
           echo -n "  SKIPPED ${skipped_lines} EMPTY OR OTHER '#' LINE(s) "
           echo    "WHILE LOOKING FOR TIMESTAMP ${ATTR_GREEN}(THIS IS OKAY)${ATTR_OFF}" ;
           skipped_lines=0 ;
         fi

         local previous_end_time="${current_start_time}" ; # added for CLARITY
         if [ "${previous_line}" != '' ] ; then  # { should __only__ see this once!
           write_a_subtitle_line "${subtitle_file_out}"      \
                                 "${transcript_sed_script}"  \
                                 "${dictionary_sed_script}"  \
                                 "${previous_line}"          \
                                 "${transcript_style}"       \
                                 "${previous_start_time}"    \
                                 "${previous_end_time}"      \
                                 ${G_OPTION_TRN_WORD_TIME}   \
                                 ${G_OPTION_TRN_WC_THRESHOLD} \
                                 ${G_OPTION_TRN_TEXT_OFFSET_MS} ;
           (( transcript_adjustments += $? )) ;
         fi  # }

         previous_start_time="${current_start_time}" ;
         my_state=1 ;

       else  # }{

         previous_line="${current_line}" ;
         my_state=0 ;

       fi  # }

       # TODO :: bail after so many 'transcript_errors' errors ??
  done  # }

  (( previous_end_time += 7 )) ; # Yup, it's a hack — but a reasonable hack!
  write_a_subtitle_line "${subtitle_file_out}"      \
                        "${transcript_sed_script}"  \
                        "${dictionary_sed_script}"  \
                        "${previous_line}"          \
                        "${transcript_style}"       \
                        "${previous_start_time}"    \
                        "${previous_end_time}"      \
                        ${G_OPTION_TRN_WORD_TIME}   \
                        ${G_OPTION_TRN_WC_THRESHOLD} \
                        ${G_OPTION_TRN_TEXT_OFFSET_MS} ;
  (( transcript_adjustments += $? )) ;

  if [ ${skipped_lines} -ne 0 ] ; then
    echo -n "  SKIPPED ${skipped_lines} EMPTY OR OTHER '#' LINE(s) AT "
    echo    "THE END OF THE TRANSCRIPT ${ATTR_GREEN_BOLD}(THIS IS OKAY)${ATTR_OFF}" ;
  fi

  printf "  ${ATTR_YELLOW_BOLD}STATISTICS${ATTR_CLR_BOLD} for "
  printf "'${ATTR_YELLOW}%s${ATTR_CLR_BOLD}':\n" "${transcript_file_in}" ;
  echo "     total lines = ${transcript_lineno}," ;
  echo "  recalculations = ${transcript_adjustments} (Dialogue: 'End' time)," ;
  echo "     blank lines = ${transcript_blank_lines}," ;
  echo "          errors = ${transcript_errors}," ;
  echo "    process time was " ;

  return ${rc} ;
}


###############################################################################
# Add_transcript_style_to_subtitle  subtitle_file_out  transcript_file_in
#
# RETURNS: name of the __last__ style that was read from the transcript file,
#          0 if style's font was found with fonconfig, 1 otherwise.
#
# NOTE :: Right now, there's no way to change any details about an embedded
#         style from the CLI.
#
# Copy the embedded style from the transcript file to the subtitle file.
#
# An embedded style definition (for the purposes of this script) must appear
# in the transcript file as FIVE lines fully detailed with all of the necessary
# fields with valid values - there isn't any substitutions done by this script.
# For example, the 'Fontname'¹ must contain a valid font name for the OS that
# ffmpeg can find during the encoding.
#
# These lines are (only the first few tokens of each line are shown):
#    [V4+ Styles]
#    Format: Name, Fontname, Fontsize, ...
#    Style: Default,Open Sans Semibold,44,&H6000F8FF, ...
#
#    [Events]
#    Format: Layer, Start, End, Style, ...
#
# There isn't any syntax checking performed on these, just some very simple
# checks to catch potentially glaring errors.  If a duplicate style exists in
# a transcript, or even the generated ASS file, libass will use the last
# defined for __all__ of the 'Dialogue:' lines that reference that style.
#
# ¹ Yeah, I'd really like that, too.  The best that we can do is WARN the
#   user if we can't "see" the font using the standard fc-* fontconfig tools.
#
#   The font could exist privately in a location specified by ffmpeg's
#   'fontsdir=' switch on the encoding command line.  It's way too complex
#   for any automated benefit to manually look at all of the fonts in the
#   location specified by 'G_FONTS_DIR', or any unextracted font attachments
#   in the source video.
#
add_transcript_style_to_subtitle() {

  local subtitle_file_out="$1" ; shift ;
  local transcript_file_in="$1" ; shift ;
  local style_in='' ;

  local rc=0 ;

    ###########################################################################
    # TODO :: Should I look for other tags and warn that they're being IGNORED?

    ###########################################################################
    # Copy through the embedded style and check if fontconfig knows the font¹.
    #
    # Style: Default,Arial,16,...
    # printf '%s' 'Style: Default,Arial,16, ...
    #
  "${GREP}" ${GREP_OPTS} "^${C_TRN_TAG_ASS_SCRIPT}" "${transcript_file_in}" \
    | "${SED}" -e "s/^${C_TRN_TAG_ASS_SCRIPT}[ ]*//"           \
    | while read text_line ; do  # {

      printf "%s\n" "${text_line}"         \
        | ${TEE} -a "${subtitle_file_out}" \
        | "${GREP}" ${GREP_OPTS} -q '^Style: ' ; RC=$? ;

      if [ "${RC}" -eq 0 ] ; then  # {
        style_in="$(printf '%s' "${text_line}"       \
            | "${SED}" -e 's/,.*$//' -e 's/Style: //')" ;
        style_font="$(printf '%s' "${text_line}"     \
            | "${SED}" -e 's/^[^,]*,//' -e 's/,.*//')" ;

        printf >&2 "  ${ATTR_YELLOW_BOLD}FOUND -${ATTR_CLR_BOLD} embedded style " ;
        printf >&2 "'${ATTR_BLUE_BOLD}%s${ATTR_CLR_BOLD}' using font '%s'" \
                   "${style_in}" "${style_font}" ;
        actual_font="$(check_font_name '' '' "${style_font}" 1)" ; RC=$? ;

        if [ ${RC} -eq 0 ] ; then  # {
          printf >&2 ', fontconfig returned "%s"' "${ATTR_GREEN_BOLD}${actual_font}" ;
          rc=0 ;
        else  # }{
          printf >&2 ', %s fontconfig returned "%s"'               \
                     "${ATTR_RED}`tput blink`WARNING -`tput sgr0`" \
                     "${ATTR_YELLOW_BOLD}${actual_font}" ;
          rc=1 ;
        fi  # }
        printf >&2 "${ATTR_OFF}\n" ;
      fi  # }
    done  # }

  echo "${style_in}" ;
  return ${rc} ;
}


###############################################################################
# Convert_transcripts_to_ass "${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass" \
#                             G_TRN_SED_SCRIPT                            \
#                             C_SED_DICTIONARY_BASENAME                   \
#                             ${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}*.txt
#
# NOTE :: arg #3 is either a single transcript file or a list of transcripts.
#
# Convert any transcript(s) for the video to Substation Alpha subtitles.
#
# Transcripts take precedence over any other subtitle format for the video.
# I don't expect an already subtitled video to be accompanied by a transcript.
#
# This script supports two methods of adding transcript subtitles to a video:
# 1. Only 1 transcript file in one language.
#    This is meant to be the simplest method - simply name the basename of the
#    transcript file with the '.txt' extension.  No special editing of the
#    transcript file is necessary -- kinda ‘plug n play’.
#    Embedded 'Style:' lines are honoured, but are not required and the
#    built-in 'Style:' will be used.
# 2. Multiple transcript files.
#    These files are named as basename*.txt __only__ so that this script can
#    find the transcripts belonging to the video.
#    Otherwise, no special significance is applied to their names.
#   - Exactly one of the transcript files can be missing the Embedded 'Style:'
#     lines, a warning is issued otherwise.
#
# The format of the transcript __filename__ follows the same convention of
# any subtitle filename with the addition of the "base-style" identifier.
# This identifier indicates the base style to assign to the lines in the
# transcript file.  A transcript file can only support 1 base style.
#
# Example of a SINGLE transcript filename¹:
#   'Eocene X - Kamloops & Shuswap w∕Jerome Lesemann [Nick Zentner] [Feb 12, 2022].txt'
# Example of a MULTIPLE transcript filenames:
#   'Eocene X - Kamloops & Shuswap w∕Jerome Lesemann [Nick Zentner] [Feb 12, 2022]-English.txt'
#   'Eocene X - Kamloops & Shuswap w∕Jerome Lesemann [Nick Zentner] [Feb 12, 2022]-2.txt'
#
# The above is the English transcript for the (does not appear to be ©) video,
# and the 'Style:' that will be assigned is 'English', something like -->
#
#   Style: English,'"${G_OPTION_TRN_DEFAULT_FONT_NAME}"','"${G_OPTION_TRN_FONT_SIZE}"',&H6000F8FF,&H000000FF,&H00101010,&H50A0A0A0,-1,0,0,0,100,100,0,0,1,2.75,0,2,100,100,12,1
# ...
#   Dialogue: 0,0:02:31.34,0:02:32.36,English,,0,0,0,,Thank you.
#
# ¹This does not appear to be ©.
#
convert_transcripts_to_ass() {
  local subtitle_file_out="$1" ; shift ;
  local transcript_sed_script="$1" ; shift ;
  local sed_dictionary_basename="$1" ; shift ;
  local transcript_file_in='…' ; # /transcript_file_in

  local default_style='Transcript' ;

  RC=0 ;

    ###########################################################################
    ###########################################################################
    # If the subtitle file's already there and is not EMPTY, don't do anything.
    #
  [ -s "${subtitle_file_out}" ] && return ${RC} ;

  msg="$(touch "${subtitle_file_out}" 2>&1)" ; RC=$? ; # 'local msg' is borked?
  if [ ${RC} -ne 0 ] ; then  # {
    echo -n "${ATTR_ERROR} "
    echo    "$(echo "${msg}" \
           | "${SED}" -e "s/^\(.*\)'\([^']*\)'\(.*\)/\1'`tput bold; tput setaf 3`\2`tput sgr0`'\3/")" ;
    abort ${FUNCNAME[0]} ${LINENO};
  fi  # }

  #############################################################################
  # Build the "header" for the Substation Alpha subtitle ...
  # We include the possibly unused 'Style: Default,' as it's easy to do ☺.
  #
  cat << HERE_DOC > "${subtitle_file_out}" ;
[Script Info]
; Script generated by ${C_SCRIPT_NAME} on ${G_SCRIPT_RUN_DATE}
ScriptType: v4.00+
PlayResX: 1280
PlayResY: 720
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize,\
 PrimaryColour, OutlineColour,\
 SecondaryColour, BackColour,\
 Bold, Italic, Underline, StrikeOut,\
 ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow,\
 Alignment, MarginL, MarginR, MarginV, Encoding
\
Style: ${default_style},${G_OPTION_TRN_DEFAULT_FONT_NAME},${G_OPTION_TRN_FONT_SIZE},\
&H${G_OPTION_TRN_PRIMARYCOLOR},&H${G_OPTION_TRN_OUTLINECOLOR},\
&H00000000,&H00000000,\
-1,0,0,0,\
100,100,0,0,1,${G_OPTION_TRN_OUTLINE_WEIGHT},0,\
2,${G_OPTION_TRN_MARGIN},${G_OPTION_TRN_MARGIN},${G_OPTION_TRN_MARGINV},1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
HERE_DOC

  local number_of_embedded_styles=0 ;
  local number_of_transcript_files=$# ;

  while [ $# -gt 0 ] ; do  # {
          transcript_file_in="$1" ; shift ;
    local transcript_style="${default_style}" ;

    local transcript_language="$(${GREP} ${GREP_OPTS} "^${C_TRN_TAG_LANGUAGE}" \
                                         "${transcript_file_in}"  \
                               | "${TAIL}" -1 | "${CUT}" -d' ' -f2)" ;

    if [ "${transcript_language}" = '' \
        -a ${number_of_transcript_files} -eq 1 ] ; then  # {
      transcript_language="${G_OPTION_TRN_LANGUAGE}" ;
      # TODO :: message about selecting default language
    fi  # }
    local transcript_language_desc="$([ "${transcript_language}" = '' ] \
            && echo '' || echo "${transcript_language} language ")" ;

    # QQQQ :: FIXME :: TODO :: this is not being printed !!! ??? ADD to MESSAGES?
    printf "  ${ATTR_YELLOW_BOLD}PROCESSING - "
    printf "${ATTR_BLUE_BOLD}%s${ATTR_CLR_BOLD}" "${transcript_language_desc}" ;
    printf "${ATTR_CLR_BOLD}transcript file " ;
    printf "'${ATTR_YELLOW}%s${ATTR_CLR_BOLD}' ...\n" "${transcript_file_in}" ;
    tput sgr0 ;

      #########################################################################
      # See if there's one or more embedded styles in the script.
      #
      # We'll need to copy those 1st before we begin to add the Dialogue text
      # because of the way libass (apparently) works, a 'Style:' must be
      # defined before it is referenced by a 'Dialogue:' line (I have NOT
      # done a lot of experimenting on this, though).  This isn't a complex
      # requirement and just means making 2 read passes over the transcript.
      #
      # A script can have multiple styles, but __only__ the last style is used
      # for the script's dialogue.  This simple rule (hopefully) reduces the
      # coding complexity of this script.  The other styles could be used for
      # other things (TBD) and could be referenced by the script's dialogue
      # either through manual edits of the transcript or by the built-in sed
      # function (TODO).
      #
      # TODO We'll check the __FINAL__ generated subtitle file for duplicate styles, as
      # that is probably the most likely bug a user could introduce. TODO
      #
    msg="$(${GREP} ${GREP_OPTS} -c "^${C_TRN_TAG_ASS_SCRIPT}" "${transcript_file_in}" 2>&1)" ;
    RC=$? ;
    if   [ ${RC} -eq 0 ] ; then  # {
      if [ ${msg} -lt 5 ] ; then  # {
        echo 'WARNING -- too few Style: line were found ..?' ; # FIXME :: add to MESSAGES
      fi  # }
      (( number_of_embedded_styles++ ))
      local style_in="$(add_transcript_style_to_subtitle \
                         "${subtitle_file_out}"          \
                         "${transcript_file_in}")" ; RC=$? ;
      if [ ${RC} -ne 0 ] || [ "${style_in}" = '' ] ; then  # {
        echo -n "  ${ATTR_NOTE} No 'Style:' was found in "
        echo    "'${ATTR_YELLOW}${transcript_file_in}${ATTR_OFF}', using '${default_style}'" ;
        style_in="${default_style}" ;
      else  # }{
        echo -n "  ${ATTR_GREEN_BOLD}FIXME this is default transcript style ${ATTR_OFF}"
        echo -n "'${ATTR_BLUE_BOLD}Style: ${style_in},…,…${ATTR_OFF}'"
         echo    " found in '${ATTR_YELLOW}${transcript_file_in}${ATTR_OFF}' ..." ;
      fi  # }
      transcript_style="${style_in}" ;
    elif [ ${RC} -eq 1 ] ; then  # }{
      # TODO :: should we allow multiple transcripts w/o any embedded styles?
      #       i.e., just assign a default "new" style to each transcript file?
      echo "  ${ATTR_TODO} no Style:, just add a message about using the default style" ;
    else  # }{
      echo "${ATTR_ERROR} ${msg}" ; # Just dump out the error from 'grep' ...
      abort ${FUNCNAME[0]} ${LINENO};
    fi  # }

      #########################################################################
      # Build the spell-correction sed script here.  We __only__ do this once
      # for the 'G_OPTION_TRN_LANGUAGE' option (default is 'English').
      #
    local dictionary_sed_script='' ; # Spell correction is disabled if NOT set.
    if [ ${G_HAVE_TOOL_ASPELL} -eq 1 \
        -a "${G_OPTION_TRN_LANGUAGE}" = "${transcript_language}" ] ; then  # {
      dictionary_sed_script="$(build_spell_correction_sed_script \
                            "${transcript_file_in}"      \
                            "${transcript_language}"     \
                            "${sed_dictionary_basename}" \
                            )" ;
    fi  # }
    { set +x ; } >/dev/null 2>&1

      #########################################################################
      # Print out the processing time for __this__ transcript file
      #
    time { function_stats="$(add_transcript_text_to_subtitle \
                            "${transcript_file_in}"    \
                            "${transcript_language}"   \
                            "${transcript_style}"      \
                            "${subtitle_file_out}"     \
                            "${transcript_sed_script}" \
                            "${dictionary_sed_script}" \
                            )"; RC=$? ; # Always SUCCESS
      printf '%s' "${function_stats}" ;
      TIMEFORMAT="${ATTR_BLUE_BOLD}%3lR" ; # bash(1) manual page
    }
    tput sgr0 ;

  done  # }

  # TODO :: check for duplicate 'Style:'s in the generated subtitle file

  { set +x ; } >/dev/null 2>&1
  return $RC;
}


###############################################################################
#        #####
#       #     #   #####    ##    #####    #####
#       #           #     #  #   #    #     #
#        #####      #    #    #  #    #     #
#             #     #    ######  #####      #
#       #     #     #    #    #  #   #      #
#        #####      #    #    #  #    #     #
###############################################################################
# main();
#
  #############################################################################
  #############################################################################
  # Initialize variable and process any command line arguments ...
  #
initialize_variables ;

check_getopt 0 "$@" ; rc=$? ;
do_probe=${rc} ;

  #############################################################################
  # Look for an embedded CLI file based on the working directory to process ...
  #
in_video_dir="$(dirname "${G_IN_VIDEO_FILE}")" ;
in_video_pwd="$(cd -- "${in_video_dir}/" && /bin/pwd -L)" ;
cli_file="$(basename "${in_video_pwd}")${C_EMBEDDED_SUFFIX}" ;

if [ -s "${cli_file}" -a -r "${cli_file}" ] ; then  # {
  if [ ${G_ALLOW_EMBEDDED_OPTIONS} -eq 1 ] ; then  # {
    check_embedded_options "${cli_file}" 0 ;
  else  # }{
    : ; # FIXME :: indicate that we're ignoring the embedded CLI file  QQQQ
  fi  # }
fi  # }

  #############################################################################
  # At this point, set which ffmpeg we're going to use ...
  #

(( do_probe )) && probe_video "${G_IN_VIDEO_FILE}" ;
(( do_probe -= 2 )) || { echo -ne "${G_OPTION_GLOBAL_MESSAGES}" ; exit 0 ; }

G_IN_EXTENSION="${G_IN_VIDEO_FILE##*.}" ;
G_IN_BASENAME="$(basename "${G_IN_VIDEO_FILE}" ".${G_IN_EXTENSION}")" ;

printf "${ATTR_BLUE_BOLD}<< '" ;
printf "${ATTR_GREEN_BOLD}%s" "${G_IN_VIDEO_FILE}"
printf "${ATTR_BLUE_BOLD}' >>${ATTR_OFF} ...\n" ;

echo -ne "${G_OPTION_MESSAGES}" ; # <sic>, couldn't printf this 'cause of '\n's
echo -ne "${G_OPTION_GLOBAL_MESSAGES}" ;

C_SED_SCRIPTS_DIR="${C_SUBTITLE_IN_DIR}" ; # ... for now use the same location

check_and_build_directory '' "${C_SUBTITLE_IN_DIR}" ;
check_and_build_directory '' "${C_SUBTITLE_OUT_DIR}" ;
check_and_build_directory '' "${G_VIDEO_OUT_DIR}" ;

check_and_build_directory '' "${G_FONTS_DIR}" ;

  #############################################################################
  # A little hack to speed up testing / development and save temporary files.
  #
if [ "${G_OPTION_DEBUG}" = '' ] ; then
  C_FFMPEG_PRESET="${C_FFMPEG_PRESET_NOR}" ;
  C_FFMPEG_CRF="${C_FFMPEG_CRF_NOR}" ;
else
  C_FFMPEG_PRESET="${C_FFMPEG_PRESET_DBG}" ;
  C_FFMPEG_CRF="${C_FFMPEG_CRF_DBG}" ;

  check_installed_tools ; # Ensure we have all of the needed tools installed
fi


###############################################################################
###############################################################################
#   #####
#  #     #  #    #  ####   #####  #  #####  #      #####   ####
#  #        #    #  #   #    #    #    #    #      #      #
#   #####   #    #  ####     #    #    #    #      ####    ####
#        #  #    #  #   #    #    #    #    #      #           #
#  #     #  #    #  #   #    #    #    #    #      #      #    #   ##  ##  ##
#   #####    ####   ####     #    #    #    #####  #####   ####    ##  ##  ##
#
# Here are the subtitle rules:
# - if '--no-subs' option is specified, any/all transcripts/subtitles will be
#   skipped and will not be hard-sub'd in the video during the re-encoding;
# - next, MANUALLY added subtitles are checked (this allows for an overriding
#   of a subtitle that may be attached with the video):
#   . if there is a subtitle in 'C_SUBTITLE_IN_DIR' and it is NEWER than the
#     subtitle in 'C_SUBTITLE_OUT_DIR', then that subtitle is processed and
#     used in the re-encoding of the video.
#     > An SRT subtitle will take priority over an ASS subtitle in
#       'C_SUBTITLE_IN_DIR'.  This is because an SRT subtitle is converted to
#       an ASS subtitle in 'C_SUBTITLE_IN_DIR', then processed and saved into
#       'C_SUBTITLE_OUT_DIR' which is then used during the re-encoding process;
#   . NOTE -- for manually added subtitles it's important to ensure that all
#     of the fonts that are used in the subtitle are visible to ffmpeg.
#     This also applies to videos with embedded subtitles although it's less
#     likely that they were packaged with missing fonts.
# - and finally, if the video contains a subtitle, then that subtitle is
#   processed and used in the re-encoding of the video.
#
# None of the above will explicitly trigger a re-encoding of the video, only
# a missing or out-of-date video will trigger the re-encoding process.  These
# steps only determine if subtitles should be reprocessed for the re-encoding.
#
# ⚙️ IN OTHER WORDS, simply adding/replacing a subtitle file will not trigger
#   a re-encoding of the video by this script.
###############################################################################
#
if [ "${G_OPTION_NO_SUBS}" != 'y' ] ; then  # {

  G_OPTION_MESSAGES='' ;

  if [ "$(/bin/ls "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}"*.txt 2>/dev/null \
        | /bin/wc -l )" != '0' ] ; then  # {

      #########################################################################
      # A good UX design should be noisy about the right things ...
      #
    G_TRN_SED_SCRIPT="${C_SED_SCRIPTS_DIR}/${G_IN_BASENAME}.sed" ;
    if [ -s "${G_TRN_SED_SCRIPT}" -a -r "${G_TRN_SED_SCRIPT}" ] ; then  # {
      if [ "${G_OPTION_TRN_SED_SCRIPT_DISABLE}" -ne 0 ] ; then  # {
        printf "  ${ATTR_BROWN_BOLD}DISABLED -${ATTR_CLR_BOLD} transcript sed script "
        printf "'${ATTR_YELLOW}%s${ATTR_CLR_BOLD}'\n" "${G_TRN_SED_SCRIPT}" ;
        G_TRN_SED_SCRIPT='' ;
      else  # }{
        printf "  ${ATTR_ORANGE_BOLD}FOUND -${ATTR_CLR_BOLD} transcript sed script " ;
        printf "'${ATTR_YELLOW}%s${ATTR_CLR_BOLD}' ...\n" "${G_TRN_SED_SCRIPT}" ;
      fi  # }
    else  # }{
      G_TRN_SED_SCRIPT='' ;
    fi  # }

    { set +x ; } >/dev/null 2>&1 ;
    tput sgr0 ;

    check_transcript_embedded_options "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}"*.txt ;

    C_SED_DICTIONARY_BASENAME="${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}" ;
    convert_transcripts_to_ass "${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass" \
                               "${G_TRN_SED_SCRIPT}"                        \
                               "${C_SED_DICTIONARY_BASENAME}"               \
                               "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}"*.txt ;

    G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass"

  elif [ -s "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" ] ; then  # }{

    ###########################################################################
    # See if this subtitle is NEWER than our previous version.  If the right
    # side of the '-nt' EXPRESSION is NOT there, then the test succeeds (i.e.,
    # the file is __newer__ than the non-existent file).  This seems logical
    # and __maybe__ implied by the man page, but there is NO explicit example
    # of this in the man page (“An omitted EXPRESSION defaults to false”).
    # Is a non-existent file considered an omitted EXPRESSION?
    #
    # Also, an expression using '-nt' is NOT reliable across different file-
    # system types because of the non-uniform increased timestamp resolution
    # between the filesystems (e.g., ext3 vs. ntfs or fat32).  This used to
    # work; dunno if it has been fixed in the interim and google returns way
    # too many results for any search terms I can think of to see if it's even
    # been identified as a bug/feature.
    #
    if [ "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
     -nt "${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass" ] ; then  # { OKAY

      [ "${G_OPTION_VERBOSE}" = 'y' ] && \
        echo "${ATTR_YELLOW_BOLD}FOUND AN SRT SUBTITLE$(tput sgr0).." ;
      set -x ; # We want to KEEP this enabled.
      "${G_FFMPEG_BIN}" ${G_FFMPEG_OPT} -i "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
                           "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
          >/dev/null 2>&1 ;
      { RC=$? ; set +x ; } >/dev/null 2>&1
      if [ ${RC} -ne 0 ] ; then
        echo -n "${ATTR_ERROR} '${G_FFMPEG_BIN}' -i " ;
        echo -n "'${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt' " ;
        echo    "'${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass'" ;
        exit 1 ;
      fi

      G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass"
      apply_script_to_srt_subtitles \
          "${G_OPTION_NO_MODIFY_SRT}" \
          "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
          "${G_SUBTITLE_PATHNAME}" ;

    else  # }{

      printf '  %s%s\n' \
             "${ATTR_YELLOW_BOLD}SUBRIP SUBTITLE ALREADY PROCESSED " \
             "TO SUBSTATION ALPHA ..." ;
      tput sgr0 ;

      G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass"
    fi  # }
  elif [ -s "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" ] ; then  # }{
    # TODO FIXME  Right now, this case doesn't exist because we extract the
    #      video's subtitle directly to 'C_SUBTITLE_OUT_DIR' without any
    #      automated sed script editing.
    # TODO make an 'apply_script_to_ass_subtitles()' and a corresponding
    #      G_OPTION_NO_MODIFY_ASS switch.  It will be similar to the SRT
    #      script, except w/o the italics (maybe just 'Default' style only?).
    #
    # echo "FOUND AN ASS SUBTITLE, SEE IF IT's NEWER" ; # TODO HERE HERE
    echo -n "  ${ATTR_BLUE_BOLD}FOUND EXISTING ASS SUBTITLE$(tput sgr0), " ;

    G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass" ;

    if [ "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
     -nt "${G_SUBTITLE_PATHNAME}" ] ; then  # {

      echo "${ATTR_GREEN}UPDATING ..." ;
      apply_script_to_ass_subtitles \
          "${G_OPTION_NO_MODIFY_ASS}" \
          "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
          "${G_SUBTITLE_PATHNAME}" \
          "${G_OPTION_ASS_SCRIPT}" ;
    else  # }{
      echo "${ATTR_GREEN}ALREADY UP-TO-DATE ..." ;
    fi  # }
    tput sgr0 ;

    #############################################################################
    # Check to see if there are subtitles attached to this video.
    # FIXME :: Right now, we only handle ASS subtitles and assume the first one
    #          is the subtitle to use.  Good video packagers will have it set up
    #          this way, but there are the odd videos (usually older encodes)
    #          where the first subtitle is not the preferred subtitle to use for
    #          the video's re-encoding.
    # 2 'subtitles' 'S_TEXT/UTF8' null 'eng'
    #
    # We use ‘mkvmerge’ and ‘jq’ to parse out the video's track IDs.  The status
    # of the ‘grep’ at the end of the pipeline will tell if there is a subtitle.
    # TODO :: Add a switch to specify the regex to use get the desired track ID.
    #         This would replace the default regex “'subtitles' 'S_TEXT/ASS'”.
    #
    # There are probably better ways to do this, but this works pretty well.
    # ls ; read MKV_FILE ; mkvmerge -i -F json "${MKV_FILE}" | jq '.tracks[]' | jq -r '[.id, .type, .properties.codec_id, .properties.track_name, .properties.language]|@sh' | grep "'subtitles' 'S_TEXT/ASS'"

    #   4 'subtitles' 'S_TEXT/ASS' 'Without Effect' 'eng'
    #   2 'subtitles' 'S_TEXT/UTF8' null 'eng'

    #   2 'subtitles' 'S_TEXT/ASS' 'English subs' 'eng'

    # so let's see if there are any font
    # attachment(s) in the video.  If there are, then extract those fonts to
    # the fonts' directory (in 'G_FONTS_DIR') to provide visibility to ffmpeg.
    #

  else  # }{

      #########################################################################
      # No subtitle files found, so see if they exist in the video.
      #
      # TODO :: the subtitles __could__ exist in a completely different video.
      #
    select_subtitle_track_number "${G_IN_VIDEO_FILE}"             \
                                  ${G_OPTION_SUBTITLE_TRACK_TYPE} \
                                 "${G_OPTION_SUBTITLE_TRACK}" ; rc=$? ;

    if [ ${rc} -eq 255 ] ; then rc=-1 ; fi ;
    G_OPTION_SUBTITLE_TRACK_NUM=${rc} ;

    if [ ${G_OPTION_SUBTITLE_TRACK_NUM} -ne -1 ] ; then  # {
      SUBTITLE_TRACK_CODEC="$(${MKVMERGE} -i -F json "${G_IN_VIDEO_FILE}" \
          | jq -r ".tracks[${G_OPTION_SUBTITLE_TRACK_NUM}].properties.codec_id")" ;
      RC=$? ;
    else  # }{
      RC=3 ; # ???
    fi  # }

    if [ ${RC} -eq 0 ] ; then  # { If we got a track, determine its TYPE.

      if ( echo "${SUBTITLE_TRACK_CODEC}" | "${GREP}" ${GREP_OPTS} -q 'S_TEXT/ASS' ) ; then  # {
        echo "${ATTR_YELLOW_BOLD}  SUBSTATION ALPHA SUBTITLE FOUND IN VIDEO$(tput sgr0) ..." ;

        extract_subtitle_track "${G_IN_VIDEO_FILE}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            ${G_OPTION_SUBTITLE_TRACK_NUM} ;

        G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass" ;
        apply_script_to_ass_subtitles \
            "${G_OPTION_NO_MODIFY_ASS}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            "${G_SUBTITLE_PATHNAME}" \
            "${G_OPTION_ASS_SCRIPT}" ;

        extract_font_attachments \
            "${G_IN_VIDEO_FILE}" \
            "${G_FONTS_DIR}" \
            0 ;

      elif ( echo "${SUBTITLE_TRACK_CODEC}" | "${GREP}" ${GREP_OPTS} -q 'S_TEXT/UTF8' ) ; then  # }{
        echo "${ATTR_CYAN_BOLD}  SUBRIP SUBTITLE FOUND IN VIDEO$(tput sgr0) ..." ;

        extract_subtitle_track "${G_IN_VIDEO_FILE}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
            ${G_OPTION_SUBTITLE_TRACK_NUM} ;

        "${G_FFMPEG_BIN}" ${G_FFMPEG_OPT} -i "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
                           "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            >/dev/null 2>&1 ; RC=$? ;
        { set +x ; } >/dev/null 2>&1
        if [ ${RC} -ne 0 ] ; then
          echo -n "${ATTR_ERROR} '${G_FFMPEG_BIN}' -i " ;
          echo -n "'${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt' " ;
          echo    "'${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass'" ;
          exit 1 ;
        fi

        G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass"
        apply_script_to_srt_subtitles \
            "${G_OPTION_NO_MODIFY_SRT}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            "${G_SUBTITLE_PATHNAME}" ;

        extract_font_attachments \
            "${G_IN_VIDEO_FILE}" \
            "${G_FONTS_DIR}" \
            1 ;

      else  # }{  # FIXME :: print the whole track description
        #######################################################################
        # We'll get __here__ if the subtitle is a PGS subtitle.
        #
        # We may add support for these in the furture, which is why we allow
        # “select_subtitle_track_number()” to return their track number.
        #
        G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
        printf "  ${ATTR_YELLOW_BOLD}$(tput blink)NOTICE${ATTR_OFF} $(tput bold)-- " ;
        printf "skipping unknown/unsupported "
        printf "“$(tput setaf 5)%s$(tput sgr0; tput bold)” subtitle type -- $(tput sgr0)\\\n" \
               "${SUBTITLE_TRACK_CODEC}")" ;
      fi  # }
    else  # }{
        #######################################################################
        # There was no subtitle track in the video.
        # This message is a duplicate - should I keep both?
        #
      if [ ${G_OPTION_SUBTITLE_TRACK_SET} -ne 0 ] ; then  # {
        G_OPTION_MESSAGES="${G_OPTION_MESSAGES}$(\
          printf "  ${ATTR_NOT_FOUND} ${ATTR_CLR_BOLD}specified subtitle track " ;
          printf "“${ATTR_YELLOW}%s${ATTR_CLR_BOLD}” ...\\\n" \
                 "${G_OPTION_SUBTITLE_TRACK}")" ;
      fi  # }
    fi  # }
  fi  # }

  if [ "${G_OPTION_MESSAGES}" != '' ] ; then  # {
    echo -ne "${G_OPTION_MESSAGES}" ; # <sic>, couldn't printf this 'cause of '\n's
  fi  # }

else  # }{
  echo '  SUBTITLES WERE FORCED SKIPPED' ;
fi  # }


###############################################################################
###############################################################################
#
FFMPEG_METADATA='' ;
if [ "${G_OPTION_NO_METADATA}" = '' ] ; then  # {

  G_METADATA_TITLE="$(get_video_title "${G_IN_VIDEO_FILE}" "${G_OPTION_TITLE}" "${G_IN_BASENAME}")" ;
  if [ "${G_METADATA_TITLE}" != '' ] ; then  # {
    ## TODO :: split the artist / title here?
    FFMPEG_METADATA=" '-metadata' 'title=${G_METADATA_TITLE}'" ;
  fi  # }

  G_METADATA_ARTIST="$(get_video_artist "${G_IN_VIDEO_FILE}" "${G_OPTION_ARTIST}" '')" ;
  if [ "${G_METADATA_ARTIST}" != '' ] ; then  # {
    ## TODO :: split the artist / title here?
    FFMPEG_METADATA="${FFMPEG_METADATA} '-metadata' 'artist=${G_METADATA_ARTIST}'" ;
  fi  # }

  G_METADATA_GENRE="$(get_video_genre "${G_IN_VIDEO_FILE}" "${G_OPTION_GENRE}" "${C_DEFAULT_GENRE}")" ;
  if [ "${G_METADATA_GENRE}" != '' ] ; then  # {
    FFMPEG_METADATA="${FFMPEG_METADATA} '-metadata' 'genre=${G_METADATA_GENRE}'" ;
  fi  # }

    ###########################################################################
    # WWWW will this work ...? copyright album_artist
##--  FFMPEG_METADATA="${FFMPEG_METADATA} '-metadata' 'show=show U-tube channel' '-metadata' 'network=network U-tube channel' '-metadata' 'producer=producer U-tube channel' '-metadata' 'publisher=publisher U-tube channel' '-metadata' 'author=author U-tube channel' '-metadata' 'album=album U-tube channel' '-metadata' 'artist=artist U-tube channel' '-metadata' 'copyright=copyright 2022' '-metadata' 'album_artist=Album artist' '-metadata' 'year=year 1956'" ;

  { set +x ; } >/dev/null 2>&1
fi  # }


###############################################################################
# これは複雑な混乱ですが、うまくいきます！
#
# Welcome to the wonderful world of shell escapes and building CLI strings!
# I wish ffmpeg could append '-vf' filter arguments together -- maybe there's
# a sound reason for why it doesn't, but it makes building '-vf' dynamically
# quite the tickler.
#
# This is/was way more complicated than it should be!
#
# https://trac.ffmpeg.org/ticket/5896
#  https://ffmpeg.org/ffmpeg-utils.html#Quoting-and-escaping
# https://ffmpeg.org/pipermail/ffmpeg-user/2017-September/037118.html  SOLVED?
#
# Also, the number of escapes exceeded the maximum number allowed by code 🤯!
#
# Pretty sure no personal info will be added to the video's comments, and
# you can easily verify that the comment is what you expected using:
#  - vlc media player => Tools => Media Information or
#  - exiftool (which is cross-platform, but requires perl to be installed).
#
# There might be a cleaner/cleverer way to do this, but darn if I know how to!
#
# NOTE :: All/any of the metadata ffmpeg options are appended to the end.
#         We make special use of that to strip them from the comment metadata
#         since we want to use that mainly for the ffmpeg re-encoding options
#         and NOT data that is easily viewable with other tools.
#
if [ "${G_PRE_VIDEO_FILTER}" != '' ] ; then  # {
  if [ "${C_VIDEO_PAD_FILTER_FIX}" = '' ] ; then  # {
     C_VIDEO_PAD_FILTER_FIX="${G_PRE_VIDEO_FILTER}" ;
  else  # }{
     C_VIDEO_PAD_FILTER_FIX="${G_PRE_VIDEO_FILTER},${C_VIDEO_PAD_FILTER_FIX}" ;
  fi  # }
fi  # }

if [ "${G_SUBTITLE_PATHNAME}" = '' ] ; then  # {

  if [ "${C_VIDEO_PAD_FILTER_FIX}" = '' ] ; then  # {
    eval set -- ; # Build an EMPTY eval just to keep the code simple ...
  else  # }{
    C_FFMPEG_VIDEO_FILTERS="`echo "${C_VIDEO_PAD_FILTER_FIX}" \
                | "${SED}" -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
                  # NOTE absence of ',' after the ':'
    eval set -- "${C_FFMPEG_VIDEO_FILTERS}" ;
  fi  # }

else  # }{

    ###########################################################################
    # This works.  Is there a better, more concise way?  Dunno ...
    #
    # There are THREE distinct character types that have to be escaped with a
    # varying number of '\'s.  I'm actually amazed this all appears to produce
    # the desired results in ffmpeg, its metadata comments, and libass!
    #
    # TODO :: I don't know if there are more cases that need special handling.
    #
  G_FFMPEG_SUBTITLE_FILENAME="`echo "${G_SUBTITLE_PATHNAME}" \
                | "${SED}" -e 's#\([ |()]\)#\\\\\\\\\\\\\1#g' \
                           -e 's#\([][]\)#\\\\\\\\\\\\\\\\\1#g' \
                           -e 's#\([:,\x27]\)#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\1#g'`" ;
  G_FFMPEG_FONTS_DIR="`echo "${G_FONTS_DIR}" \
                | "${SED}" -e 's#\([ |()]\)#\\\\\\\\\\\\\1#g' \
                           -e 's#\([][]\)#\\\\\\\\\\\\\\\\\1#g' \
                           -e 's#\([:,\x27]\)#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\1#g'`" ;

  if [ "${C_VIDEO_PAD_FILTER_FIX}" = '' ] ; then  # {
    eval set -- "subtitles=${G_FFMPEG_SUBTITLE_FILENAME}:fontsdir=${G_FFMPEG_FONTS_DIR}" ;
  else  # }{
    C_FFMPEG_VIDEO_FILTERS="`echo "${C_VIDEO_PAD_FILTER_FIX}" \
                | "${SED}" -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
                  # NOTE absence of ',' after the ':'
    eval set -- "${C_FFMPEG_VIDEO_FILTERS},subtitles=${G_FFMPEG_SUBTITLE_FILENAME}:fontsdir=${G_FFMPEG_FONTS_DIR}" ;
  fi  # }

fi  # }

# TODO :: description
if [ "${G_POST_VIDEO_FILTER}" != '' ] ; then  # {
  if [ $# -eq 0 ] ; then
    FFMPEG_FILTER_COMMA='' ;
  else
    FFMPEG_FILTER_COMMA=',' ;
  fi
fi  # }

eval set -- "-vf $@${FFMPEG_FILTER_COMMA}${G_POST_VIDEO_FILTER}${FFMPEG_METADATA}" ;

# TODO :: description
G_FFMPEG_AUDIO_CHANNELS='' ;
if [ "${G_OPTION_MONO}" -eq 1 ] ; then
  G_FFMPEG_AUDIO_CHANNELS='-ac 1' ;
fi

###############################################################################
# This is where the hammer meets the road!
#
if [ ! -s "${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" \
       -a "${G_OPTION_DRY_RUN}" = '' ] ; then  # {

    ###########################################################################
    # Check to ensure we have all of the necessary tools installed ...
    #
  check_installed_tools ;

  RC=0 ;
  if   [ "${G_OPTION_NO_COMMENT}" = 'y' ] \
    || [ "${G_OPTION_NO_METADATA}" = 'y' ] ; then  # {

    set -x ; # We want to KEEP this enabled.
    "${G_FFMPEG_BIN}" ${G_FFMPEG_OPT} -i "${G_IN_VIDEO_FILE}" \
              -c:a libmp3lame -ab ${C_FFMPEG_MP3_BITS}K ${G_FFMPEG_AUDIO_CHANNELS} \
              -c:v libx264 -preset ${C_FFMPEG_PRESET} \
              -crf ${C_FFMPEG_CRF} \
              -tune ${G_OPTION_FFMPEG_TUNE} -profile:v high -level 4.1 -pix_fmt ${C_FFMPEG_PIXEL_FORMAT} \
              "$@" \
              "file:${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" ;
    { RC=$? ; set +x ; } >/dev/null 2>&1

  else  # }{

      #########################################################################
      # If the comment isn't set, then build a default comment.
      # NOTE -- this has to be done here because we need to evaluate "$@"
      #         to get the remaining ffmpeg options ...
      #
    G_ARCH="$(uname -sr)" ;
    G_BUILD_ARCH="${G_ARCH} ➕ $("${G_FFMPEG_BIN}" ${G_FFMPEG_OPT} -version \
          | "${GREP}" ${GREP_OPTS} '^ffmpeg '   \
          | "${SED}" -e 's/version //' -e 's/ Copyright.*//' ; \
          add_other_commandline_options ;)" ;

    G_VIDEO_COMMENT='' ;
    if [ "${C_METADATA_COMMENT}" = '' ] ; then  # {
      G_VIDEO_COMMENT="`cat <<HERE_DOC
Encoded on ${G_SCRIPT_RUN_DATE}
${G_BUILD_ARCH}
ffmpeg -c:a libmp3lame -ab ${C_FFMPEG_MP3_BITS}K ${G_FFMPEG_AUDIO_CHANNELS} -c:v libx264 -preset ${C_FFMPEG_PRESET} -crf ${C_FFMPEG_CRF} -tune ${G_OPTION_FFMPEG_TUNE} -profile:v high -level 4.1 -pix_fmt ${C_FFMPEG_PIXEL_FORMAT} $(echo $@ | "${SED}" -e 's/[\\]//g' -e "s#${HOME}#\\\${HOME}#g" -e 's/ -metadata .*//')
HERE_DOC
`" ;
    else  # }{
      echo 'FIXME' ;
    fi  # }

    set -x ; # We want to KEEP this enabled.
    "${G_FFMPEG_BIN}" ${G_FFMPEG_OPT} -i "${G_IN_VIDEO_FILE}" \
              -c:a libmp3lame -ab ${C_FFMPEG_MP3_BITS}K ${G_FFMPEG_AUDIO_CHANNELS} \
              -c:v libx264 -preset ${C_FFMPEG_PRESET} \
              -crf ${C_FFMPEG_CRF} \
              -tune ${G_OPTION_FFMPEG_TUNE} -profile:v high -level 4.1 -pix_fmt ${C_FFMPEG_PIXEL_FORMAT} \
              "$@" \
              -metadata "comment=${G_VIDEO_COMMENT}" \
              "file:${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" ;
    { RC=$? ; set +x ; } >/dev/null 2>&1

  fi  # }

  run_desc="  ${ATTR_GREEN_BOLD}FFMPEG ENCODING COMPLETE" ;
  printf "${run_desc}${ATTR_CLR_BOLD} '%s' ...\n" "${G_IN_VIDEO_FILE}" ;

else  # }{

  run_desc="  $([ "${G_OPTION_DRY_RUN}" = '' ] \
            && echo "${ATTR_YELLOW_BOLD}"       \
            || echo "${ATTR_MAGENTA_BOLD}DRY RUN ")COMPLETE" ;
  printf "${run_desc}${ATTR_CLR_BOLD} '%s' ...\n" "${G_IN_VIDEO_FILE}" ;
  RC=0 ;
fi  # }

exit ${RC} ;

