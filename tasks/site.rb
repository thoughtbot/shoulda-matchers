module SiteTasks
  extend Rake::DSL

  def self.create
    publisher = SitePublisher.new

    namespace :site do
      file SitePublisher.gh_pages_dir do
        publisher.create_reference_to_gh_pages_branch
      end

      task :setup => SitePublisher.gh_pages_dir do
        publisher.reset_repo_directory
      end

      desc 'Publish the site to GitHub Pages'
      task :publish => :setup do
        publisher.publish
      end
    end
  end
end

class SitePublisher
  GITHUB_USERNAME = 'thoughtbot'
  GH_PAGES_DIR = ".#{GITHUB_USERNAME}-gh-pages"

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

  def publish
    build_site
    commit_and_push_updates
  end

  private

  def build_site
    system 'bundle exec middleman build'

    Dir.entries('build').each do |entry|
      unless entry.start_with?('.')
        FileUtils.rm_rf("#{GH_PAGES_DIR}/#{entry}")
        FileUtils.cp_r("build/#{entry}", "#{GH_PAGES_DIR}/#{entry}")
      end
    end
  end

  def commit_and_push_updates
    message = 'Update site'

    within_gh_pages_dir do
      system 'git add -A .'
      system "git commit -m '#{message}'"
      system 'git push origin gh-pages'
    end
  end

  def within_gh_pages_dir(&block)
    Dir.chdir(GH_PAGES_DIR, &block)
  end
end
