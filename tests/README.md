## Command 

	SERVER_TYPE=webapp TARGET_HOST=128.199.228.10 rake spec
	SERVER_TYPE=webapp TARGET_HOST=128.199.228.10 rake SPEC_OPTS="--require ./junit.rb --format JUnit --out results.xml" spec
