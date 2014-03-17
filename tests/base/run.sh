#!/bin/bash

rake SPEC_OPTS="--require ../lib/junit.rb --format JUnit --out ../../results.xml" spec
