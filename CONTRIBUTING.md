We love contributions from the community! Here's a quick guide to making a pull
request:

Overview
========

1. Fork the repo.

2. Install [Dependencies](#installing-dependencies)

3. Run the tests. We only take pull requests with passing tests, and it's great
to know that you have a clean slate: `bundle && bundle exec rake`

4. If you're adding functionality or fixing a bug, add a failing test for the
issue first.

5. Make the test pass.

6. If you're adding a new feature, ensure that the documentation is up to date
(see the README for instructions on previewing documentation live).

7. Finally, push to your fork and submit a pull request.

At this point you're waiting on us. We try to respond to issues and pull
requests within a few business days. We may suggest some changes to make to your
code to fit with our [code style] or the project style, or discuss alternate
ways of addressing the issue in question. When we're happy with everything,
we'll bring your changes into master. Now you're a contributor!

Installing Dependencies
=======================

On RedHat based systems
-----------------------

```
sudo yum install -y ruby-devel postgresql-devel sqlite-devel zlib-devel  
```

Also, install one of the javascript runtimes supported by [execjs]. For instance, to install Node.js do 

```
sudo su
curl -sL https://rpm.nodesource.com/setup | bash -
yum install -y nodejs
```

[code style]: https://github.com/thoughtbot/guides/tree/master/style
[execjs]: https://github.com/sstephenson/execjs