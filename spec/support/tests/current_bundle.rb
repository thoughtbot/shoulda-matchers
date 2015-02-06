require 'bundler'
require 'appraisal'

module Tests
  class CurrentBundle
    AppraisalNotSpecified = Class.new(ArgumentError)

    include Singleton

    def assert_appraisal!
      unless appraisal?
        message = <<EOT


Please run tests starting with `appraisal <appraisal_name>`.
Possible appraisals are: #{possible_appraisals}

EOT
        raise AppraisalNotSpecified, message
      end
    end

    private

    def possible_appraisals
      appraisals = []

      Appraisal::File.each do |appraisal|
        appraisals << appraisal.name
      end

      appraisals
    end

    def path
      Bundler.default_gemfile
    end

    def appraisal?
      path.dirname == root.join('gemfiles')
    end

    def root
      Pathname.new('../../../..').expand_path(__FILE__)
    end
  end
end
