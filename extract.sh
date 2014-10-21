# takes a list of mp3 files and generates some data for them, including bpm and
# their chord changes

# requires sonic-annotator
# requires bpm-graph

SONIC_ANNOTATOR_BIN="~/tonka/apps/sonic_annotator/sonic-annotator"
BPM_GRAPH_BIN="bpm-graph"

DIR=$1

MP3_FILES=`ls $1/*.mp3`

OUT_DIR="${DIR}/musincs"
mkdir -p ${OUT_DIR}

${SONIC_ANNOTATOR_BIN} -s vamp:nnls-chroma:chordino:simplechord > chord.n3 2>/dev/null

for file in ${MP3_FILES}; do
  echo "Analyzing ${file}"
  base=`basename ${file}`
  out_file=${OUT_DIR}/${base}
  ${BPM_GRAPH_BIN} ${file} 2>/dev/null > ${out_file}.bpm
  ${SONIC_ANNOTATOR_BIN} -t chord.n3 ${file} -w csv --csv-omit-filename --csv-stdout 2> /dev/null > ${out_file}.chords
  echo ${file} >> analyzed.log
done


