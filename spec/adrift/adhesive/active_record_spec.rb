require 'spec_helper'

module Adrift::Adhesive
  describe ActiveRecord do
    it_behaves_like Adrift::Adhesive, :callbacks => {
      :after_save     => [:save_attachments],
      :before_destroy => [:destroy_attachments]
    }
  end
end
