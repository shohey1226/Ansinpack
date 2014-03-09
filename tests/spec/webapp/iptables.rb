require 'spec_helper'

describe iptables do
  it { should have_rule('-P INPUT ACCEPT') }
  it { should have_rule('-P FORWARD ACCEPT') }
  it { should have_rule('-P OUTPUT ACCEPT') }
  it { should have_rule('-A INPUT -p icmp -j ACCEPT') }
  it { should have_rule('-A INPUT -i lo -j ACCEPT') }
  it { should have_rule('-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT') }
  it { should have_rule('-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT') }
  it { should have_rule('-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT') }
  it { should have_rule('-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT') }
  it { should have_rule('-A INPUT -p tcp -m state --state NEW -m tcp --dport 25 -j ACCEPT') }
  it { should have_rule('-A INPUT -p tcp -m state --state NEW -m tcp --dport 587 -j ACCEPT') }
  it { should have_rule('-A INPUT -j REJECT --reject-with icmp-host-prohibited') }
  it { should have_rule('-A FORWARD -j REJECT --reject-with icmp-host-prohibited') }
end
