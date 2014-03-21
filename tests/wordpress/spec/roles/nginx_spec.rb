require 'spec_helper'

describe package('nginx') do
  it { should be_installed }
end

#describe command('/usr/bin/openssl version') do
#    it { should return_stdout 'OpenSSL 1.0.1e-fips 11 Feb 2013' }
#end

