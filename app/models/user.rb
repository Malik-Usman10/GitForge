class User < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: :slugged

  # Devise modules for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Associations
  has_many :repositories, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :pull_requests, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
  
  # Email validations
  validates :email, email: { mode: :strict, require_fqdn: true }
  validate :email_not_disposable, if: -> { email_changed? }

  # Uploader (e.g., for ActiveStorage)
  has_one_attached :avatar

  # Additional profile attributes
  # Note: real_name, bio already exist in the database
  # location, website were added in migration
  alias_attribute :name, :real_name

  # Callback to generate username from email
  before_validation :generate_username, on: :create

  def should_generate_new_friendly_id?
    username_changed?
  end

  private

  def generate_username
    if email.present?
      base_username = email.split('@').first
      # If username already exists, append a random number
      if User.exists?(username: base_username)
        self.username = "#{base_username}#{rand(1000)}"
      else
        self.username = base_username
      end
    end
  end
  
  def email_not_disposable
    domain = email.split('@').last&.downcase
    
    # List of common disposable email domains
    disposable_domains = [
      'mailinator.com', 'yopmail.com', 'guerrillamail.com', 'guerrillamail.info',
      'guerrillamail.biz', 'guerrillamail.org', 'guerrillamailblock.com',
      'sharklasers.com', 'sharklasers.net', 'sharklasers.org', 'grr.la',
      'temp-mail.org', 'temp-mail.ru', 'tempmail.net', 'throwawaymail.com',
      'trashmail.com', 'trashmail.net', '10minutemail.com', 'mailinator.net',
      'maildrop.cc', 'mailnesia.com', 'dispostable.com', 'tempmailaddress.com'
    ]
    
    if disposable_domains.include?(domain)
      errors.add(:email, "from disposable email providers are not allowed")
    end
  end
end
