require 'spec_helper'

module Adrift::Integration
  describe ActiveRecord do
    it_behaves_like Adrift::Integration::Base do
      before { klass.stub(after_save: nil, before_destroy: nil) }

      describe ".attachment" do
        it "registers an after save callback to save the attachments" do
          klass.should_receive(:after_save).with(:save_attachments)
          klass.attachment :avatar
        end

        it "registers a before destroy callback to destroy the attachments" do
          klass.should_receive(:before_destroy).with(:destroy_attachments)
          klass.attachment :avatar
        end
      end
    end
  end
end
