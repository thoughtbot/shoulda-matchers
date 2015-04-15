We love contributions from the community! Here's a quick guide to making a pull
request.

## Overview

0. If you haven't contributed before, please read and understand the [Code of
Conduct].

1. Fork the repo.

2. Install [dependencies](#installing-dependencies).

3. Run the tests. We only take pull requests with passing tests, and it's great
to know that you have a clean slate: `bundle && bundle exec rake`

4. If you're adding functionality or fixing a bug, add a failing test for the
issue first.

5. Make the test pass.

6. Finally, push to your fork and submit a pull request.

At this point you're waiting on us. We try to respond to issues and pull
requests within a few business days. We may suggest some changes to make to your
code to fit with our [code style] or the project style, or discuss alternate
ways of addressing the issue in question. When we're happy with everything,
we'll bring your changes into master. Now you're a contributor!

## Installing Dependencies

### On Debian/Ubuntu-based systems

```
sudo apt-get install -y ruby-dev libpq-dev libsqlite3-dev nodejs
```

Ubuntu, as of 14.04, ships with Ruby 1.9.2. shoulda-matchers is only compatible
with Ruby 2, so use your Ruby version manager of choice to install the latest
version of Ruby (2.2.1 at the time of this writing).

```
# RVM
rvm install 2.2
rvm use 2.2

# rbenv
rbenv install 2.2.1
rbenv shell 2.2.1
```

### On RedHat-based systems

```
sudo yum install -y ruby-devel postgresql-devel sqlite-devel zlib-devel
```

Also, install one of the JavaScript runtimes supported by [execjs]. For
instance, to install node.js:

```
sudo su
curl -sL https://rpm.nodesource.com/setup | bash -
yum install -y nodejs
```

[Code of Conduct]: https://thoughtbot.com/open-source-code-of-conduct
[code style]: https://github.com/thoughtbot/guides/tree/master/style
[execjs]: https://github.com/sstephenson/execjs
[install rvm]: https://rvm.io/rvm/install
