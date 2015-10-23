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
chose to modify for our tests.

We first modified JMVC to record per-macroblock motion vector information as the
macroblocks were coded.

[schwarz10]: references.md#schwarz10
[suehring15]: references.md#suehring15
