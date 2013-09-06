require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::Callbacks do

  let :class_with_callbacks do
    define_model :example do
      ActiveRecord::Base::CALLBACKS.each do |callback_name|
        send callback_name, :method_to_call
      end
    end
  end

  let :class_without_callbacks do
    define_model :example do
    end
  end

  ActiveRecord::Base::CALLBACKS.each do |callback_name|
    it { class_with_callbacks.should        send("have_#{callback_name}_callback_on", :method_to_call) }
    it { class_without_callbacks.should_not send("have_#{callback_name}_callback_on", :method_to_call) }
  end

end
