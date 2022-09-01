#! /bin/bash

shopt -s lastpipe ; # Needed for 'while read XXX ; do' loops

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
          echo -n ". $(tput bold; tput setaf 5)UPDATE" ;
        else
          echo -n ".. $(tput bold; tput setaf 2)DONE" ;
        fi
      else
        echo -n '.' ;
        /bin/cp -p "${yy}" "/run/media/${USER}/2TBBlue3/MVs/${yy}" ;
        echo -n ". $(tput bold; tput blink; tput setaf 3)COPY" ;
      fi ;
      tput sgr0 ; echo ;
    done ; cd /avm1/NO_RSYNC/MVs ;

  ls *.flv *.avi *.mkv *.mp4 *.webm *.ts *.mpg *.vob 2>/dev/null \
    | while read yy ; do
      ./hardsub.sh --out-dir=ZTE --mono --preset=ZTE --srt-font-size=135% "${yy}" ;
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
# NOTE + TODO:
# - Is this what's happening to the older videos?
#   https://forum.videohelp.com/threads/397242-FFMPEG-Interlaced-MPEG2-video-to-x264-Issue
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
# - https://trac.ffmpeg.org/wiki/HowToBurnSubtitlesIntoVideo
#   ffmpeg has 2 text-based subtitle filters: SubRip and Advanced Substation
#   Alpha.  There is no timed text support (have to externally convert it to,
#   say SRT and use that subtitle file if I want to support it).
#   Timed text, I believe, is what U-tube uses for auto-translation, etc.
#
# ffmpeg -y -i "test.mpg" -c:a copy -vf transpose=2,scale=240:-1 test.mp4
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
ATTR_OFF="`tput sgr0`" ;
ATTR_BOLD="`tput bold`" ;
ATTR_UNDL="`tput smul`" ;
ATTR_BLINK="`tput blink`" ;
ATTR_CLR_BOLD="${ATTR_OFF}${ATTR_BOLD}" ;
ATTR_RED="${ATTR_OFF}`tput setaf 1`" ;
ATTR_RED_BOLD="${ATTR_RED}${ATTR_BOLD}" ;
ATTR_GREEN="${ATTR_OFF}`tput setaf 2;`" ;
ATTR_GREEN_BOLD="${ATTR_GREEN}${ATTR_BOLD}" ;
ATTR_YELLOW="${ATTR_OFF}`tput setaf 3`" ;
ATTR_YELLOW_BOLD="${ATTR_YELLOW}${ATTR_BOLD}" ;
ATTR_BLUE="${ATTR_OFF}`tput setaf 4`" ;
ATTR_BLUE_BOLD="${ATTR_BLUE}${ATTR_BOLD}" ;
ATTR_MAGENTA="${ATTR_OFF}`tput setaf 5`" ;
ATTR_MAGENTA_BOLD="${ATTR_MAGENTA}${ATTR_BOLD}" ;
ATTR_CYAN="${ATTR_OFF}`tput setaf 6`" ;
ATTR_CYAN_BOLD="${ATTR_CYAN}${ATTR_BOLD}" ;
ATTR_BROWN="${ATTR_OFF}`tput setaf 94`" ;
ATTR_BROWN_BOLD="${ATTR_BROWN}${ATTR_BOLD}" ;
OPEN_TIC='‘' ;
ATTR_OPEN_TIC="${ATTR_CLR_BOLD}${OPEN_TIC}" ;
CLOSE_TIC='’' ;
ATTR_CLOSE_TIC="${ATTR_CLR_BOLD}${CLOSE_TIC}${ATTR_OFF}" ;

ATTR_ERROR="${ATTR_RED_BOLD}ERROR -${ATTR_OFF}" ;
ATTR_NOTE="${ATTR_OFF}`tput setaf 12`NOTE -${ATTR_OFF}";
ATTR_TOOL="${ATTR_GREEN_BOLD}" ;

G_TMP_FILE='' ;

###############################################################################
###############################################################################
# Ctl-C, signals and exit handler stuff ...
#
stty -echoctl ; # hide '^C' on the terminal output
exit_handler() {

   [ "${G_OPTION_DEBUG}" = '' ] \
       && [ -f "${G_TMP_FILE}" ] \
       && /bin/rm -f "${G_TMP_FILE}" ;
}

