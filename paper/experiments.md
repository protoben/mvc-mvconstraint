Experiments
===========

In this section, we present the results of our experiments. First we describe
our experimental method, including the software we modified for our tests and
how we modified it. Next we step through our reasoning for constraining the
frames we chose to constrain, along with the results of our experiments.
Finally, we draw some conclusions about what method of constraint works best
and quantify the benefits of our proposed system.

JMVC
----

JMVC [\[1\]][schwarz10] is a fork of JM [\[2\]][suehring15], the H.264 reference
codec. It implements the H.264 multiview extensions. This was the software we
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

JMVC provides two methods of motion vector search: *block search*, which tests
every block in a region around the block being predicted for, and *TZ-search*,
which uses a combination of scaled-down raster search and diamond
refinement. [\[3\]][purnachand12] We ran tests using both algorithms, but we
will focus on our results using TZ-search, since this most closely matches the
way the codec would be used in practice.

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
predicted and inter-view predicted pictures. In order to eliminate the noise
that might arise from running tests on multiview footage from real cameras (the
cameras might not be placed on a perfectly horizontal plane, for example), we
ran our tests on a suite of 3d-rendered multiview videos. These were designed to
simulate the ideal case for stereoscopic video, in which views are separated
horizontally, but lie in the same horizontal plane. In this paper we show the
results of our tests on two 8-view videos, one of a helicopter landing, and the
other of a camera panning around a bedroom.

<span align="center">
[insert frames from each of the videos tested]
</span>

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
`IBPBIBPB...`). We used three different configurations for the dependent
view, however.

The standard allows frames in a dependent view to refer to concurrent frames
from up to two other views or previous/subsequent frames within the same view
for motion information. The most common configuration in the literature is shown
in figure (a). In this configuration, each frame of a dependent view is coded
with respect to the same numbered frame in the reference view, and each frame
but the first is additionally uses inter prediction from the same
view. [\[4\]][vetro11] Unfortunately, JMVC does not support using both inter
and inter-view prediction within the same frame.

Our experiments used two configurations, one with two views and the other with
eight. These correspond to to figures (a) and (b), respectively. For the
remainder of this paper, these will be refered to as configurations A and B.

Configuration A represents the simple case of two-view stereoscopic video. View
0 is independent, while each frame in view 1 is inter-view coded with reference
to the temporally corresponding frame in view 0.

Configuration B has a more complex, eight view configuration. Views 2 and 5 are
independent, using only inter prediction. The remaining views are coded with
reference to the two independent views.

<span align=center>
[insert figure a: 2 views (0->1), with no inter prediction on view 1]
</span>

<span align=center>
[insert figure b: 8 views, with no inter prediction on views 0, 1, 3, 4, 6, and 7]
</span>

Without Vertical Constraint
---------------------------

For each configuration, we ran tests with JMVC's stock configuration and
examined the motion vectors it produced. Figures (c) and (d) show the
distribution of motion vectors for each view in the respective configurations.
Each point corresponds to the offset of the reference block with respect to
the block being predicted for.

In the inter-coded views, reference blocks are mostly near the original
block. The motion vectors mostly show incremental horizontal or vertical
movement. This suggests that the TZ-search does a good job of finding
appropriate motion vectors for inter-coded blocks.

On the other hand, in the inter-view coded frames, reference blocks are
scattered across the search area. A large proportion of them show primarily
horizontal dislocation from the origin, which is what you would expect, given
that the views are all located within the same horizontal plane, but many of
the motion vectors seem scattered at random. In this case, TZ-search seems to
be doing a poor job of finding the appropriate motion vectors.

In the inter-view coded frames, 

<span align=center>
[insert figure c: unconstrained mv graphs for conf. a, bedroom1 and helicopter]
</span>

<span align=center>
[insert figure c: unconstrained mv graphs for conf. b, bedroom1 and helicopter]
</span>

Vertically Constraining All Frames
----------------------------------

Selective Vertical Constraints
------------------------------

Conclusion
----------

[schwarz10]: references.md#schwarz10
[suehring15]: references.md#suehring15
[purnachand12]: references.md#purnachand12
