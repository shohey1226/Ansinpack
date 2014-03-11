require 'serverspec'
require 'net/ssh'

include Serverspec::Helper::Ssh
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.host  = ENV['TARGET_HOST']
  options = Net::SSH::Config.for(c.host)
  #user    = options[:user] || Etc.getlogin
  user    = 'root' 
  options[:port] = ENV['TARGET_PORT']
  c.ssh   = Net::SSH.start(c.host, user, options)
  c.os    = backend.check_os
end

