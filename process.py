#!/usr/bin/env bash
# take in the list of analyzed files and then turn them into an HTML page?

import sys
import os
import random


# make sure to pip install these
import html
import svgwrite

from svg_colors import SVG_COLORS

SEED=44

if len(sys.argv) < 2:
    print "NO DIR SUPPLIED"
    sys.exit(0)

process_dir = sys.argv[1]
print "PROCESSING", process_dir

analyzed = open(os.path.join(process_dir, "analyzed.log")).readlines()


def get_svg_file(music_file):
    basename = os.path.basename(music_file)
    svg_name = os.path.join(process_dir, basename + ".svg")

    return svg_name
    # generate an HTML file with all the SVGs in it, now

COLOR_USED = {}
COLOR_MAPPED = {
    "N" : "gray"
}
def get_fill_color(chord):
    chord = chord.strip().strip('"')
    chord_root = chord[0]
    if len(chord) >= 2 and chord[1] is 'b':
        chord_root += chord[1]

    if not chord_root in COLOR_MAPPED:
        choice = None
        while not choice:
            choice = random.choice(SVG_COLORS)
            if choice in COLOR_USED:
                choice = None

        COLOR_MAPPED[chord_root] = choice
        COLOR_USED[choice] = True

    return COLOR_MAPPED[chord_root]


processed = []
BPMS = {}
for music_file in analyzed:
    music_file = music_file.strip()
    base_name = os.path.basename(music_file)
    bpm = open(os.path.join(process_dir, base_name + ".bpm")).read().strip()
    chords = open(os.path.join(process_dir, base_name + ".chords")).readlines()

    print base_name

    random.seed(SEED)
    all_chords = {}
    for chord in chords:
        chord_name = chord.strip().split(",")[1]
        all_chords[chord_name] = True

    for chord in all_chords:
        get_fill_color(chord)
        

    bpm = float(bpm)
    if bpm > 150:
        bpm /= 2
    if bpm < 50:
        bpm *= 2

    BPMS[music_file] = bpm

    parsed_chords = []
    for chord in chords:
        split = chord.strip().split(",")
        time = float(split[0])
        chord = split[1]
        parsed_chords.append((time, chord))

    # generate an SVG based on song data...
    # length of song is last element or so?

    last_chord = parsed_chords[-1]
    length = last_chord[0]

    height = 50
    dwg = svgwrite.Drawing(get_svg_file(music_file), profile='tiny')
    total = dwg.add(dwg.rect((0, 0), (length, height)))

    prev_chord = (0, 0)
    for chord in parsed_chords:
        fill_color = get_fill_color(chord[1])


        start = prev_chord[0]
        end = chord[0] - prev_chord[0]
        factor = 4
        start *= factor
        end *= factor
        rect = dwg.add(dwg.rect((start, 0), (end, height), fill=fill_color, stroke_opacity="0"))
        rect.set_desc(title=chord[1])

        prev_chord = chord
        

    dwg.save()
    processed.append(music_file)


h = html.HTML('html')


style_str = "<style>\n"
style_str += ".song { float: left; width: 100%; height: 50px; margin-top: 50px; position: relative; }\n";
style_str += ".song .embed { width: 100%; height: 100%; }\n"
style_str += ".song .name { position: absolute; opacity: 0.5; bottom: 2em }\n"
style_str += ".song .bpm { position: absolute; opacity: 0.5; bottom: 2em; right: 0px }\n"
style_str += "</style>"

for music_file in processed:
    svg_file = os.path.basename(get_svg_file(music_file))

    div = h.div("", klass='song')
    title_str = "%s %.2f" % (os.path.basename(music_file), BPMS[music_file])
    div.p(title_str, klass='name')
    div.object("", data=svg_file , type="image/svg+xml", klass="embed")


all_songs = open(os.path.join(process_dir, "index.html"), "w")
all_songs.write(style_str)
all_songs.write(str(h))
all_songs.close()