sigint_handler() {
   { set +x ; } >/dev/null 2>&1 ;

   MY_REASON='ABORTED' ;
   if [ $# -ne 0 ] ; then
      MY_REASON="$1" ; shift ;
   fi

   exit_handler ;

   tput setaf 1 ; tput bold ;
   for yy in {01..03} ; do echo -n "${MY_REASON} BY USER  " ; done ;
   echo ; tput sgr0 ;

   exit 1 ;
}
trap 'sigint_handler' HUP INT QUIT TERM ; # Don't include 'EXIT' here...
trap 'exit_handler' EXIT ;


###############################################################################
# Required tools (many of these are probably installed by default):
#  - ffmpeg
#  - mkvtoolnix
#  - sed + pcre2 (the library)
#  - coreutils -- basename, cut, head, et. al.
#  - grep       - which includes 'egrep' via script or hard-link to grep
#  - bc         - for (re-)calculating font sizes
#  - jq         - used to parse mkvmerge's json output
#                 developed and tested with version 1.6
#  - dos2unix   - ffmpeg builds a DOS file when converting SRT to ASS subtitles
#  - bash shell - unless you're going with a really old distro, the version of
#                 bash installed is probably modern enough for this script.
#                 No special advanced bash features are intentionally used in
#                 this script (except for array append, but that 1st appeared
#                 in 3.1x or thereabouts).
#                 This script used bash-5.1.0 in its development.
#  - exiftool   - used in this script to get/copy metadata from the source
#                 video to the re-encoded video.
#                 exiftool is a perl script, so (obviously) perl needs to be
#                 installed along with any additional supporting libraries.
#  - agrep + libtre
#               - https://github.com/Wikinaut/agrep
#                 Recent Fedora distros have an 'agrep' package which links
#                 with 'libtre' and can be optionally installed; other distros
#                 may require building from source.
#
MY_SCRIPT="`basename \"$0\"`" ;
DBG='' ;
DBG=':' ;
FFMPEG='/usr/local/bin/ffmpeg -y -nostdin -hide_banner' ;
FFMPEG='ffmpeg -y -nostdin -hide_banner -loglevel info' ;
MKVMERGE='/usr/bin/mkvmerge' ;
MKVEXTRACT='/usr/bin/mkvextract' ;
DOS2UNIX='/bin/dos2unix --force' ;
GREP='/usr/bin/grep --text' ; # saves the embarrassing "binary file matches"
AGREP='/usr/bin/agrep' ;
AGREP_FUZZY_ITERS=6 ;  # Number of agrep passes to make
AGREP_FUZZY_ERRORS=2 ; # This value is mostly arbitrary and arrived at by testing.
                       # This is the number of 'agrep' "failures" we'll count to
                       # determine if the Title in the video is unusable (garbage)
                       # based on comparing it with the filename of the video.
SED='/usr/bin/sed' ;
CUT='/usr/bin/cut' ;
CP='/usr/bin/cp' ;
FOLD='/usr/bin/fold' ;
HEAD='/usr/bin/head' ;
BC='/usr/bin/bc' ;
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
C_FFMPEG_CRF=20 ;
C_FFMPEG_PRESET_DBG='veryfast' ; # Fast, used for batch script --debug testing
C_FFMPEG_PRESET_NOR='veryslow' ; # Good quality w/good compression
C_FFMPEG_MP3_BITS=320 ;         # We'll convert the audio track to MP3
C_FFMPEG_PIXEL_FORMAT='yuvj420p' ; # If it does NOT work, go back to 'yuv420p'.
                                # https://news.ycombinator.com/item?id=20036710
C_SUBTITLE_OUT_DIR='./SUBs' ;   # Where to save the extracted subtitle
C_FONTS_DIR="${HOME}/.fonts" ;  # Where to save the font attachments

G_OPTION_NO_SUBS='' ;           # set to 'y' if '--no-subs' is specified
G_OPTION_NO_MODIFY_SRT='' ;     # for an SRT subtitle, don't apply any sed
                                # scripts to the generated ASS subtitle if
                                # this is set to 'y'.
                                # This flag's use should be pretty rare since
                                # ffmpeg's default conversion is pretty basic.
G_OPTION_NO_MODIFY_ASS='' ;     # TODO write_me + getopt
G_OPTION_ASS_SCRIPT=''    ;     # TODO write_me + getopt
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
G_OPTION_PRESETS=0 ;            # Number of preset selected on commandline.

G_OPTION_SRT_FONT_SIZE=39 ;     # The Default font size for SRT subtitles
                                # If > 1, we'll warn the user, otherwise ...
G_OPTION_SRT_FONT_NAME='Open Sans Semibold' ; # The font for SubRip subtitles
G_OPTION_TITLE='' ;
G_OPTION_ARTIST='' ;
G_OPTION_GENRE='' ;

G_VIDEO_OUT_DIR='OUT DIR' ;     # the re-encoded video's save location
C_SUBTITLE_IN_DIR='IN SUBs' ;   # location for manually added subtitles

  #############################################################################
  # Video filter setup area ...  Still rough around the edges.
  # TODO :: Should I roll up the 'C_VIDEO_PAD_FILTER' filter here?
  #
G_PRE_VIDEO_FILTER='' ;
G_POST_VIDEO_FILTER='' ;
G_ZTE_FIX_FILENAMES=0 ; # Filter special character(s) from the filename (':').
G_FLAC_PASSTHRU=0 ;     # Some devices support FLAC, so if the source is FLAC,
                        # tell ffmpeg to pass it through (using '-c:a copy').
G_OPTION_MONO=0 ;       # down sample the audio to mono

  #############################################################################
  # We'll re-encode the video to h264.
  #
  # BUT h264 has some size constraints that we have to “fix” from the input
  # video (something about a odd number of rows or columns -- I don't remember
  # the exact error message).  The easiest fix is to always apply the “fix”
  # since on "correct" input videos, the fix will not have a negative effect.
  #
  # This may also happen when re-sizing a video.
  #
C_VIDEO_PAD_FILTER='pad=width=ceil(iw/2)*2:height=ceil(ih/2)*2' ; # The "fix"

declare -a SED_SCRIPT_ARRAY=();

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
#
C_OUTPUT_CONTAINER='mp4' ; # Some older TVs may be able to read MKV files...

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
  echo -n ' ls *.flv *.avi *.mkv *.mp4 *.webm *.ts *.mpg *.vob 2>/dev/null '
  echo    '| while read yy ; do '$0' "${yy}" ; done' ;

  exit $L_RC ;
}


