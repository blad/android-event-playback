#! /usr/bin/env bash

function assertBinaryMatch {
  local LABEL=$1
  local EXPECTED=$2
  local ACTUAL=$3
  local RESULT=$(diff <(cat $EXPECTED | xxd) <(cat $ACTUAL | xxd) | head)

  if [[ -z "${RESULT}" ]]; then
    echo "${LABEL}: Success!"
  else 
    echo "${LABEL}: Failed!"
    echo "Error: ${RESULT}"
  fi
  echo ""
}

function assertMatch {
  local LABEL=$1
  local EXPECTED=$2
  local ACTUAL=$3
  local RESULT=$(diff $EXPECTED $ACTUAL)

  if [[ -z "${RESULT}" ]]; then
    echo "${LABEL}: Success!"
  else 
    echo "${LABEL}: Failed!"
    echo "Error: ${RESULT}"
  fi
  echo ""
}

function withInput {
  local INPUT=$1
  cat "${INPUT}" | \
    awk --non-decimal-data \
    -v "${THRESHOLD}" \
    -v "${OUTPUT_DIR}" \
    -f process_event_log.awk
}
