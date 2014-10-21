# takes a list of mp3 files and generates some data for them, including bpm and
# their chord changes

# requires sonic-annotator
# requires bpm-graph

SONIC_ANNOTATOR_BIN=~/tonka/apps/sonic_annotator/sonic-annotator
BPM_GRAPH_BIN=bpm-graph

DIR=$1

if [ "$#" -ne 1 ]; then
  echo "Requires a source directory to run on"
  exit 1
fi


OUT_DIR="${DIR}/musincs"
mkdir -p ${OUT_DIR}

${SONIC_ANNOTATOR_BIN} -s vamp:nnls-chroma:chordino:simplechord > chord.n3 2>/dev/null

echo -n "" > ${OUT_DIR}/analyzed.log
for file in ${DIR}/*.mp3; do
  echo "Analyzing ${file}"
  base=`basename "${file}"`
  out_file="${OUT_DIR}/${base}"
  ${BPM_GRAPH_BIN} "${file}" > "${out_file}.bpm"
  ${SONIC_ANNOTATOR_BIN} -t chord.n3 "${file}" -w csv --csv-omit-filename --csv-stdout > "${out_file}.chords"
  echo "${file}" >> ${OUT_DIR}/analyzed.log
done