###############################################################################
# Configure a preset.
#
# A preset is a static set of configuration(s) that you may want to always
# apply to a specific playback device.  Examples might include always scaling
# the video to the device's screen size, or other re-encoding attributes.
#
configure_preset() {
  local my_option="$1" ; shift ;
  local my_preset="$1" ; shift ;
  local my_preset_count="$1" ; shift ;

  while : ; do  # {
    if [ "${my_preset}" = '' ] ; then  # Pedantic, I know ...
      echo "${ATTR_ERROR} '${my_option}' requires a preset name to apply." >&2 ;
      break ;
    fi

    case "${my_preset}" in  # {
    linkII|ZTE|zte)
      G_POST_VIDEO_FILTER='transpose=2' ;
        #######################################################################
        # Why use 640 when the phone is 2.8” (240x320)/1.7 (128x160)” TFT LCD?
        # It has to do with the font scaling.  The font rendering at small
        # point sizes is rough - it seems I get better results applying a font
        # to a larger image and then letting the phone's HW scaler fit it to
        # the display.  Downsides: larger file size and larger file size for
        # videos w/o subtitles.  A possible solution is to smart-scale the
        # video - if there is a subtitle, scale it larger, otherwise, scale to
        # the device's native display size.
        #
      G_PRE_VIDEO_FILTER='scale=640:-1' ;
      G_SMART_SCALING=1 ; # TODO :: A marker for a future improvement.
        #######################################################################
        # Some filenames do NOT copy to the phone.  Not a lot of info about the
        # exact filesystem on the phone, I suspect some version of NTFS?  Looks
        # like a ':' in the filename breaks the copy (no useful error message).
        #
      G_ZTE_FIX_FILENAMES=1 ;
      ;;
    *)
      echo "${ATTR_ERROR} unrecognized preset='${my_preset}'" ;
      break ;
      ;;
    esac  # }

    return 0;
  done ;  # }

  exit 1;
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
      # SUCCESS :: return (echo) the successfully built directory is required.
      #
    [ "${my_option}" != '' ] && echo "${my_directory}" ;
    return 0;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've alredy printed an appropriate error message above.
    #
  exit 1 ;
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
  local in_number="$1" ; shift ;
  local my_option="$1" ; shift ;
  local in_percentage="$1" ; shift ;
  local my_scale="$1" ; shift ;

  ${DBG} echo "OPTION = '${my_option}', PERCENTAGE = '${my_percentage}'" >&2 ;

  while : ; do  # {
    if [ "${in_percentage}" = '' ] ; then  # Pedantic, I know ...
      echo "${ATTR_ERROR} '${my_option}' requires a percentage value." >&2 ;
      break ;
    fi

    local my_percentage="$(echo "${in_percentage}" | sed -e 's/%$//')" ;

    local my_regex='^[0-9]+([.][0-9]+)?$' ;
    if ! [[ "${my_percentage}" =~ ${my_regex} ]] ; then
      echo "${ATTR_ERROR} '${my_option}=${in_percentage}' is not a number" ;
      break ;
    fi

    echo "scale=${my_scale};${in_number} * (${my_percentage} / 100)" | ${BC} ;

    return 0;
  done ;  # }

    ###########################################################################
    # FAILURE :: exit; we've alredy printed an appropriate error message above.
    #
  exit 1 ;
}

# XXXX
###############################################################################
#
add_other_commandline_options() {
  echo -n '' ;
  #echo '-srt-font-size=130%' ;
}


###############################################################################
#
my_set_system_variables() {

  G_OPTION_NO_SUBS='' ;
  G_OPTION_VERBOSE='' ;
}

if [ $# -eq 0 ] ; then

  my_usage 2;
fi


###############################################################################
###############################################################################
###############################################################################
# Setup and use getopt for the command line arguments.
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
HS_OPTIONS=`getopt -o h::vc:f:yt:q: \
    --long help::,verbose,config:,fonts-dir:,copy-to:,quality:,\
debug,\
mono,\
no-subs,\
no-comment,\
no-metadata,\
no-modify-srt,\
no-fuzzy,\
preset::,\
out-dir::,\
srt-font-size:: \
    -n "${ATTR_ERROR} ${ATTR_BLUE_BOLD}${MY_SCRIPT}${ATTR_YELLOW}" -- "$@"` ;

if [ $? != 0 ] ; then
   my_usage 1 ;
fi

my_set_system_variables ;

eval set -- "${HS_OPTIONS}" ;
while true ; do  # {
  SEP=' ' ;

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
  --debug)
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
  --out-dir)
    G_VIDEO_OUT_DIR="$(check_and_build_directory "$1" "$2")" ;
    shift 2;
    ;;
  --srt-font-size)
    IN_SIZE="${G_OPTION_SRT_FONT_SIZE}" ;
    G_OPTION_SRT_FONT_SIZE="$(apply_percentage "${G_OPTION_SRT_FONT_SIZE}" "$1" "$2" 1)" ;
    echo -n "${ATTR_YELLOW_BOLD}  SETTING SubRip font size ${ATTR_CLR_BOLD}" ;
    echo -n "(${IN_SIZE})${ATTR_OFF} to ${ATTR_GREEN_BOLD}${G_OPTION_SRT_FONT_SIZE}" ;
    echo    "${ATTR_CLR_BOLD}.${ATTR_OFF}" ;
      # TODO :: add a note about this to the comments IF the video really had SubRip subtitles
    shift 2;
    ;;
  --preset)
    (( G_OPTION_PRESETS++ ));
    configure_preset "$1" "$2" "${G_OPTION_PRESETS}" ;
    shift 2;
    ;;
  -v|--verbose)
    G_OPTION_VERBOSE='y' ; shift ;
    ;;
  -h|--help)
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


  #############################################################################
  # Do the remaining input validation here
  #
