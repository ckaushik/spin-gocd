#!/bin/sh
# WHY? OH? WHY?
# - Serverspec only works on one host at a time. So we need to run rspec multiple times
# - For the life of me, I can't work out how to get Make to run a command once 
#   per spec file, without hard-coding each filename
# - Started on a Rakefile, it was just too heavy
# This still sucks. Stops running specfiles on the first failure.

set -eu

find $(dirname $0)/spec -type f -name '*_spec.rb' | while read specfile ; do
  bundle exec rspec ${specfile}
done
