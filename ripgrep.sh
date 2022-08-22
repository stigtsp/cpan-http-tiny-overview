#!/bin/sh
set -ex
rg -g "!*.t" -f constructor.patterns --sort path --json --type perl  ./metacpan-cpan-extracted/ > constructor.rg.json
rg -g "!*.t" -f verify_SSL.patterns  --sort path --json --type perl  ./metacpan-cpan-extracted/ > verify_SSL.rg.json
