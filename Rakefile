GH_PAGES_DIR = '.gh-pages'
# GH_USERNAME = 'thoughtbot'
GITHUB_USERNAME = 'mcmire'

namespace :site do
  directory GH_PAGES_DIR do
    create_reference_to_gh_pages_branch
  end

  task :setup => GH_PAGES_DIR do
    reset_repo_directory
  end

  desc 'Publish the site to GitHub Pages'
  task :publish => :setup do
    build_site
    commit_and_push_updates
  end

  def create_reference_to_gh_pages_branch
    sh "git clone git@github.com:#{GITHUB_USERNAME}/shoulda-matchers.git #{GH_PAGES_DIR} --branch gh-pages"
  end

  def reset_repo_directory
    within_gh_pages_dir do
      sh 'git fetch origin'
      sh 'git reset --hard origin/gh-pages'
    end
  end

  def build_site
    sh 'bundle exec middleman build'

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
      sh 'git add -A .'
      sh "git commit -m '#{message}'"
      sh 'git push origin gh-pages'
    end
  end

  def within_gh_pages_dir(&block)
    Dir.chdir(GH_PAGES_DIR, &block)
  end
end
