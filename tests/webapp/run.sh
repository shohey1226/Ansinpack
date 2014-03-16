#!/bin/bash

TARGET_HOST=localhost TARGET_PORT=2222 rake SPEC_OPTS="--require ../lib/junit.rb --format JUnit --out /tmp/results.xml" spec
