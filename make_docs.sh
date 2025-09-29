#!/bin/bash -ve

cd /home/san/prog/ocaml/gl-legacy/dune-version
dune build @doc
rsync -avz --delete _build/default/_doc/_html/gl-legacy/Gl_legacy/ docs
for file in "docs/index.html" "docs/List_type/index.html" "docs/Feedback/index.html"
do
  sed -i "s|../../||g" $file
  sed -i "s|<span>&#45;&gt;</span>|<span class=\"arrow\">→</span>|g" $file
done

sed -i "s| (gl-legacy.Gl_legacy)||g" docs/index.html
cp -r ./_build/default/_doc/_html/odoc.support docs/
chmod 644 docs/odoc.support/odoc.css
sed -i "s|max-width: 132ex;|max-width: 180ex;|g" docs/odoc.support/odoc.css

echo "Done"
