require 'spec_helper'

describe Shoulda::Matchers::ActionController::FilterParamMatcher do
  it 'accepts filtering a filtered parameter' do
    filter(:secret)

    expect(nil).to filter_param(:secret)
  end

  it 'rejects filtering an unfiltered parameter' do
    filter(:secret)
    matcher = filter_param(:other)

    expect(matcher.matches?(nil)).to eq false

    expect(matcher.failure_message).to match(/Expected other to be filtered.*secret/)
  end

  def filter(param)
    Rails.application.config.filter_parameters = [param]
  end
end