if [ $# -ne 1 ] ; then
  echo "${ATTR_ERROR} no input filename was specified" ;
  exit 2;
fi

check_and_build_directory '' "${G_VIDEO_OUT_DIR}" ;
check_and_build_directory '' "${C_SUBTITLE_OUT_DIR}" ;
check_and_build_directory '' "${C_SUBTITLE_IN_DIR}" ;

check_and_build_directory '' "${C_FONTS_DIR}" ;

###############################################################################
###############################################################################
###############################################################################

G_IN_FILE="$1" ; shift ;

mkdir -p "${C_SUBTITLE_OUT_DIR}" ;
if [ $? -ne 0 ] ; then
   echo "${ATTR_ERROR} Can't make the subtitle directory!" ;
   exit 1;
fi

G_IN_EXTENSION="${G_IN_FILE##*.}" ;
G_IN_BASENAME="$(basename "${G_IN_FILE}" ".${G_IN_EXTENSION}")" ;


###############################################################################
# TODO :: make these (and other) proper command line args
#
if [ $# -ne 0 ] ; then
    echo 'EXTRA ARGS' ;
    C_FFMPEG_CRF="$1" ; shift ;
    C_FFMPEG_MP3_BITS=192;
fi


###############################################################################
###############################################################################
# The *way* ffmpeg seems to work (probably documented somewhere) is that if
# the source metadata tag is __set__, then that metadata is copied to the
# output file.  I haven't tested to see if there's any filtering done in this
# process (e.g. coping a video specific tag to an audio only output file), but
# since this script doesn't do those types of conversions, I'll skip it 4 now.
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
# | ${SED} -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
#
get_video_title() {
  local in_filename="$1" ; shift ;
  local in_title="$1" ; shift ;
  local in_video_basename="$1" ; shift ;

  local out_title='' ; # The default if 'Title' IS set in the video

  if [ "${in_title}" != '' ] ; then  # {
      # The title is explicitly set by the user
    out_title="${in_title}" ;

  else  # }{
    local title_in_video="$(${EXIFTOOL} "${in_filename}" \
                     | ${GREP} '^Title' \
                     | sed -e 's/^.*: //')" ;
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
                   | ${SED} -e 's/[_+]/ /g'  \
                   )" ;
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
      for (( fuzz=1; fuzz <= ${AGREP_FUZZY_ITERS}; fuzz++ )); do
        echo "${in_filename}" \
          | ${AGREP} -${fuzz} -k -i -q "${title_in_video}" ;
        (( fuzzy_errors += $? )) ;
      done  # }
      if [ ${fuzzy_errors} -ge ${AGREP_FUZZY_ERRORS} ] ; then  # {

          ## FIXME -- I should do this filtering cleanup elsewhere ...
        out_title="$(echo "${in_video_basename}" \
                     | ${SED} -e 's/[_+]/ /g'  \
                     )" ;
      fi  # }
    fi  # }
  fi  # }

  #############################################################################
  # Ensure that any single quotes are escaped.  FIXME should be done elsewhere.
  ## 'title=The Byrd'"'"'s - Turn! Turn! Turn! (2nafish)'
  #
  echo "$(echo "${out_title}" \
                   | ${SED} -e 's#\([\x27]\)#\1"\1"\1#g')" ;
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
                     | ${GREP} '^Genre' \
                     | sed -e 's/^.*: //')" ;
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
  # Ensure that any single quotes are escaped.  FIXME should be done elsewhere.
  # TODO :: Do I also need to escape the ',' character in the genre?
  #
  echo "$(echo "${out_genre}" \
                   | ${SED} -e 's#\([\x27]\)#\1"\1"\1#g')" ;
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
#         name in the subtitle file.  So, probably not gonna happen ...
#
# FIXME :: Theoretically, a video containing an SRT subtitle __could__ have an
#          attached font.  We'll only use that info to NOT display the warning
#          about 'no font attachments were found' below.
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
  ### TEST_CODE mkvmerge -i "${in_video}" | egrep 'XXXXXXX' \
  ${MKVMERGE} -i "${in_video}" | egrep 'truetype|opentype|font.ttf|font.otf' \
                               | while read attachment_line ; do # {

    have_font_attachments='Y' ;

      #########################################################################
      # Attachment IDs are NOT always sequential, so we need to capture each
      # attachment's ID.  Also, attachment names may have embedded SPACEs.
      #
    local attachment_ID=`echo "${attachment_line}" \
                        | ${SED} -e 's/Attachment ID \([0-9][0-9]*\):.*$/\1/'` ;
    local attachment_file=`echo "${attachment_line}" \
                        | ${CUT} -d' ' -f 11- \
                        | ${SED} -e "s/'//g"` ;

    local font_pathname="${attachments_dir}/${attachment_file}" ;

    if [ ! -f "${font_pathname}" ] ; then # {
      attachment_list="${attachment_list}${attachment_ID}:${font_pathname} " ;
      MSG="`${MKVEXTRACT} attachments \"${in_video}\" \"${attachment_ID}:${font_pathname}\"`" ;
      if [ $? -eq 0 ] ; then  # {
        echo    "${MSG}" \
          | ${SED} -e "s/.*is written to \(.*\).$/${pad_spaces}<< ${ATTR_BLUE_BOLD}EXTRACTING ${ATTR_CLR_BOLD}${attachment_ID}:${attachment_file}${ATTR_OFF} to ${ATTR_CYAN_BOLD}\1${ATTR_OFF}. >>/" \
          | ${SED} -e "s#${HOME}#\\\${HOME}#g" ;
      else  # }{
        ERR_MKVMERGE=1;
        MSG="`echo -n \"${MSG}\" | tail -1 | cut -d' ' -f2-`" ;
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
  local subtitle_track="$1" ; shift ;


  local track_ID=`echo "${subtitle_track}" | cut -f1 -d' '` ;

  echo -n "   ${ATTR_CYAN_BOLD}Track ${ATTR_CLR_BOLD}${track_ID} ==> " ;
  echo    "${ATTR_YELLOW}'$(basename "${save_to_file}")' ${ATTR_OFF}..." ;

  ${MKVEXTRACT} tracks "${in_video}" "${track_ID}:${save_to_file}" \
    >/dev/null 2>&1 ;
}


