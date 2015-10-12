Storyboard
==========

1. Examining the motion vectors in an MVC stream
  - *Inter* predicted vectors versus *inter-view* predicted vectors
  - Some graphs showing where both show up in unmodified JMVC (?)
  - Why horizontal motion vectors make sense for *inter-view* slices
    + Views are horizontally correlated
  - Why they aren't always used
    + Encoder stops when MV is "good enough"
    + Occlusions (?)
  - Out-of-frame bug in unmodified JMVC
2. Constraining motion vectors in all slice types
  - Speedup versus increased bitrate (graphs?)
  - Graphs of constrained motion vectors (?)
  - Why this is a bad idea
    + Temporally separated pictures aren't horizontally correlated
3. Constraining only inter-view frames
  - Speed-up and practically no change in bitrate
  - With single view dependency (P-frames)
    + E.g. sending just 2 views for stereoscopic video
    + About twice as fast with minimal (+/-1%) bitrate change
  - With multi-view dependency
    + E.g. sending more than 2 views for variable-view video
    + About 5-times speedup with minimal (+/-1%) bitrate change
  - Possible configurations
    + All frames *inter-view*
    + Interspersed *inter* and *inter-view*
    + Bitrate differences
      * [I think *inter-view* frames are slightly larger, but I should do tests]
    + B-frames with both *inter* and *inter-view* references
      * [This seems common in the lit. I should do tests if JMVC can do it.]
  - Histagrams with speed and bitrate
4. Conclusions
  - Constraining works well with 1 reference, better with more
  - Can only make *inter-view* prediction faster
    + Tradeoff:
      * More *inter-view* frames means faster MV search with constraint
      * More *inter* frames means lower bitrate
