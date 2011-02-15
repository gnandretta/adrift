require 'spec_helper'
require 'adrift/adhesive/data_mapper'

module Adrift::Adhesive
  describe DataMapper do
    let(:instance) { klass.new }
    let(:klass) do
      Class.new do
        extend DataMapper
        attr_accessor :avatar_filename

        def self.before(*) end
        def self.after(*) end
      end
    end

    context "when extends a class" do
      it "adds a .has_attached_file method" do
        klass.should respond_to(:has_attached_file)
      end
    end

    describe ".has_attached_file" do
      before { klass.has_attached_file :avatar }

      it "adds a #attachments method" do
        klass.instance_methods.should include(:attachments)
      end

      it "adds a #save_attachments method" do
        klass.instance_methods.should include(:save_attachments)
      end

      it "adds a #destroy_attachments method" do
        klass.instance_methods.should include(:destroy_attachments)
      end

      it "adds an attachment reader method" do
        klass.instance_methods.should include(:avatar)
      end

      it "adds an attachment writer method" do
        klass.instance_methods.should include(:avatar)
      end

      it "defines an after_save callback to save the attachments" do
        klass.should_receive(:after).with(:save, :save_attachments)
        klass.has_attached_file :avatar
      end

      it "defines an before_destroy callback to save the attachments" do
        klass.should_receive(:before).with(:destroy, :destroy_attachments)
        klass.has_attached_file :avatar
      end

      it "registers the attachment definition" do
        definition = { :styles => { :normal => '100x100' } }
        klass.has_attached_file :avatar, definition
        klass.attachment_definitions[:avatar].should == definition
      end
    end

    describe ".save_attachments" do
      it "saves every attachment" do
        klass.has_attached_file :avatar
        klass.has_attached_file :photo
        instance.avatar.should_receive(:save)
        instance.photo.should_receive(:save)
        instance.save_attachments
      end
    end

    describe ".destroy_attachments" do
      it "destroy every attachment" do
        klass.has_attached_file :avatar
        klass.has_attached_file :photo
        instance.avatar.should_receive(:destroy)
        instance.photo.should_receive(:destroy)
        instance.destroy_attachments
      end
    end

    describe "attachment reader" do
      before { klass.has_attached_file :avatar }

      it "returns an attachment" do
        instance.avatar.should be_instance_of(Adrift::Attachment)
      end

      it "is always the same" do
        instance.avatar.should === instance.avatar
      end

      it "has the specified name" do
        instance.avatar.name.should == :avatar
      end

      it "has the specified options" do
        styles = { :small => '50x50' }
        klass.has_attached_file :avatar, :styles => styles
        instance.avatar.styles.should == styles
      end
    end

    describe "attachment writer" do
      let(:up_file_representation) do
        double('up file representation', {
          :original_filename => 'me.png',
          :tempfile => double('tempfile', :path => '/tmp/123')
        })
      end

      it "assigns its argument to the attachment" do
        klass.has_attached_file :avatar
        instance.avatar = up_file_representation
        instance.avatar.filename.should == 'me.png'
      end
    end
  end
end
