#!/usr/bin/env bash
# Waits for network connectivity. Source this from other scripts.
# Usage: source network-wait.sh && wait_for_network [max_attempts]

wait_for_network() {
  local max_attempts="${1:-5}"
  local attempt=0
  
  while (( attempt < max_attempts )); do
    # Check if we can reach a reliable endpoint
    if curl -sf --max-time 2 "http://1.1.1.1" >/dev/null 2>&1 || \
       ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; then
      return 0
    fi
    (( attempt++ ))
    sleep 2
  done
  return 1
}
