

DIR=$1

if [ "$#" -ne 1 ]; then
  echo "Requires a source directory to run on"
  exit 1
fi

OUT_DIR="${DIR}/musincs"
mkdir -p ${OUT_DIR}

DATA_FILE="${OUT_DIR}/data.js"

# prepare the data for JSON formatting

echo "(function() { var JSON_DATA = [ " > ${DATA_FILE}
for file in `cat ${OUT_DIR}/analyzed.log`; do
  music_name=`basename $file`
  echo "{ name: '${music_name}'," >> "${DATA_FILE}"
  echo "file: '${file}'," >> "${DATA_FILE}"

  bpm=`cat ${OUT_DIR}/${music_name}.bpm`
  echo "bpm: ${bpm}," >> ${DATA_FILE}
  echo "chords: [ " >> ${DATA_FILE}
  chords=`cat "${OUT_DIR}/${music_name}.chords"`
  echo "$chords" | sed -e 's/^/[/' -e 's/$/],/' >> ${DATA_FILE}

  echo "]}, " >> "${DATA_FILE}"
done

echo -e "];" >> "${DATA_FILE}"

echo "load_data(JSON_DATA);" >> ${DATA_FILE}
echo -e "})();\n" >> ${DATA_FILE}

cp viewer.html $OUT_DIR/index.html
cp -R inc/ $OUT_DIR
