require 'bundler'
require 'appraisal'

module Tests
  class CurrentBundle
    AppraisalNotSpecified = Class.new(ArgumentError)

    include Singleton

    def assert_appraisal!
      unless appraisal_in_use?
        message = <<EOT


Please run tests starting with `appraisal <appraisal_name>`.
Possible appraisals are: #{available_appraisals}

EOT
        raise AppraisalNotSpecified, message
      end
    end

    def appraisal_in_use?
      path.dirname == root.join('gemfiles')
    end

    def current_or_latest_appraisal
      current_appraisal || latest_appraisal
    end

    def latest_appraisal
      available_appraisals.sort.last
    end

    def available_appraisals
      Appraisal::AppraisalFile.each.map(&:name)
    end

    private

    def current_appraisal
      if appraisal_in_use?
        File.basename(path, ".gemfile")
      end
    end

    def path
      Bundler.default_gemfile
    end

    def root
      Pathname.new('../../../..').expand_path(__FILE__)
    end
  end
end
