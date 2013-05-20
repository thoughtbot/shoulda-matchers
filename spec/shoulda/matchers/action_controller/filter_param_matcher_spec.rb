require 'spec_helper'

describe Shoulda::Matchers::ActionController::FilterParamMatcher do
  it 'accepts filtering a filtered parameter' do
    filter(:secret)

    nil.should filter_param(:secret)
  end

  it 'rejects filtering an unfiltered parameter' do
    filter(:secret)
    matcher = filter_param(:other)

    matcher.matches?(nil).should be_false

    matcher.failure_message_for_should.should =~ /Expected other to be filtered.*secret/
  end

  def filter(param)
    Rails.application.config.filter_parameters = [param]
  end
end
