class Blogpost < ActiveRecord::Base

  include MailerHelper
  include UsersHelper

  validates_presence_of :title, :content, :author
  belongs_to :user_author, class_name: "User", foreign_key: "user_author_id"
  belongs_to :user_editor, class_name: "User", foreign_key: "user_editor_id"
  has_many :comments, :dependent => :destroy
  accepts_nested_attributes_for :comments

  def author
    @author ||= if self.user_author.present?
      user_author
    else
      User.first
    end
  end

  def editor
    # can be nil
    @editor ||= user_editor
  end

  def edited?
    !!user_editor_id
  end

  def send_new_mention_mail(old_content = "")
    new_mentions = mentions(content) - mentions(old_content)
    mails = []
    new_mentions.each do |user|
      begin
        mails << RedstonerMailer.new_post_mention_mail(user, self)
      rescue => e
        Rails.logger.error "---"
        Rails.logger.error "WARNING: Failed to create new_post_mention_mail (view) for post#: #{@self.id}, user: #{@user.name}, #{@user.email}"
        Rails.logger.error e.message
        Rails.logger.error "---"
      end
    end
    background_mailer(mails)
  end

end
