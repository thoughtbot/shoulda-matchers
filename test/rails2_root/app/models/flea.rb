class Flea < ActiveRecord::Base
  has_and_belongs_to_many :dogs

  after_create :send_notification

  private

  def send_notification
    Notifier.deliver_the_email
  end
end
