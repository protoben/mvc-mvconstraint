#!/bin/bash

[[ ! "$1" ]] && {
  echo "Usage: $0 <datfile>" > /dev/stderr
    exit 1
}

DATFILE="$1"
BITMPFILE="`mktemp`"
UNITMPFILE="`mktemp`"
IRATE="`awk '
BEGIN {
  i_rate = 0;
  count = 0;
}
/^I/ {
  i_rate += $5;
  ++count;
}
END {
  if(count == 0)
    print(0)
  else
    printf("%.02f\n", i_rate/count);
}
' "$DATFILE"`"

awk -v i_rate=$IRATE '
BEGIN {
  ntypes = 0;
}
/^P/ {
  type = $1;
  rate = $5;
  sub("P", "", type);
  if(rates[type] == 0) {
    types[ntypes++] = type;
    rates[type] = rate;
  } else {
    rates[type] = (rates[type] + rate) / 2;
  }
}
END {
  for(i = 0; i < ntypes; ++i)
    printf("%d\t%.02f\t%s\n", i, (rates[types[i]]/i_rate)*100, types[i]);
}
' "$DATFILE" > "$UNITMPFILE"

awk -v i_rate=$IRATE '
BEGIN {
  ntypes = 0;
}
/^B/ {
  type = $1;
  rate = $5;
  sub("B", "", type);
  if(rates[type] == 0) {
    types[ntypes++] = type;
    rates[type] = rate;
  } else {
    rates[type] = (rates[type] + rate) / 2;
  }
}
END {
  for(i = 0; i < ntypes; ++i)
    printf("%d\t%.02f\t%s\n", i, (rates[types[i]]/i_rate)*100, types[i]);
}
' "$DATFILE" > "$BITMPFILE"

[[ "`cat $UNITMPFILE`" ]] &&
gnuplot << END
unset key
set terminal pdfcairo size 3.5in,2.4in font 'serif,10'
set output "${DATFILE%.dat}_unidirectional.pdf"
set title "Bitrates by distance from reference view\nUnidirectional references"
set xlabel "Reference view distance"
set yrange [0:200]
set arrow from graph 0,first 100 to graph 1,first 100 nohead lc rgb "#000000" front
set ylabel "Bitrate\n% of avg. independent view"
set grid
set style fill solid
plot "$UNITMPFILE" using 1:2:(0.60):xtic(3) with boxes,\
               "" using 0:(\$2+10):2 with labels font ",7"
END

[[ "`cat $BITMPFILE`" ]] &&
gnuplot << END
unset key
set terminal pdfcairo size 5in,2.4in font 'serif,10'
set output "${DATFILE%.dat}_bidirectional.pdf"
set title "Bitrates by distance from reference view\nBidirectional references"
set xlabel "Reference view distances"
set yrange [0:150]
set arrow from graph 0,first 100 to graph 1,first 100 nohead lc rgb "#000000" front
set ylabel "Bitrate\n% of avg. independent view"
set grid
set style fill solid
plot "$BITMPFILE" using 1:2:(0.60):xtic(3) with boxes,\
               "" using 0:(\$2+10):2 with labels font ",7"
END

rm "$BITMPFILE"
rm "$UNITMPFILE"
