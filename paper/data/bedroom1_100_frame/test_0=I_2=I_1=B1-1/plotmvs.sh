#!/bin/bash

[[ ! "$1" ]] && {
  echo "Usage: $0 <motionfile>" >&2
  exit 1
}

MOTIONFILE="$1"
OUTFILE="`sed 's/motion/graph/g' <<< $MOTIONFILE | sed 's/\.mot/\.mvs\.pdf/g'`"
PLOTLINE=""

PDATA=`mktemp`
BDATA_L0=`mktemp`
BDATA_L1=`mktemp`

VIEW=`egrep -o '[[:digit:]]+' <<< "$MOTIONFILE"`
if [[ "`egrep 'constrained' <<< "$MOTIONFILE"`" ]]; then
  TITLE="Constrained View ${VIEW}"
else
  TITLE="Unconstrained View ${VIEW}"
fi
if [[ "`egrep 'fast' <<< "$MOTIONFILE"`" ]]; then
  TITLE+=" with Fast Search"
else
  TITLE+=" with Full Search"
fi

awk '
  /^[[:digit:]] +P.* 16x16/ {
    gsub(",", "\t", $6)
    printf("%s\n", $6);
  }

  /^[[:digit:]] +P.* 8x16/ {
    gsub(",", "\t", $6)
    gsub(",", "\t", $7)
    printf("%s\n%s\n", $6, $7);
  }

  /^[[:digit:]] +P.* 16x8/ {
    gsub(",", "\t", $6)
    gsub(",", "\t", $7)
    printf("%s\n%s\n", $6, $7);
  }

  /^[[:digit:]] +P.* 8x8/ {
    gsub(",", "\t", $6)
    gsub(",", "\t", $7)
    gsub(",", "\t", $8)
    gsub(",", "\t", $9)
    printf("%s\n%s\n%s\n%s\n", $6, $7, $8, $9);
  }
' < "$MOTIONFILE" | awk '/^[^0][^\t]*\t[^0]/ {print}' > "$PDATA"
[[ "`cat $PDATA`" ]] && {
  if [[ "$PLOTLINE" ]]; then PREFIX=","; else PREFIX="plot"; fi
  PLOTLINE+="$PREFIX \"$PDATA\" with points lt 3 pt 3 title \"P frames\""
}

awk '
  /^[[:digit:]] +B.* 16x16/ {
    gsub(",", "\t", $6)
    printf("%s\n", $6);
  }

  /^[[:digit:]] +B.* 8x16/ {
    gsub(",", "\t", $6)
    gsub(",", "\t", $7)
    printf("%s\n%s\n", $6, $7);
  }

  /^[[:digit:]] +B.* 16x8/ {
    gsub(",", "\t", $6)
    gsub(",", "\t", $7)
    printf("%s\n%s\n", $6, $7);
  }

  /^[[:digit:]] +B.* 8x8/ {
    gsub(",", "\t", $6)
    gsub(",", "\t", $7)
    gsub(",", "\t", $8)
    gsub(",", "\t", $9)
    printf("%s\n%s\n%s\n%s\n", $6, $7, $8, $9);
  }
' < "$MOTIONFILE" | awk '/^[^0][^\t]*\t[^0]/ {print}' > "$BDATA_L0"
[[ "`cat $BDATA_L0`" ]] && {
  if [[ "$PLOTLINE" ]]; then PREFIX=","; else PREFIX="plot"; fi
  PLOTLINE+="$PREFIX \"$BDATA_L0\" with points lt 4 pt 4 title \"B frames, list 0\""
}

awk '
  /^[[:digit:]] +B.* 16x16/ {
    gsub(",", "\t", $7)
    printf("%s\n", $7);
  }

  /^[[:digit:]] +B.* 8x16/ {
    gsub(",", "\t", $8)
    gsub(",", "\t", $9)
    printf("%s\n%s\n", $8, $9);
  }

  /^[[:digit:]] +B.* 16x8/ {
    gsub(",", "\t", $8)
    gsub(",", "\t", $9)
    printf("%s\n%s\n", $8, $9);
  }

  /^[[:digit:]] +B.* 8x8/ {
    gsub(",", "\t", $10)
    gsub(",", "\t", $11)
    gsub(",", "\t", $12)
    gsub(",", "\t", $13)
    printf("%s\n%s\n%s\n%s\n", $10, $11, $12, $13);
  }
' < "$MOTIONFILE" | awk '/^[^0][^\t]*\t[^0]/ {print}' > "$BDATA_L1"
[[ "`cat $BDATA_L1`" ]] && {
  if [[ "$PLOTLINE" ]]; then PREFIX=","; else PREFIX="plot"; fi
  PLOTLINE+="$PREFIX \"$BDATA_L1\" with points lt 1 pt 2 title \"B frames, list 1\""
}

[[ ! "`cat $PDATA $BDATA_L0 $BDATA_L1`" ]] && {
  echo "$0: No motion vectors in $MOTIONFILE. Skipping..." >&2
  exit 0
}

gnuplot << HERE
  set terminal pdfcairo size 4.5in,3.5in font 'serif,10'
  set output "$OUTFILE"
  set title "$TITLE"
  set grid
  set xrange [-300:300]
  set yrange [-300:300]
  set xlabel "<--- X --->"
  set ylabel "<--- Y --->"
  $PLOTLINE
  quit
HERE

rm $PDATA $BDATA_L0 $BDATA_L1
