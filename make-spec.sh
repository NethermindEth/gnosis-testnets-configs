#!/bin/bash

set -eux

DIR=$1 # first argument should be output directory

(cd ./posdao-contracts && npm install)                                 # install posdao-contracts dependencies
cp ."/$DIR/template.json" "./posdao-contracts/templates/spec.json"     # copy to posdao-contracts template folder
source "$DIR/spec.env" && node ./posdao-contracts/scripts/make_spec.js # generate spec
cp "./posdao-contracts/spec.json" "./$DIR/spec.json"                   # copy generated spec to network folder
(cd ./posdao-contracts && git restore .)                               # restore modifies files in posdao-contracts (probably only spec template)
