require 'spec_helper'

describe 'consul server' do
  describe service('consul') do
    it { should be_enabled }
    it { should be_running }
  end

  describe user('consul') do
    it { should exist }
    it { should belong_to_group 'consul' }
  end

  %w(/opt/consul /opt/consul/bin /opt/consul/data /etc/consul.d ).each do |dir|
    describe file(dir) do
      it { should be_directory }
      it { should be_owned_by('consul') }
    end
  end

  describe file('/etc/consul.conf') do
    it { should be_file }
    its (:content) { should match /"server": true/ }
  end

  describe file('/var/log/consul/consul-agent.log') do
    it { should be_file }
    it { should be_owned_by('consul') }
    its (:content) { should contain "New leader elected:" }
  end

end
