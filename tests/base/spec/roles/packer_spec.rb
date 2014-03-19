require 'spec_helper'

describe file('/usr/local/bin/packer') do
    it { should be_file }
end

describe file('/usr/bin/docker') do
    it { should be_file }
end

describe file('/usr/bin/ansible-playbook') do
    it { should be_file }
end

describe command('/usr/bin/openssl version') do
    it { should return_stdout 'OpenSSL 1.0.1e-fips 11 Feb 2013' }
end

