require 'spec_helper'

module Adrift
  shared_examples_for "any attachment" do
    describe "#dirty?" do
      context "for a newly instantiated attachment" do
        it "returns false" do
          attachment.should_not be_dirty
        end
      end

      context "when a file has been assigned" do
        before { attachment.assign(up_file_double) }

        it "returns true" do
          attachment.should be_dirty
        end

        context "and the attachment is saved" do
          it "returns false" do
            attachment.save
            attachment.should_not be_dirty
          end
        end

        context "and the attachment is cleared" do
          it "returns true" do
            attachment.should be_dirty
          end
        end
      end
    end

    describe "#empty?" do
      context "when a file has been assigned" do
        it "returns true" do
          attachment.assign(up_file_double)
          attachment.should_not be_empty
        end
      end
    end

    describe "#assign" do
      let(:up_file) { up_file_double }

      it "updates the attachment's filename in the model" do
        up_file.stub(:original_filename => 'new_me.png')
        attachment.assign(up_file)
        user.avatar_filename.should == 'new_me.png'
      end

      it "replaces the filename's non alphanumeric characters with '_' (except '.')" do
        up_file.stub(:original_filename => 'my awesome-avatar!.png')
        attachment.assign(up_file)
        attachment.filename.should == 'my_awesome_avatar_.png'
      end
    end

    describe "#save" do
      context "when a file hasn't been assigned" do
        it "doesn't store anything" do
          attachment.save
          attachment.storage.stored.should be_empty
        end

        it "doesn't remove anything" do
          attachment.save
          attachment.storage.removed.should be_empty
        end

        it "doesn't proccess anything" do
          attachment.processor.should_not_receive(:process)
          attachment.save
        end
      end

      context "when a file has been assigned" do
        before do
          attachment.styles = { :normal => '100x100', :small => '50x50' }
          attachment.path = '/:class_name/:id/:style/:filename'
          attachment.assign up_file_double(:original_filename => 'new_me.png', :path => '/tmp/123')
        end

        it "process the assigned file" do
          attachment.processor.should_receive(:process).with('/tmp/123', attachment.styles)
          attachment.save
        end

        it "stores the assigned file and the processed ones" do
          attachment.save
          attachment.storage.stored.should include(['/tmp/123', '/users/1/original/new_me.png'])
          attachment.storage.stored.should include(['/tmp/normal-123', '/users/1/normal/new_me.png'])
          attachment.storage.stored.should include(['/tmp/small-123', '/users/1/small/new_me.png'])
          attachment.storage.stored.size.should == 3
        end

        context "when an ':original' style has been set" do
          before do
            attachment.styles[:original] = '500x500'
            attachment.save
          end

          it "doesn't store the uploaded file" do
            attachment.storage.stored.should_not include(['/tmp/123', '/users/1/original/new_me.png'])
          end

          it "stores the processed one" do
            attachment.storage.stored.should include(['/tmp/original-123', '/users/1/original/new_me.png'])
          end
        end
      end

      context "when two files has been asigned without saving" do
        before do
          attachment.styles = { :normal => '100x100', :small => '50x50' }
          attachment.path = '/:class_name/:id/:style/:filename'
          attachment.assign up_file_double(:original_filename => 'first_me.png', :path => '/tmp/123')
          attachment.assign up_file_double(:original_filename => 'second_me.png', :path => '/tmp/456')
          attachment.save
        end

        it "stores and process only the second assigned file" do
          attachment.storage.stored.should include(['/tmp/456', '/users/1/original/second_me.png'])
          attachment.storage.stored.should include(['/tmp/normal-456', '/users/1/normal/second_me.png'])
          attachment.storage.stored.should include(['/tmp/small-456', '/users/1/small/second_me.png'])
          attachment.storage.stored.size.should == 3
        end

        it "doesn't try to remove the first assigned file" do
          attachment.storage.removed.should_not include('/users/1/original/first_me.png')
          attachment.storage.removed.should_not include('/users/1/normal/first_me.png')
          attachment.storage.removed.should_not include('/users/1/small/first_me.png')
        end
      end

      describe "#destroy" do
        context "when a file hasn't been assigned" do
          before { attachment.destroy }

          it "doesn't store anything" do
            attachment.storage.stored.should be_empty
          end

          it "sets to nil the attachment filename in the model" do
            user.avatar_filename.should be_nil
          end
        end

        context "when a file has been assigned" do
          before do
            attachment.styles = { :normal => '100x100', :small => '50x50' }
            attachment.path = '/:class_name/:id/:style/:filename'
            attachment.assign up_file_double(:original_filename => 'new_me.png', :path => '/tmp/123')
            attachment.destroy
          end

          it "doesn't remove the assigned file nor its processed files" do
            attachment.storage.removed.should_not include('/users/1/original/new_me.png')
            attachment.storage.removed.should_not include('/users/1/normal/new_me.png')
            attachment.storage.removed.should_not include('/users/1/small/new_me.png')
          end

          it "doesn't store anything" do
            attachment.storage.stored.should be_empty
          end

          it "sets to nil the attachment filename in the model" do
            user.avatar_filename.should be_nil
          end
        end
      end
    end
  end

  describe Attachment do
    describe ".default_options" do
      let(:default_options) { Attachment.default_options }

      it "has a default style" do
        default_options.should have_key(:default_style)
        default_options[:default_style].should == :original
      end

      it "doesn't have any styles defined" do
        default_options.should have_key(:styles)
        default_options[:styles].should == {}
      end

      it "has a default url for empty attachments" do
        default_options.should have_key(:default_url)
        default_options[:default_url].should == '/images/missing.png'
      end

      it "has a url pattern for non empty attachments" do
        default_options.should have_key(:url)
        default_options[:url].should == '/system/attachments/:class_name/:id/:attachment/:filename'
      end

      it "has a path pattern for non empty attachments" do
        default_options.should have_key(:path)
        default_options[:path].should == ':root/public:url'
      end

      it "has a class to build the attachment's storage" do
        default_options.should have_key(:storage_class)
        default_options[:storage_class].should == Storage::Filesystem
      end

      it "has a class to build the attachment's processor" do
        default_options.should have_key(:processor_class)
        default_options[:processor_class].should == Processor::Thumbnail
      end

      it "has a pattern class used to build patterns from strings" do
        default_options.should have_key(:pattern_class)
        default_options[:pattern_class].should == Pattern
      end
    end

    describe ".reset_default_options" do
      it "revert changes made to the default options" do
        original_value = Attachment.default_options[:url]
        Attachment.default_options[:url] = '/:filename'
        Attachment.default_options[:url].should_not == original_value
        Attachment.reset_default_options
        Attachment.default_options[:url].should == original_value
      end
    end

    describe ".new" do
      let(:user) { user_double }
      let(:attachment) { Attachment.new(:avatar, user) }

      it "sets the attachment's name" do
        attachment.name.should == :avatar
      end

      it "sets the model to which the attachment belongs" do
        attachment.model.should == user
      end

      context "when not providing custom options" do
        it "uses the default options" do
          default_style_option = Attachment.default_options[:default_style]
          default_style_option.should_not be_nil
          attachment.default_style.should == default_style_option
        end
      end

      context "when providing custom options" do
        let(:styles) { { :small => '50x50', :normal => '100x100' } }
        let(:attachment) { Attachment.new(:avatar, user, :styles => styles) }

        it "prefers the custom over the default options" do
          Attachment.default_options[:styles].should_not == styles
          attachment.styles.should == styles
        end

        it "uses the default options when there's not a custom one" do
          Attachment.default_options[:default_style].should_not be_nil
          attachment.default_style.should == Attachment.default_options[:default_style]
        end

        it "doesn't complain if it doesn't know the option" do
          expect {
            Attachment.new(:avatar, user, :imaginary => 'option')
          }.to_not raise_error
        end
      end
    end

    describe ".config" do
      after { Attachment.reset_default_options }

      it "changes the default attachment options" do
        default_url = '/missing.png'
        Attachment.default_options[:default_url].should_not == default_url
        Attachment.config { default_url default_url }
        Attachment.default_options[:default_url].should == default_url
      end
    end
  end

  describe Attachment, "when is empty" do
    let(:user) { user_double(:id => 1, :avatar_filename => nil) }
    let(:attachment) { Attachment.new(:avatar, user) }

    it_behaves_like "any attachment"

    describe "#empty?" do
      it "returns true" do
        attachment.should be_empty
      end
    end

    describe "#url" do
      it "returns a default url" do
        attachment.url.should == '/images/missing.png'
      end

      it "builds the default url from a pattern if there's one" do
        attachment.default_url = '/images/:class_name/missing.png'
        attachment.url.should == '/images/users/missing.png'
      end

      it "accepts a style" do
        attachment.default_url = '/images/:class_name/missing_:style.png'
        attachment.url(:small).should == '/images/users/missing_small.png'
      end

      it "uses a default style if there isn't one" do
        attachment.default_style = :normal
        attachment.default_url = '/images/:class_name/missing_:style.png'
        attachment.url.should == '/images/users/missing_normal.png'
      end

      it "assumes an ':original' default style" do
        attachment.default_url = '/images/:class_name/missing_:style.png'
        attachment.url.should == '/images/users/missing_original.png'
      end
    end

    describe "#path" do
      it "returns nil" do
        attachment.path.should be_nil
      end

      it "accepts a style" do
        attachment.path(:small).should be_nil
      end
    end

    describe "#save" do
      context "when a file has been assigned" do
        before do
          attachment.assign(up_file_double)
          attachment.save
        end

        it "doesn't remove anything" do
          attachment.storage.removed.should be_empty
        end
      end

      context "when a file has been assigned and then cleared" do
        before do
          attachment.assign(up_file_double)
          attachment.clear
          attachment.save
        end

        it "doesn't store anything" do
          attachment.storage.stored.should be_empty
        end

        it "doesn't remove anything" do
          attachment.storage.removed.should be_empty
        end
      end
    end

    describe "#destroy" do
      it "doesn't remove anything" do
        attachment.destroy
        attachment.storage.removed.should be_empty
      end
    end
  end

  describe Attachment, "when isn't empty" do
    let(:user) { user_double(:id => 1, :avatar_filename => 'me.png') }
    let(:attachment) { Attachment.new(:avatar, user) }

    it_behaves_like "any attachment"

    describe "#dirty?" do
      context "when the attachment is cleared" do
        before { attachment.clear }

        it "returns true" do
          attachment.should be_dirty
        end

        context "and the attachment is saved" do
          it "returns false" do
            attachment.save
            attachment.should_not be_dirty
          end
        end
      end
    end

    describe "#empty?" do
      it "returns false" do
        attachment.should_not be_empty
      end
    end

    describe "#url" do
      it "builds its url from a default pattern" do
        attachment.url.should == '/system/attachments/users/1/avatars/me.png'
      end

      it "builds its url from a pattern if there's one" do
        attachment.url = '/:class_name/:id/:attachment/:filename'
        attachment.url.should == '/users/1/avatars/me.png'
      end

      it "accepts a style" do
        attachment.url = '/:class_name/:id/:attachment/:style/:filename'
        attachment.url(:small).should == '/users/1/avatars/small/me.png'
      end

      it "uses a default style if there isn't one" do
        attachment.default_style = :normal
        attachment.url = '/:class_name/:id/:attachment/:style/:filename'
        attachment.url.should == '/users/1/avatars/normal/me.png'
      end

      it "assumes an ':original' default style" do
        attachment.url = '/:class_name/:id/:attachment/:style/:filename'
        attachment.url.should == '/users/1/avatars/original/me.png'
      end
    end

    describe "#path" do
      it "builds its path from the url by default" do
        attachment.stub(:url => '/users/1/avatars/me.png')
        attachment.path.should == './public/users/1/avatars/me.png'
      end

      it "builds its path from a pattern if there's one" do
        attachment.path = './:class_name/:id/:attachment/:filename'
        attachment.path.should == './users/1/avatars/me.png'
      end

      it "accepts a style" do
        attachment.path = './:class_name/:id/:attachment/:style/:filename'
        attachment.path(:small).should == './users/1/avatars/small/me.png'
      end

      it "uses a default style if there isn't one" do
        attachment.default_style = :normal
        attachment.path = './:class_name/:id/:attachment/:style/:filename'
        attachment.path.should == './users/1/avatars/normal/me.png'
      end

      it "assumes an ':original' default style" do
        attachment.path = './:class_name/:id/:attachment/:style/:filename'
        attachment.path.should == './users/1/avatars/original/me.png'
      end
    end

    describe "#clear" do
      it "sets to nil the attachment filename in the model" do
        attachment.clear
        attachment.filename.should be_nil
      end
    end

    describe "#save" do
      context "when a file has been assigned" do
        before do
          attachment.styles = { :normal => '100x100', :small => '50x50' }
          attachment.path = '/:class_name/:id/:style/:filename'
          attachment.assign up_file_double(:original_filename => 'new_me.png', :path => '/tmp/123')
          attachment.save
        end

        it "removes the previous files for each style" do
          attachment.storage.removed.should include('/users/1/original/me.png')
          attachment.storage.removed.should include('/users/1/normal/me.png')
          attachment.storage.removed.should include('/users/1/small/me.png')
        end
      end

      context "when the attachment has been cleared" do
        let(:attachment) { Attachment.new(:avatar, user) }
        before do
          attachment.styles = { :normal => '100x100', :small => '50x50' }
          attachment.path = '/:class_name/:id/:style/:filename'
          attachment.clear
          attachment.save
        end

        it "doesn't store anything" do
          attachment.storage.stored.should be_empty
        end

        it "removes the files for each style" do
          attachment.storage.removed.should include('/users/1/original/me.png')
          attachment.storage.removed.should include('/users/1/normal/me.png')
          attachment.storage.removed.should include('/users/1/small/me.png')
          attachment.storage.removed.size.should == 3
        end
      end
    end

    describe "#destroy" do
      context "when a file hasn't been assigned" do
        before do
          attachment.styles = { :normal => '100x100', :small => '50x50' }
          attachment.path = '/:class_name/:id/:style/:filename'
          attachment.destroy
        end

        it "removes the files for each style" do
          attachment.storage.removed.should include('/users/1/original/me.png')
          attachment.storage.removed.should include('/users/1/normal/me.png')
          attachment.storage.removed.should include('/users/1/small/me.png')
          attachment.storage.removed.size.should == 3
        end
      end

      context "when a file has been assigned" do
        before do
          attachment.styles = { :normal => '100x100', :small => '50x50' }
          attachment.path = '/:class_name/:id/:style/:filename'
          attachment.assign up_file_double(:original_filename => 'new_me.png', :path => '/tmp/123')
          attachment.destroy
        end

        it "removes the files for every style" do
          attachment.storage.removed.should include('/users/1/original/me.png')
          attachment.storage.removed.should include('/users/1/normal/me.png')
          attachment.storage.removed.should include('/users/1/small/me.png')
          attachment.storage.removed.size.should == 3
        end
      end
    end
  end
end
