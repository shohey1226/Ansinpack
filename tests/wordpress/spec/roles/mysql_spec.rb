require 'spec_helper'

describe package('mysql-server') do
  it { should be_installed }
end

describe package('mysql') do
  it { should be_installed }
end

describe process("mysqld") do
  it { should be_running }
  it { should be_enabled }
end

describe service('mysqld') do
  it { should be_enabled }
end

#describe command('/usr/bin/openssl version') do
#    it { should return_stdout 'OpenSSL 1.0.1e-fips 11 Feb 2013' }
#end

