require 'spec_helper'

describe 'superssh service (localport option)' do
  describe "definition by name" do
    describe command "curl -s http://127.0.0.1:8500/v1/catalog/service/superssh-different-name -v" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain '"ServiceName":"superssh-different-name"' }
        its(:stdout) { should contain '"ServiceTags":\["test"]' }
        its(:stdout) { should contain '"ServicePort":22' }
    end
  end

  describe "health is passing" do
    describe command "curl -s http://127.0.0.1:8500/v1/health/service/superssh-different-name -v" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain '"Service":"superssh-different-name"'}
        its(:stdout) { should contain '"Status":"passing"'}
    end
  end

  describe "definition by key should be empty" do
    describe command "curl -s http://127.0.0.1:8500/v1/catalog/service/superssh -v" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match '[]' }
    end
  end

  describe "localport 2222 is open by haproxy" do
    describe port(2222) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  describe "ssh is working on 2222" do
    describe command "echo X | nc -v  127.0.0.1 2222 2>&1 | grep SSH" do
      its(:exit_status) { should eq 0 }
    end
  end
end

describe 'superdb service (A failing service)' do
  describe "definition" do
    describe command "curl -s http://127.0.0.1:8500/v1/catalog/service/superdb -v" do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"ServiceName":"superdb"' }
      its(:stdout) { should contain '"ServiceTags":\["userdb","v1.2"]' }
      its(:stdout) { should contain '"ServicePort":2122' }
    end
  end

  describe "health is failing" do
    describe command "curl -s http://127.0.0.1:8500/v1/health/service/superdb -v" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain '"Service":"superdb"' }
        its(:stdout) { should contain '"Status":"(warning|critical)"' }
    end
  end

  describe "localport 2122 is open by haproxy" do
    describe port(2122) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end

end


describe 'superapp service (a non advertised service)' do

  describe "definition should not exist" do
    describe command "curl -s http://127.0.0.1:8500/v1/catalog/service/superapp -v" do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match '[]' }
    end
  end

  describe "localport 9999 is open by haproxy" do
    describe port(9999) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end

end

describe 'hellofresh service (normal port option)' do
  describe "definition" do
    describe command "curl -s http://127.0.0.1:8500/v1/catalog/service/hellofresh" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain '"ServiceName":"hellofresh"' }
        its(:stdout) { should contain '"ServiceAddress":"hellofresh.com"' }
        its(:stdout) { should contain '"ServicePort":80' }
    end
  end

  describe "health is passing" do
    describe command "curl -s http://127.0.0.1:8500/v1/health/service/hellofresh -v" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain '"Service":"hellofresh"'}
        its(:stdout) { should contain '"Status":"passing"' }
    end
  end

  describe "localport 80 is open by haproxy" do
    describe port(80) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  describe "HAProxy server backend should be on active" do
    describe command "echo 'show stat' | socat unix-connect:/var/haproxy/stats.sock stdio | grep hellofresh,hellofresh" do
      its(:exit_status) { should eq 0 }
    end
  end


  describe "curling to hellofresh is working on 80" do
    describe command "curl -I --resolve hellofresh.com:80:127.0.0.1 -H 'Host: hellofresh.com' http://hellofresh.com" do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain 'HTTP/1.1 301 Moved Permanently' }
    end
  end
end
