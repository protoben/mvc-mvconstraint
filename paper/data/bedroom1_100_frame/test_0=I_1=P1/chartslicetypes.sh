#!/bin/bash

[[ ! "$1" ]] && {
  echo "Usage: $0 <logfile>" >&2
  exit 1
}

LOGFILE="$1"
OUTFILE="`sed 's/log/graph/;s/log/chart/' <<< $LOGFILE | sed 's/\.txt/\.bitrates\.csv/g'`"

DATA=`mktemp`

awk 'BEGIN {FS="########"; RS="QQQQQQ";} {print($NF);}' "$LOGFILE" > "$DATA"

echo -e "type\tcnt \ty psnr  \tu psnr  \tv psnr  \tavg bits\tsecs" > "$OUTFILE"
for slice_type in I P B; do
  awk --posix "
    BEGIN {
      ypsnr = 0;
      upsnr = 0;
      vpsnr = 0;
      bits = 0;
      secs = 0;
      nframes = 0;
    }

    /^[ 0-9]{4} $slice_type/ {
      ++nframes;

      for(i = 1; i < NF; ++i) {
        if(\$i == \"Y\")
          ypsnr += \$(i + 1);
        else if(\$i == \"U\")
          upsnr += \$(i + 1);
        else if(\$i == \"V\")
          vpsnr += \$(i + 1);
        else if(\$i == \"bits\")
          bits += \$(i + 1);
        else if(\$i == \"secs\")
          secs += \$(i + 1);
      }
    }

    END {
      if(nframes != 0) {
        ypsnr /= nframes;
        upsnr /= nframes;
        vpsnr /= nframes;
        bits /= nframes;
        secs /= nframes;
      }

      printf(\"%4s\\t%-4d\\t%-2.6f\\t%-2.6f\\t%-2.6f\\t%-8f\\t%-4.9f\\n\" \
             , \"$slice_type\" \
             , nframes \
             , ypsnr \
             , upsnr \
             , vpsnr \
             , bits \
             , secs);
    }
  "  "$DATA" >> "$OUTFILE"
done

rm "$DATA"
