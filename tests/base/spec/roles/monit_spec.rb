require 'spec_helper'

describe package('monit') do
  it { should be_installed }
end
