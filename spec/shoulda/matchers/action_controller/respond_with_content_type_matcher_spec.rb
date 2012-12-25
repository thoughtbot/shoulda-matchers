require 'spec_helper'

describe Shoulda::Matchers::ActionController::RespondWithContentTypeMatcher do
  it 'generates the correct description' do
    expected = 'respond with content type of application/xml'

    respond_with_content_type(:xml).description.should == expected
  end

  it 'accepts responding with content type as symbol' do
    xml_controller.should respond_with_content_type(:xml)
  end

  it 'accepts responding with qualified MIME-style content type' do
    xml_controller.should respond_with_content_type('application/xml')
  end

  it 'accepts responding with a regex matching the content type' do
    xml_controller.should respond_with_content_type(/xml/)
  end

  it 'rejects responding with another content type' do
    xml_controller.should_not respond_with_content_type(:json)
  end

  def xml_controller
    build_response do
      render :xml => { :user => 'thoughtbot' }.to_xml
    end
  end
end
