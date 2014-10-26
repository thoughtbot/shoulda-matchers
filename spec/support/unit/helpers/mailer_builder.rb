module MailerBuilder
  def define_mailer(name, paths, &block)
    class_name = name.to_s.pluralize.classify
    define_class(class_name, ActionMailer::Base, &block)
  end
end

RSpec.configure do |config|
  config.include MailerBuilder
end
