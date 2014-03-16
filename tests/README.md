## Command 

    SERVER_TYPE=webapp TARGET_HOST=172.17.42.1 TARGET_PORT=49163 rake spec
	#SERVER_TYPE=webapp TARGET_HOST=128.199.228.10 rake spec
	SERVER_TYPE=webapp TARGET_HOST=128.199.228.10 TARGET_PORT=22 rake SPEC_OPTS="--require ./junit.rb --format JUnit --out results.xml" spec
    TARGET_HOST=localhost TARGET_PORT=2222 rake spec
