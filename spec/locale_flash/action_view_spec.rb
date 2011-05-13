require 'spec_helper'
require 'support/templates'

describe ActionView::Base do
  before(:each) do
    @template = UsersTemplate.new
  end

  describe '#locale_flash' do
    context "when flash is empty" do
      it "returns an empty string" do
        @template.flash = {}
        @template.locale_flash.should == ''
      end
    end

    context "when flash is a string" do
      it "returns an html flash" do
        @template.flash = {:notice => 'This is a string'}
        @template.locale_flash.should == %Q{<div class="notice">This is a string</div>}
      end  

      it "returns multiple html flashes" do
        @template.flash = {:notice => 'This is a string', :alert => 'This is another string'}
        html = @template.locale_flash
        html.should include(%Q{<div class="notice">This is a string</div>})
        html.should include(%Q{<div class="alert">This is another string</div>})
      end
    end

    context "when flash is a hash containg controller and action keys" do
      it "returns the flash for the controller and action" do
        @template.flash = {:notice => {:controller => 'users', :action => 'create'}}
        @template.locale_flash.should == %Q{<div class="notice">Found in controllers.users.create.flash.notice</div>}
      end

      it "returns the flash falling back to the controller flash" do
        @template.flash = {:notice => {:controller => 'users', :action => 'update'}}
        @template.locale_flash.should == %Q{<div class="notice">Found in controllers.users.flash.notice</div>}
      end

      it "returns the flash falling back to the action flash" do
        @template.flash = {:notice => {:controller => 'pages', :action => 'show'}}
        @template.locale_flash.should == %Q{<div class="notice">Found in controllers.flash.show.notice</div>}
      end

      it "returns the flash falling back to the key flash" do
        @template.flash = {:notice => {:controller => 'other', :action => 'index'}}
        @template.locale_flash.should == %Q{<div class="notice">Found in controllers.flash.notice</div>}
      end
    end
  end

  describe "#locale_flash_default(type, msg)" do
    it "should be correct for simple controllers" do
      @template.send(
        :locale_flash_default,
        :notice, {:controller => 'users',  :action => 'show'}
      ).should == [
        :"controllers.users.flash.notice",
        :"controllers.flash.show.notice",
        :"controllers.flash.notice"
      ]
    end

    it "should be correct for nested controllers" do
      @template.send(
        :locale_flash_default,
        :notice, {:controller => 'admin/users', :action => 'show'}
      ).should == [
        :"controllers.admin.users.flash.notice",
        :"controllers.admin.flash.show.notice",
        :"controllers.admin.flash.notice",
        :"controllers.flash.show.notice",
        :"controllers.flash.notice"
      ]
    end

    it "should be correct for multiply nested controllers" do
      @template.send(
        :locale_flash_default,
        :notice, {:controller => 'admin/users/projects', :action => 'show'}
      ).should == [
        :"controllers.admin.users.projects.flash.notice",
        :"controllers.admin.users.flash.show.notice",
        :"controllers.admin.users.flash.notice",
        :"controllers.admin.flash.show.notice",
        :"controllers.admin.flash.notice",
        :"controllers.flash.show.notice",
        :"controllers.flash.notice"
      ]
    end
  end
end