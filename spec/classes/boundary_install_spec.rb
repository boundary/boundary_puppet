require 'spec_helper'
require 'rspec-puppet'

describe 'boundary::install', :type => 'class' do

  context "On Debian OS with no package name specified" do
    let :facts do
      {
          :osfamily => 'Debian',
          :lsbdistid => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'jessie'
      }
    end

    it 'should compile' do should create_class('boundary::install') end

    it { should contain_package('boundary-meter').with(
                    'ensure' => 'present',
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

    it 'should compile' do should create_class('boundary::install') end

    it { should contain_package('boundary-meter').with(
                    'ensure' => 'present',
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

    it 'should compile' do should create_class('boundary::install') end

    it { should contain_package('boundary-meter').with(
                    'ensure' => 'present',
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

    it 'should compile' do should create_class('boundary::install') end

    it { should contain_package('boundary-meter').with(
                    'ensure' => 'present',
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

    it 'should compile' do should create_class('boundary::install') end

    it { should contain_package('boundary-meter').with(
                    'ensure' => 'present',
                )
    }

  end

end