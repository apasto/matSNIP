#!/usr/bin/env bash
# update readme and contents function with the 2nd row of every function in SNIP

TEMPLATEdir="./readme_template/"
READMEhead="${TEMPLATEdir}readme_head.md"
READMEfoot="${TEMPLATEdir}readme_foot.md"
README="README.md"
CONTENTShead="${TEMPLATEdir}contents_head"
CONTENTSfoot="${TEMPLATEdir}contents_foot"
CONTENTS="./+SNIP/DispContents.m"

FUNClist="$(head -n2 +SNIP/*.m | sed -ne'n;n;p;n' | sed 's/ /** /' | sed 's/%/- **/')"

# text of FUNClist with literal \n newlines
FUNClistN=$(echo "$FUNClist" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')

echo "Updating README and contents function with:"
echo "$FUNClist"

# README
{ cat "$READMEhead";
  echo "$FUNClist";
  cat "$READMEfoot"
  } > "$README"

# contents.m
{ cat "$CONTENTShead"
  echo -n "Contents_text = \"";
  echo -n "$FUNClistN";
  echo "\";";
  cat "$CONTENTSfoot"
  } > "$CONTENTS"

echo "DONE."
