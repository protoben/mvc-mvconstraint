Experiments
===========

In this section, we present the results of our experiments. First we describe
our experimental method &mdash; the software we modified for our tests and how
we modified it. Next we step through our reasoning for constraining the frames
we chose to constrain, along with the results of our experiments. Finally, we
draw some conclusions about what method of constraint worked best in our
experiments and quantify the benefits of our proposed system.

JMVC
----

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

Once we were able to inspect the motion information JMVC produced, we began
running tests to determine what motion vectors it was finding for inter
predicted and inter-view predicted pictures, respectively. In order to eliminate
the noise that might arise from running tests on multiview footage from real
cameras (the cameras might not be placed on a perfectly horizontal plane, for
example), we ran our tests on a suite of 3d-rendered multiview videos.

We further modified JMVC's search constraints so that we could selectively
constrain the vertical component of the motion-vector search on some or all
frames. We then tested the speed and rate-distortion efficiency &mdash; with and
without vertical constraint &mdash; of three different view-dependency
configurations.

JMVC uses variable-bitrate encoding, so to quantify rate-distortion efficiency,
it sufficed to record the bitrate of each frame and view. To record timing
information, we used Linux's `time` utility to record the time each view took
to encode. We additionally modified JMVC to record the time each frame took to
encode using `clock_gettime()` with Linux's `CLOCK_MONOTONIC`.

All our tests were run on [insert zodiac cluster hardware info here].

View Dependencies
-----------------

For all of our reference views we used an intra-period of 4 with P-frames
halfway between each pair of I-frames (i.e., a frame structure of
`IBPBIBPB...`). We used a three different configurations for the dependent
view, however.

The standard allows frames in a dependent view to refer to concurrent frames
from up to two other views or previous/subsequent frames within the same view
for motion information. The most common configuration in the literature is shown
in figure (a). In this configuration, each frame of a dependent view is coded
with respect to the same numbered frame in the reference view, and each frame
but the first is additionally uses inter prediction from the same view. In the
remainder of this paper, we will refer to this as configuration A.

We also tested a simpler scheme in which each frame of the dependent view uses
only inter-view prediction from either one or two reference frames. This
corresponds to figures (b) and (c). For the rest of this paper, these will be
refered to as configurations B and C, respectively.

<span align=center>
[insert figure a: 2 views (0->1), with inter prediction on view 1]
</span>

<span align=center>
[insert figure b: 2 views (0->1), with no inter prediction on view 1]
</span>

<span align=center>
[insert figure c: 3 views (0->1<-2), with no inter prediction on view 1]
</span>

Without Vertical Constraint
---------------------------



[schwarz10]: references.md#schwarz10
[suehring15]: references.md#suehring15
[purnachand12]: references.md#purnachand12
