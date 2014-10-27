module Tests
  class Version
    def initialize(version)
      @version = Gem::Version.new(version.to_s + '')
    end

    def <(other_version)
      compare?(:<, other_version)
    end

    def <=(other_version)
      compare?(:<=, other_version)
    end

    def ==(other_version)
      compare?(:==, other_version)
    end

    def >=(other_version)
      compare?(:>=, other_version)
    end

    def >(other_version)
      compare?(:>, other_version)
    end

    def =~(other_version)
      Gem::Requirement.new(other_version).satisfied_by?(version)
    end

    def to_s
      version.to_s
    end

    protected

    attr_reader :version

    private

    def compare?(op, other_version)
      Gem::Requirement.new("#{op} #{other_version}").satisfied_by?(version)
    end
  end
end
