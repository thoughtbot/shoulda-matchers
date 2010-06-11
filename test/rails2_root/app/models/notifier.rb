class Notifier < ActionMailer::Base
  def the_email
    from       "do-not-reply@example.com"
    recipients "myself@me.com"
    subject    "This is spam"
    body       :body => "Every email is spam."
  end
end
