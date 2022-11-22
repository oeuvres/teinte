#!/bin/sed -E -f
# Chained substitutions on a TEI generated from WordProcessor mess
# should work as a sed script in unicode (on one line, no dotall option)
# those regexp will be interpreted in PHP, Java, may be Python
# default MacOSX sed is not perl compatible, there is no support for backreference in search “\1”, and assertions (?…)
# frederic.glorieux@fictif.org

# linked inlines
s@</(i|ref|title)><\1>@@g
s@</(i|ref|title)><\1>@@g
# initial space
s@(<(note|p)( [^>]+)?>) +@$1@g
# note, editor
s@(<note[^>]*)>\[?nde\]? *@$1 resp="editor">@gi
# note, author
s@(<note[^>]*)>\[?nda\]? *@$1 resp="author">@gi