###############################################################################
###############################################################################
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
      'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding <==> Style: Default Italic,'"${G_OPTION_SRT_FONT_NAME}"','"${G_OPTION_SRT_FONT_SIZE}"',&H30FF00DD,&H000000FF,&H00101010,&H20A0A0A0,0,1,0,0,100,100,0,0,1,2.2,0,2,105,105,11,1'
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
        'Style: Default,'"${G_OPTION_SRT_FONT_NAME}"','"${G_OPTION_SRT_FONT_SIZE}"',&H6000F8FF,&H000000FF,&H00101010,&H50A0A0A0,-1,0,0,0,100,100,0,0,1,2.75,0,2,100,100,12,1'
      #########################################################################
      # - Note that the necessary _replacement_ escapes are added by the MAIN
      #   script, i.e., the '&' character does not need to be and should NOT
      #   be escaped in the replacement part.
      # - Because some libass directives are preceeded by a '\' character, e.g.
      #   '{\pos(13,80)}'.  This makes using the '\' character a little tricky
      #   Consider the following sed script pair (from a converted SRT file):
      #
    '^Dialogue: \(.*\),Default,\(.*\),{\\i1}\(.*\){\\i[0]*}$'
        'Dialogue: %%%1,Default Italic,%%%2,%%%3'
      #
      #   Its purpose is to detect a line that is all italic, and select a
      #   different style for that Dialogue line keeping everything else the
      #   same.  In this case, the \1, \2, and \3 capture buffer specifiers
      #   are represented as %%%1, %%%2, and %%%3 in the replacement string.
      #   Ugly, I know.
  ) ;

  # https://unix.stackexchange.com/questions/181937/how-create-a-temporary-file-in-shell-script
  G_TMP_FILE="$(mktemp "/tmp/${C_SCRIPT_NAME}-sed.XXXXXX")" ;
