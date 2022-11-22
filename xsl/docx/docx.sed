#!/bin/sed -E -f
# Chained substitutions on a TEI generated from WordProcessor mess
# should work as a sed script in unicode (on one line, no dotall option)
# those regexp will be interpreted in PHP, Java, may be Python
# default MacOSX sed is not perl compatible, there is no support for backreference in search “\1”, and assertions (?…)
# frederic.glorieux@fictif.org

# linked inlines
s@</(i|ref|title)><\1>@@g
s@</(i|ref|title)><\1>@@g
# inline without chars
s@<(bg_[^> ]+|color_[^> ]+|mark_[^> ]+|font_[^> ]+|author|b|code|em|emph|foreign|hi|i|num|phr|s|sc|seg|strong|surname|tech|title|u)( [^>]+)?>([ : \‑\.\(\),\]\[’“”«»]*)</\1>@\3@g
# <i>attitude. </i>
# exit some punctuation from inline tags !! &amp;
s@\s*( ;)</(b|emph|foreign|em|hi|i|phr|strong|seg|tech|title|u)>@</\2>\1@g
s@([  \-\,:!\?\.]+)</(author|b|em|emph|foreign|hi|i|phr|strong|seg|tech|title|u)>@</\2>\1@g
# centuries <sc>xii</sc><sup>e</sup>

# initial space in blocks
s@(<(note|p)( [^>]+)?>) +@$1@g
# note, editor
s@(<note[^>]*)>\[?nde\]? *@$1 resp="editor">@gi
# note, author
s@(<note[^>]*)>\[?nda\]? *@$1 resp="author">@gi

