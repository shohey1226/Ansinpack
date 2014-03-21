require 'spec_helper'

describe file('/usr/bin/ansible-playbook') do
    it { should be_file }
end
