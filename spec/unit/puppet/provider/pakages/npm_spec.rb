#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:package).provider(:npm) do
  before :each do
    @provider.class.stubs(:optional_commands).with(:npm).returns "/usr/local/bin/npm"
    @resource =  Puppet::Type.type(:package).new(
      :name   => 'express',
      :ensure => :present
    )
    @provider = described_class.new(@resource)
  end

  def self.it_should_respond_to(*actions)
    actions.each do |action|
      it "should respond to :#{action}" do
        @provider.should respond_to(action)
      end
    end
  end

  it_should_respond_to :install, :uninstall, :update, :query, :latest

  describe "when installing npm packages" do
    it "should use package name by default" do
      @provider.expects(:npm).with('install', '--global', 'express')
      @provider.install
    end

    describe "and a source is specified" do
      it "should use the source instead of the gem name" do
        @resource[:source] = "/tmp/express.tar.gz"
        @provider.expects(:npm).with('install', '--global', '/tmp/express.tar.gz')
        @provider.install
      end
    end
  end

  describe "when npm packages are installed globally" do
    it "should return a list of npm packages installed globally" do
      @provider.class.stubs(:npm).with('list', '--json', '--global').returns(my_fixture_read('npm_global'))
      @provider.class.instances.map {|p| p.properties}.should == [
        {:ensure => '1.1.15', :provider => 'npm', :name => 'npm'    },
        {:ensure => '2.5.9' , :provider => 'npm', :name => 'express' },
      ]
    end
  end

#  describe "when no npm packages are installed globally" do
#    it "should return nothing is installed" do
#      @provider.class.stubs(:npm).with('list', '--json', '--global').returns("{}\n")
#      @provider.class.instances.should == []
#    end
#  end
end