# exec 3>"${G_TMP_FILE}" ;
# exec 4<"${G_TMP_FILE}" ;
# /bin/rm -f "${G_TMP_FILE}" ;

  { # (I'm not going to bother adjusting the indent for this block ...)
  local ido=0 ;
  local idx=0 ;

  while [ "${SED_SCRIPT_ARRAY[$idx]}" != '' ] ; do  # {

    (( ido = (idx / 2) + 1 )) ; # A temp for displaying the regex index
    printf "${ATTR_BROWN_BOLD}%.2d${ATTR_OFF}." ${ido} ;

      #########################################################################
      # Insane shell escape sequences - also, the sed '-e' ordering is
      # important.  This is because some .ASS directives are preceeded by a
      # '\', e.g. {\pos(13,80)}.  Note, regex captures are complicated to code
      # -- I ended up using '%%%' to represent the '\' character to simplify
      # the scripting.
      #
    ${GREP} -q "${SED_SCRIPT_ARRAY[$idx]}" "${ASS_SRC}" ; RC=$? ;
    if [ ${RC} -eq 0 ] ; then  # {
      echo -n "${ATTR_GREEN_BOLD}." ;
      (( ido = idx + 1 )) ;
      REPLACEMENT_STR=`echo "${SED_SCRIPT_ARRAY[$ido]}" \
          | ${SED} -e 's#\\\#\\\\\\\#g'   \
                   -e 's/,&H/,\\\\\&H/g'  \
                   -e 's/ <==> /\\\\n/g'  \
                   -e 's/%%%/\\\/g'
                 `;
      echo -n '! ' ;

      echo "s#${SED_SCRIPT_ARRAY[$idx]}#${REPLACEMENT_STR}#" \
        >> "${G_TMP_FILE}" ;

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
      | ${SED} "--file=${G_TMP_FILE}" \
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
  SED_SCRIPT_ARRAY=( # HERE-HERE
#   '^Format: Name,.*'
#     'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding'

    ###########################################################################
    # Here are a few common ‘Default’ ASS subtitle styles ...
    #
    '^Style: Default,Roboto Medium,.*'
       'Style: Default,Roboto Medium,24,&H4820FAFF,&H000000FF,&H13102810,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,2,100,100,14,0'
    '^Style: Default,Fontin Sans Rg,.*'
       'Style: Default,Fontin Sans Rg,46,&H30EBEFF6,&H000000FF,&H10091A04,&HBE000000,-1,0,0,0,100,100,0,0,1,2.4,1,2,90,90,14,1'
    '^Style: Default,Open Sans Semibold,.*'
       'Style: Default,Open Sans Semibold,45,&H4820FAFF,&H000000FF,&H00020713,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,2,80,80,13,1'

    ###########################################################################
    # These are some common additional stylizations ...
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
  G_TMP_FILE="$(mktemp "/tmp/${C_SCRIPT_NAME}-sed.XXXXXX")" ;
# exec 3>"${G_TMP_FILE}" ;
# exec 4<"${G_TMP_FILE}" ;
# /bin/rm -f "${G_TMP_FILE}" ;

  { # (I'm not going to bother adjusting the indent for this block ...)
  local ido=0 ;
  local idx=0 ;

  while [ "${SED_SCRIPT_ARRAY[$idx]}" != '' ] ; do  # {

    (( ido = (idx / 2) + 1 )) ; # A temp for displaying the regex index
    printf "${ATTR_BROWN_BOLD}%.2d${ATTR_OFF}." ${ido} ;

      #########################################################################
      # Insane shell escape sequences - also, the sed '-e' ordering is
      # important.  This is because some .ASS directives are preceeded by a
      # '\', e.g. {\pos(13,80)}.  Note, regex captures are complicated to code
      # -- I ended up using '%%%' to represent the '\' character to simplify
      # the scripting.
      #
    ${GREP} -q "${SED_SCRIPT_ARRAY[$idx]}" "${ASS_SRC}" ; RC=$? ;
    if [ ${RC} -eq 0 ] ; then  # {
      echo -n "${ATTR_GREEN_BOLD}." ;
      (( ido = idx + 1 )) ;
      REPLACEMENT_STR=`echo "${SED_SCRIPT_ARRAY[$ido]}" \
          | ${SED} -e 's#\\\#\\\\\\\#g'   \
                   -e 's/,&H/,\\\\\&H/g'  \
                   -e 's/ <==> /\\\\n/g'  \
                   -e 's/%%%/\\\/g'
                 `;
      echo -n '! ' ;

      echo "s#${SED_SCRIPT_ARRAY[$idx]}#${REPLACEMENT_STR}#" \
        >> "${G_TMP_FILE}" ;

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
      | ${SED} "--file=${G_TMP_FILE}" \
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
echo -n "${ATTR_BLUE_BOLD}<< " ;
echo -n "'${ATTR_GREEN_BOLD}${G_IN_FILE}${ATTR_OFF}${ATTR_BLUE_BOLD}'"
echo    " >>${ATTR_OFF} ..." ;

if [ -s "${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" ] ; then
  echo -n "  $(tput setaf 3 ; tput bold)COMPLETED$(tput sgr0; tput bold) "
  echo    "'${G_IN_FILE}'$(tput sgr0) ..." ;
  exit 0;
fi


  #############################################################################
  # A little hack to speed up testing / development and save temporary files.
  #
if [ "${G_OPTION_DEBUG}" = '' ] ; then
  C_FFMPEG_PRESET="${C_FFMPEG_PRESET_NOR}" ;
else
  C_FFMPEG_PRESET="${C_FFMPEG_PRESET_DBG}" ;
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
# - if '--no-subs' option is specified, any/all subtitles will be ignored and
#   will not be hard-sub'd in the video during the re-encoding;
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
# None of the above will explicitely trigger a re-encoding of the video, only
# a missing or out-of-date video will trigger the re-encoding process.  These
# steps only determine if subtitles should be reprocessed for the re-encoding.
#
# ⚙️ IN OTHER WORDS, simply adding/replacing a subtitle file will not trigger
#   a re-encoding of the video by this script.
###############################################################################
#
if [ "${G_OPTION_NO_SUBS}" != 'y' ] ; then  # {

  if [ -s "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" ] ; then  # {

    ###########################################################################
    # See if this subtitle is NEWER than our previous version.  If the right
    # side of the '-nt' EXPRESSION is NOT there, then the test succeeds (i.e.,
    # the file is __newer__ than the non-existant file).  This seems logical
    # and __maybe__ implied by the man page, but there is NO explicit example
    # of this in the man page (“An omitted EXPRESSION defaults to false”).
    # Is a non-existant file considered an omitted EXPRESSION?
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
      ${FFMPEG} -i "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
                   "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
          >/dev/null 2>&1 ;
      { RC=$? ; set +x ; } >/dev/null 2>&1
      if [ ${RC} -ne 0 ] ; then
        echo -n "${ATTR_ERROR} ${FFMPEG} -i " ;
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

      echo "${ATTR_YELLOW_BOLD}SRT SUBTITLE ALREADY PROCESSED$(tput sgr0) ..." ;

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

    # so let's see if there are any font
    # attachment(s) in the video.  If there are, then extract those fonts to
    # the fonts' directory (in 'C_FONTS_DIR') to provide visibility to ffmpeg.
    #

  else  # }{

    SUBTITLE_TRACK="$(${MKVMERGE} -i -F json "${G_IN_FILE}" \
        | jq '.tracks[]' \
        | jq -r '[.id, .type, .properties.codec_id, .properties.track_name, .properties.language]|@sh' \
        | ${GREP} "'subtitles' 'S_TEXT/" \
        | ${HEAD} -1 \
        | ${GREP} "'subtitles' 'S_TEXT/")" ; RC=$? ;

    if [ ${RC} -eq 0 ] ; then  # { OKAY  HERE-HERE  YYYY

      if ( echo "${SUBTITLE_TRACK}" | ${GREP} -q "'subtitles' 'S_TEXT/ASS'" ) ; then  # {
        echo "${ATTR_YELLOW_BOLD}  SUBSTATION ALPHA SUBTITLE FOUND IN VIDEO$(tput sgr0) ..." ;

        extract_subtitle_track "${G_IN_FILE}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            "${SUBTITLE_TRACK}" ;

        G_SUBTITLE_PATHNAME="${C_SUBTITLE_OUT_DIR}/${G_IN_BASENAME}.ass" ;
        apply_script_to_ass_subtitles \
            "${G_OPTION_NO_MODIFY_ASS}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            "${G_SUBTITLE_PATHNAME}" \
            "${G_OPTION_ASS_SCRIPT}" ;

        extract_font_attachments \
            "${G_IN_FILE}" \
            "${C_FONTS_DIR}" \
            0 ;

      elif ( echo "${SUBTITLE_TRACK}" | ${GREP} -q "'subtitles' 'S_TEXT/UTF8'" ) ; then  # }{
        echo "${ATTR_CYAN_BOLD}  SUBRIP SUBTITLE FOUND IN VIDEO$(tput sgr0) ..." ;

        extract_subtitle_track "${G_IN_FILE}" \
            "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
            "${SUBTITLE_TRACK}" ;

        ${FFMPEG} -i "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.srt" \
                     "${C_SUBTITLE_IN_DIR}/${G_IN_BASENAME}.ass" \
            >/dev/null 2>&1 ; RC=$? ;
        { set +x ; } >/dev/null 2>&1
        if [ ${RC} -ne 0 ] ; then
          echo -n "${ATTR_ERROR} ${FFMPEG} -i " ;
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
            "${G_IN_FILE}" \
            "${C_FONTS_DIR}" \
            1 ;

      else  # }{
        echo -n "${ATTR_YELLOW_BOLD}$(tput blink)NOTICE${ATTR_OFF} $(tput bold)-- " ;
        echo -n "skipping unknown/unsupported "
        echo -n "$(tput setaf 5)S_TEXT$(tput sgr0; tput bold) "
        echo    "subtitle type -- $(tput sgr0)" ;
        echo    "      <<< '${ATTR_YELLOW}${SUBTITLE_TRACK}$(tput sgr0)' >>>" ;
      fi  # }
    fi  # }
  fi  # }
else  # }{
  echo 'SUBTITLES WERE FORCED SKIPPED' ;
fi  # }


###############################################################################
# HERE-HERE
###############################################################################
#               | ${SED} -e 's#\([][ :,()\x27]\)#\\\\\\\\\\\\\1#g' ;
#               | ${SED} -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g' ; # NO COMMA
#
FFMPEG_METADATA='' ;
if [ "${G_OPTION_NO_METADATA}" = '' ] ; then  # {

  G_METADATA_TITLE="$(get_video_title "${G_IN_FILE}" "${G_OPTION_TITLE}" "${G_IN_BASENAME}")" ;
  if [ "${G_METADATA_TITLE}" != '' ] ; then  # {
    ## TODO :: split the artist / title here?
    FFMPEG_METADATA=" '-metadata' 'title=${G_METADATA_TITLE}'" ;
  fi  # }

  G_METADATA_GENRE="$(get_video_genre "${G_IN_FILE}" "${G_OPTION_GENRE}" "${C_DEFAULT_GENRE}")" ;
  if [ "${G_METADATA_GENRE}" != '' ] ; then  # {
    FFMPEG_METADATA="${FFMPEG_METADATA} '-metadata' 'genre=${G_METADATA_GENRE}'" ;
  fi  # }
  { set +x ; } >/dev/null 2>&1
fi  # }


###############################################################################
# Welcome to the wonderful world of shell escapes and building CLI strings!
# I wish ffmpeg could append '-vf' filter arguments together -- maybe there's
# a sound reason for why it doesn't, but it makes building '-vf' dynamically
# quite the tickler.
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
if [ "${G_PRE_VIDEO_FILTER}" != '' ] ; then
  if [ "${C_VIDEO_PAD_FILTER}" = '' ] ; then
     C_VIDEO_PAD_FILTER="${G_PRE_VIDEO_FILTER}" ;
  else
     C_VIDEO_PAD_FILTER="${G_PRE_VIDEO_FILTER},${C_VIDEO_PAD_FILTER}" ;
  fi
fi

if [ "${G_SUBTITLE_PATHNAME}" = '' ] ; then  # {
  if [ "${C_VIDEO_PAD_FILTER}" = '' ] ; then
    eval set -- ; # Build an EMPTY eval just to keep the code simple ...
  else
    C_FFMPEG_VIDEO_FILTERS="`echo "${C_VIDEO_PAD_FILTER}" \
                | ${SED} -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
                  # NOTE absence of ',' after the ':'
    eval set -- "${C_FFMPEG_VIDEO_FILTERS}" ;
  fi
else
  G_FFMPEG_SUBTITLE_FILENAME="`echo "${G_SUBTITLE_PATHNAME}" \
                | ${SED} -e 's#\([][ :,()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
  G_FFMPEG_FONTS_DIR="`echo "${C_FONTS_DIR}" \
                | ${SED} -e 's#\([][ :,()\x27]\)#\\\\\\\\\\\\\1#g'`" ;

  if [ "${C_VIDEO_PAD_FILTER}" = '' ] ; then  # {
    eval set -- "subtitles=${G_FFMPEG_SUBTITLE_FILENAME}:fontsdir=${G_FFMPEG_FONTS_DIR}" ;
  else  # }{
    C_FFMPEG_VIDEO_FILTERS="`echo "${C_VIDEO_PAD_FILTER}" \
                | ${SED} -e 's#\([][ :()\x27]\)#\\\\\\\\\\\\\1#g'`" ;
                  # NOTE absence of ',' after the ':'
    eval set -- "${C_FFMPEG_VIDEO_FILTERS},subtitles=${G_FFMPEG_SUBTITLE_FILENAME}:fontsdir=${G_FFMPEG_FONTS_DIR}" ;
  fi  # }
fi  # }

# TODO :: description
ARGs='' ;
ARG_IDX=0;
ARG_SPACE=' ';
for ARG in "$@" ; do
  (( ARG_IDX++ ));
  [[ ${ARG_IDX} -eq $# ]] && ARG_SPACE='' ;
  ARGs="${ARGs}'${ARG}'${ARG_SPACE}";
done

# TODO :: description
if [ "${G_POST_VIDEO_FILTER}" != '' ] ; then  # {
  if [ "${ARGs}" = '' ] ; then
    FFMPEG_FILTER_COMMA='' ;
  else
    FFMPEG_FILTER_COMMA=',' ;
  fi
fi  # }
eval set -- "'-vf' ${ARGs}${FFMPEG_FILTER_COMMA}${G_POST_VIDEO_FILTER}${FFMPEG_METADATA}" ;

# TODO :: description
G_FFMPEG_AUDIO_CHANNELS='' ;
if [ "${G_OPTION_MONO}" -eq 1 ] ; then
  G_FFMPEG_AUDIO_CHANNELS='-ac 1' ;
fi

###############################################################################
# This is where the hammer meets the road!
#
if [ ! -s "${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" ] ; then  # {

  RC=0 ;
  if   [ "${G_OPTION_NO_COMMENT}" = 'y' ] \
    || [ "${G_OPTION_NO_METADATA}" = 'y' ] ; then  # {

    set -x ; # We want to KEEP this enabled.
    ${FFMPEG} -i "${G_IN_FILE}" \
              -c:a libmp3lame -ab ${C_FFMPEG_MP3_BITS}K ${G_FFMPEG_AUDIO_CHANNELS} \
              -c:v libx264 -preset ${C_FFMPEG_PRESET} \
              -crf ${C_FFMPEG_CRF} \
              -tune film -profile:v high -level 4.1 -pix_fmt ${C_FFMPEG_PIXEL_FORMAT} \
              "$@" \
              "file:${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" ;
    { RC=$? ; set +x ; } >/dev/null 2>&1

  else  # }{

      #########################################################################
      # If the comment isn't set, then build a default comment.
      # NOTE -- this has to be done here because we need to evaluate "$@"
      #         to get the remaining ffmpeg options ...
      #
    G_VIDEO_COMMENT='' ;
    if [ "${C_METADATA_COMMENT}" = '' ] ; then  # {
      G_VIDEO_COMMENT="`cat <<HERE_DOC
Encoded on $(date)
$(uname -sr ;
  ffmpeg -version | egrep '^ffmpeg ' | sed -e 's/version //' -e 's/ Copyright.*//' ;
  add_other_commandline_options ;)
ffmpeg -c:a libmp3lame -ab ${C_FFMPEG_MP3_BITS}K ${G_FFMPEG_AUDIO_CHANNELS} -c:v libx264 -preset ${C_FFMPEG_PRESET} -crf ${C_FFMPEG_CRF} -tune film -profile:v high -level 4.1 -pix_fmt ${C_FFMPEG_PIXEL_FORMAT} $(echo $@ | ${SED} -e 's/[\\]//g' -e "s#${HOME}#\\\${HOME}#g" -e 's/ -metadata .*//')
HERE_DOC
`" ;
    else  # }{
      echo 'FIXME' ;
    fi  # }

    set -x ; # We want to KEEP this enabled.
    ${FFMPEG} -i "${G_IN_FILE}" \
              -c:a libmp3lame -ab ${C_FFMPEG_MP3_BITS}K ${G_FFMPEG_AUDIO_CHANNELS} \
              -c:v libx264 -preset ${C_FFMPEG_PRESET} \
              -crf ${C_FFMPEG_CRF} \
              -tune film -profile:v high -level 4.1 -pix_fmt ${C_FFMPEG_PIXEL_FORMAT} \
              "$@" \
              -metadata "comment=${G_VIDEO_COMMENT}" \
              "file:${G_VIDEO_OUT_DIR}/${G_IN_BASENAME}.${C_OUTPUT_CONTAINER}" ;
    { RC=$? ; set +x ; } >/dev/null 2>&1

  fi  # }
else  # }{

  echo "$(tput setaf 3 ; tput bold)COMPLETED$(tput sgr0; tput bold) '${G_IN_FILE}'$(tput sgr0) ..." ;
  RC=0 ;
fi  # }

exit ${RC} ;

