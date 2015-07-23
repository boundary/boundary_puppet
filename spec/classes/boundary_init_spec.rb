require 'spec_helper'
require 'rspec-puppet'

describe 'boundary', :type => 'class' do

  context "On Debian OS with no package name specified" do
    let :facts do
      {
          :osfamily => 'Debian',
          :lsbdistid => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'jessie'
      }
    end
    let(:params) { {:token => 'api-123456',} }

    it 'should compile' do should create_class('boundary') end
    it { should contain_class('boundary::dependencies') }

    it { should contain_service('boundary-meter').with(
                    'ensure' => 'running',
                    'enable' => true,
                    'hasstatus' => false,
                )
    }

  end

  context "On Ubuntu 12.04 with no package name specified" do
    let :facts do
      {
          :osfamily => 'Debian',
          :lsbdistid => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'precise'
      }
    end
    let(:params) { {:token => 'api-123456',} }

    it 'should compile' do should create_class('boundary') end
    it { should contain_class('boundary::dependencies') }

    it { should contain_service('boundary-meter').with(
                    'ensure' => 'running',
                    'enable' => true,
                    'hasstatus' => false,
                )
    }

  end

  context "On Ubuntu 14.04 with no package name specified" do
    let :facts do
      {
          :osfamily => 'Debian',
          :lsbdistid => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'trusty'
      }
    end
    let(:params) { {:token => 'api-123456',} }

    it 'should compile' do should create_class('boundary') end
    it { should contain_class('boundary::dependencies') }

    it { should contain_service('boundary-meter').with(
                    'ensure' => 'running',
                    'enable' => true,
                    'hasstatus' => false,
                )
    }

  end

  context "On RHEL OS with no package name specified" do
    let :facts do
      {
          :osfamily => 'RedHat',
          :lsbdistid => 'RedHat',
          :operatingsystem => 'RedHat',
          :operatingsystemrelease => 7,
          :architecture => 'x86_64'
      }
    end
    let(:params) { {:token => 'api-123456',} }

    it 'should compile' do should create_class('boundary') end
    it { should contain_class('boundary::dependencies') }

    it { should contain_service('boundary-meter').with(
                    'ensure' => 'running',
                    'enable' => true,
                    'hasstatus' => false,
                )
    }

  end

  context "On CentOS with no package name specified" do
    let :facts do
      {
          :osfamily => 'CentOS',
          :lsbdistid => 'CentOS',
          :operatingsystem => 'CentOS',
          :operatingsystemrelease => 7,
          :architecture => 'x86_64'
      }
    end
    let(:params) { {:token => 'api-123456',} }
    let(:fqdn) { 'testhost.example.com' }

    it 'should compile' do should create_class('boundary') end
    it { should contain_class('boundary::dependencies') }

    it { should contain_service('boundary-meter').with(
                    'ensure' => 'running',
                    'enable' => true,
                    'hasstatus' => false,
                )
    }

  end

end