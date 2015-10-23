Experiments
===========

In this section, we present the results of our experiments. First we describe
our experimental method &mdash; the software we modified for our tests and how
we modified it. Next we step through our reasoning for constraining the frames
we chose to constrain, along with the results of our experiments. Finally, we
draw some conclusions about what method of constraint worked best in our
experiments and quantify the benefits of our proposed system.

Modifying JMVC
--------------

JMVC [\[1\]][schwarz10] is a fork of JM [\[2\]][suehring15], the H.264 reference
coder. It implements the H.264 multiview extensions. This was the software we
chose to modify for our tests to record per-macroblock motion vector information
as they were being coded.

Standard H.264 P- and B-frames allow motion information to be encoded with
reference to frames that come temporally before and after the current frame.
Multiview extensions add to this the idea of a view and allow motion information
to be coded with respect to temporally concurrent frames in different views as
well. These are refered to, respectively, as *inter* frames and *inter-view*
frames. Motion information is encoded as vector offsets from a block in the
dependent view to a similar block in the reference view, along with a residual
that records the difference between the two.

JMVC provides two methods of searching a reference frame for motion vector
search: *block search*, which tries every block of appropriate size in a region
around the block being predicted for, and *TZ-search*, which uses a combination
of scaled-down raster search and diamond refinement. [\[3\]][purnachand12]
Once a motion vector has been found that surpasses some threshold, it is coded
and written to file. Our modification writes the information for the chosen
motion vectors (if any) for the current macroblock to file in human-readable
form immediately before this step.

An ancillary benefit to this was that we could closely examine the motion
vectors the unmodified JMVC produced. This permitted us to identify what
appears to be a bug in the original JMVC implementation.

Before searching for motion vectors, JMVC decides on how to constrain the search
area based on a predefined search range, further restricted by the boundaries of
the frame. The logic that determined where the boundaries of the frame lay with
respect to the current macroblock was incorrect, which led the software to
search for and sometimes choose motion vectors outside of the boundaries of the
frame. In the worst case, this meant overflowing the boundaries of the array
that represented the current picture. We modified this logic to accurately
constrain the search to within frame boundaries.

Experimental Method
-------------------


[schwarz10]: references.md#schwarz10
[suehring15]: references.md#suehring15
[purnachand12]: references.md#purnachand12
