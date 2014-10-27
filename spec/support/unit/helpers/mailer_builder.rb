module UnitTests
  module MailerBuilder
    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def define_mailer(name, paths, &block)
      class_name = name.to_s.pluralize.classify
      define_class(class_name, ActionMailer::Base, &block)
    end
  end
end
