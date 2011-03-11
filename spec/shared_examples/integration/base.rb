shared_examples_for Adrift::Integration::Base do
  let(:instance) { klass.new }
  let(:klass) do
    Class.new.tap do |klass|
      klass.send :extend, described_class
      klass.send :attr_accessor, :avatar_filename
    end
  end

  context "when extends a class" do
    it "adds a .attachment method" do
      klass.should respond_to(:attachment)
    end
  end

  describe ".attachment" do
    before { klass.attachment :avatar }

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

    it "registers the attachment definition" do
      definition = { :styles => { :normal => '100x100' } }
      klass.attachment :avatar, definition
      klass.attachment_definitions[:avatar].should == definition
    end
  end

  describe ".save_attachments" do
    it "saves every attachment" do
      klass.attachment :avatar
      klass.attachment :photo
      instance.avatar.should_receive(:save)
      instance.photo.should_receive(:save)
      instance.save_attachments
    end
  end

  describe ".destroy_attachments" do
    it "destroy every attachment" do
      klass.attachment :avatar
      klass.attachment :photo
      instance.avatar.should_receive(:destroy)
      instance.photo.should_receive(:destroy)
      instance.destroy_attachments
    end
  end

  describe "attachment reader" do
    before { klass.attachment :avatar }

    context "when an :attachment_class option hasn't been specified" do
      it "returns an instance of Adrift::Attachment" do
        instance.avatar.should be_instance_of(Adrift::Attachment)
      end
    end

    context "when an :attachment_class option has been specified" do
      before do
        klass.attachment(
          :avatar,
          :style => { :small => '50x50' },
          :attachment_class => attachment_class
        )
      end
      let(:attachment_class) { Class.new }

      it "returns an instance of the specified class" do
        instance.avatar.should be_instance_of(attachment_class)
      end

      it "instantiates the class withouth the :attachment_class option" do
        attachment_class.should_receive(:new).with(
          anything,
          anything,
          hash_not_including(:attachment_class)
        )
        instance.avatar
      end
    end

    it "is always the same" do
      instance.avatar.should === instance.avatar
    end

    it "has the specified name" do
      instance.avatar.name.should == :avatar
    end

    it "has the specified options" do
      styles = { :small => '50x50' }
      klass.attachment :avatar, :styles => styles
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
      klass.attachment :avatar
      instance.avatar = up_file_representation
      instance.avatar.filename.should == 'me.png'
    end
  end
end
