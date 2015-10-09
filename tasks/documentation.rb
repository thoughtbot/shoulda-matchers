require_relative '../lib/shoulda/matchers/version'
require 'erb'

module Shoulda
  module Matchers
    module DocumentationTasks
      extend Rake::DSL

      def self.create
        publisher = DocumentationPublisher.new

        namespace :docs do
          file DocumentationPublisher.gh_pages_dir do
            publisher.create_reference_to_gh_pages_branch
          end

          file DocumentationPublisher.docs_dir => DocumentationPublisher.gh_pages_dir

          task :setup => DocumentationPublisher.docs_dir do
            publisher.reset_repo_directory
          end

          desc 'Generate docs for a particular version'
          task :generate, [:version, :latest_version] => :setup do |t, args|
            unless args.version
              raise ArgumentError, "Missing version"
            end

            unless args.latest_version
              raise ArgumentError, "Missing latest_version"
            end

            publisher.generate_docs_for(args.version, latest_version: args.latest_version)
          end

          desc 'Watch source files for this project for changes and autogenerate docs accordingly'
          task :autogenerate do
            require 'fssm'

            project_directory = File.expand_path(File.dirname(__FILE__) + "/..")

            regenerate_docs = proc do
              print 'Regenerating docs... '
              if system('bundle exec yard doc &>/dev/null')
                puts 'done!'
              else
                print "\nCould not regenerate docs!!"
              end
            end

            regenerate_docs.call

            puts 'Waiting for documentation files to change...'

            FSSM.monitor do
              path project_directory do
                glob '{README.md,NEWS.md,.yardopts,docs/**/*.md,doc_config/yard/**/*.{rb,js,css,erb},lib/**/*.rb}'
                create(&regenerate_docs)
                update(&regenerate_docs)
              end
            end
          end

          desc 'Generate docs for a particular version and push them to GitHub'
          task :publish, [:version, :latest_version] => :setup do |t, args|
            unless args.version
              raise ArgumentError, "Missing version"
            end

            unless args.latest_version
              raise ArgumentError, "Missing latest_version"
            end

            publisher.generate_docs_for(args.version, latest_version: args.latest_version)
            publisher.publish_docs_for(args.version, latest_version: args.latest_version)
          end

          desc "Generate docs for version #{DocumentationPublisher.current_version} and push them to GitHub"
          task :publish_latest => :setup do
            publisher.publish_latest_version
          end
        end
      end
    end

    class DocumentationPublisher
      CURRENT_VERSION = Shoulda::Matchers::VERSION
      GITHUB_USERNAME = 'thoughtbot'
      # GITHUB_USERNAME = 'mcmire'
      GH_PAGES_DIR = ".#{GITHUB_USERNAME}-gh-pages"
      DOCS_DIR = "#{GH_PAGES_DIR}/docs"

      def self.current_version
        CURRENT_VERSION
      end

      def self.gh_pages_dir
        GH_PAGES_DIR
      end

      def self.docs_dir
        DOCS_DIR
      end

      def create_reference_to_gh_pages_branch
        system "git clone git@github.com:#{GITHUB_USERNAME}/shoulda-matchers.git #{GH_PAGES_DIR} --branch gh-pages"
      end

      def reset_repo_directory
        within_gh_pages_dir do
          system 'git fetch origin'
          system 'git reset --hard origin/gh-pages'
        end
      end

      def generate_docs_for(version, options = {})
        ref = determine_ref_from(version)

        system "rm -rf #{DOCS_DIR}/#{ref}"
        system "bundle exec yard -o #{DOCS_DIR}/#{ref}"

        add_version_to_index_page_for(ref, version)

        within_docs_dir do
          system "git add #{ref}"
        end

        if options[:latest_version]
          generate_file_that_redirects_to_latest_version(options[:latest_version])
        end
      end

      def publish_docs_for(version, options = {})
        message = build_commit_message(version)

        within_gh_pages_dir do
          system 'git clean -f'
          system "git commit -m '#{message}'"
          system 'git push origin gh-pages'
        end
      end

      def publish_latest_version
        version = Gem::Version.new(CURRENT_VERSION)
        options = {}

        unless version.prerelease?
          options[:latest_version] = version.to_s
        end

        generate_docs_for(CURRENT_VERSION, options)
        publish_docs_for(CURRENT_VERSION, options)
      end

      private

      def add_version_to_index_page_for(ref, version)
        within_docs_dir do
          filename = "#{ref}/index.html"
          content = File.read(filename)
          content.sub!(%r{<h1>shoulda-matchers.+</h1>}, "<h1>shoulda-matchers (#{version})</h1>")
          File.open(filename, 'w') {|f| f.write(content) }
        end
      end

      def generate_file_that_redirects_to_latest_version(version)
        ref = determine_ref_from(version)
        locals = { ref: ref, github_username: GITHUB_USERNAME }

        erb = ERB.new(File.read('doc_config/gh-pages/index.html.erb'))

        within_docs_dir do
          File.open('index.html', 'w') { |f| f.write(erb.result(binding)) }
          system 'git add index.html'
        end
      end

      def determine_ref_from(version)
        if version =~ /^\d+\.\d+\.\d+/
          'v' + version
        else
          version
        end
      end

      def build_commit_message(version)
        "Regenerated docs for version #{version}"
      end

      def within_gh_pages_dir(&block)
        Dir.chdir(GH_PAGES_DIR, &block)
      end

      def within_docs_dir(&block)
        Dir.chdir(DOCS_DIR, &block)
      end
    end
  end
end
