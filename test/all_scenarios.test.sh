#! /usr/bin/env bash

source 'test/test_utils.sh'

# This test asserts the `power_events.input.log` is correctly translated 
# into the expected binary format.

# High threshold is used so all events are put in a single file
THRESHOLD='threshold=5000'
OUTPUT_DIR='output_directory=test/data/'

withInput 'test/data/power_events.input.log' 

mv 'test/data/events.0.bin' 'test/data/power_events.actual.bin'
assertBinaryMatch 'Power Events Binary' \
  'test/data/power_events.expected.bin' \
  'test/data/power_events.actual.bin'

mv 'test/data/run_events.sh' 'test/data/power_events.run_events.actual.sh'
assertMatch 'Power Events Coordinator Script' \
  'test/data/power_events.run_events.expected.sh' \
  'test/data/power_events.run_events.actual.sh'


withInput 'test/data/drawing_events.input.log' 

mv 'test/data/events.0.bin' 'test/data/drawing_events.actual.bin'
assertBinaryMatch 'Drawing Events Binary' \
  'test/data/drawing_events.expected.bin' \
  'test/data/drawing_events.actual.bin'

mv 'test/data/run_events.sh' 'test/data/drawing_events.run_events.actual.sh'
assertMatch 'Drawing Events Coordinator Script' \
  'test/data/drawing_events.run_events.expected.sh' \
  'test/data/drawing_events.run_events.actual.sh'
