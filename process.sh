

DIR=$1

if [ "$#" -ne 1 ]; then
  echo "Requires a source directory to run on"
  exit 1
fi

OUT_DIR="${DIR}/musincs"
mkdir -p ${OUT_DIR}

# prepare the data for JSON formatting

echo "(function() { var JSON_DATA = [ " > data.js
for file in `cat ${OUT_DIR}/analyzed.log`; do
  music_name=`basename $file`
  echo "{ name: '${music_name}'," >> data.js
  echo "file: '${file}'," >> data.js

  bpm=`cat ${OUT_DIR}/${music_name}.bpm`
  echo "bpm: ${bpm}," >> data.js
  echo "chords: [ " >> data.js
  chords=`cat ${OUT_DIR}/${music_name}.chords`
  echo "$chords" | sed -e 's/^/[/' -e 's/$/],/' >> data.js

  echo "]}, " >> data.js
done

echo -e "];" >> data.js

echo "load_data(JSON_DATA);" >> data.js
echo -e "})();\n" >> data.js

