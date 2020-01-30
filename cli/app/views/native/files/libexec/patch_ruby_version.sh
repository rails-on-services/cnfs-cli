#!/usr/bin/env bash

set -eEuo pipefail

. libexec/lib.sh

gemfile=$PLATFORM_PATH/Gemfile
version=$(echo $RUBY_VERSION | sed -e 's/^ruby-//')

if ! grep -q "ruby '$version'" $gemfile; then
  _sed -i $gemfile \
    -e "s/ruby '.*/ruby '$version'/"
fi
