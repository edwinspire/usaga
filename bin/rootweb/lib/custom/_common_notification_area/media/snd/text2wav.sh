#!/bin/bash
less text | iconv -f utf-8 -t iso-8859-1 | text2wave -eval "(Parameter.set
'Duration_Stretch 1)" -scale 5.0  -o  audiotext.wav

