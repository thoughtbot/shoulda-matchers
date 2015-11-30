# Contributing to shoulda-matchers

We love contributions from the community! Here's a quick guide to making a pull
request.

1. If you haven't contributed before, please read and understand the [Code of
   Conduct].

1. Ensure that you have a [working Ruby environment].

1. Fork the repo on GitHub, then clone it to your machine.

1. Now that you've cloned the repo, navigate to it and install dependencies by
   running:

   ```
   bundle install
   ```

1. All tests should be passing, but it's a good idea to run them anyway
   before starting any work:
   
   ```
   bundle exec rake
   ```

1. If you're adding functionality or fixing a bug, you'll want to add a
   failing test for the issue first.

1. Now you can implement the feature or bugfix.

1. Since we only accept pull requests with passing tests, it's a good idea to
   run the tests again. Since you're probably working on a single file, you can
   run the tests for that file with the following command:

   ```
   appraisal 4.2 rspec <path of test file to run>
   ```

   You can also run unit tests by running `zeus start` in one shell, and then
   running the following in another:

   ```
   zeus rspec <path of test file to run>
   ```

   And to run the entire test suite again:
   
   ```
   bundle exec rake
   ```

1. Finally, push to your fork and submit a pull request.

At this point you're waiting on us. We try to respond to issues and pull
requests within a few business days. We may suggest some changes to make to your
code to fit with our [code style] or the project style, or discuss alternate
ways of addressing the issue in question. When we're happy with everything,
we'll bring your changes into master. Now you're a contributor!

## Addendum: Setting up your environment

### Installing dependencies (Linux only)

#### Debian/Ubuntu

Run this command to install necessary dependencies:

```
sudo apt-get install -y ruby-dev libpq-dev libsqlite3-dev nodejs
```

#### RedHat

Run this command to install necessary dependencies:

```
sudo yum install -y ruby-devel postgresql-devel sqlite-devel zlib-devel
```

Then, install one of the JavaScript runtimes supported by [execjs]. For
instance, to install node.js:

```
sudo su
curl -sL https://rpm.nodesource.com/setup | bash -
yum install -y nodejs
```

### Installing Ruby (all platforms)

shoulda-matchers is only compatible with Ruby 2.x. A `.ruby-version` is included
in the repo, so if you're using one of the Ruby version manager tools, then you
should be using (or have been prompted to install) the latest version of Ruby.
If not, you'll want to do that.

[working Ruby environment]: #addendum-setting-up-your-environment
[Code of Conduct]: https://thoughtbot.com/open-source-code-of-conduct
[code style]: https://github.com/thoughtbot/guides/tree/master/style
[execjs]: https://github.com/sstephenson/execjs
[install rvm]: https://rvm.io/rvm/install
