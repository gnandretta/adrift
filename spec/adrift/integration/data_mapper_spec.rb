require 'spec_helper'

module Adrift::Integration
  describe DataMapper do
    it_behaves_like 'Adrift::Integration::Base' do
      before { klass.stub(after: nil, before:  nil) }

      describe ".attachment" do
        it "registers an after save callback to save the attachments" do
          klass.should_receive(:after).with(:save, :save_attachments)
          klass.attachment :avatar
        end

        it "registers a before destroy callback to destroy the attachments" do
          klass.should_receive(:before).with(:destroy, :destroy_attachments)
          klass.attachment :avatar
        end
      end
    end
  end
end
