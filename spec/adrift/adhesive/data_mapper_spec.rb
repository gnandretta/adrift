require 'spec_helper'

module Adrift::Adhesive
  describe DataMapper do
    it_behaves_like Adrift::Adhesive, :callbacks => {
      :after  => [:save, :save_attachments],
      :before => [:destroy, :destroy_attachments]
    }
  end
end
