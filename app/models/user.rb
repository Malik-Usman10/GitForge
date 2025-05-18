class User < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: :slugged

  # Devise modules for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :repositories, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :pull_requests, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :real_name, presence: true

  # Uploader (e.g., for ActiveStorage)
  has_one_attached :avatar

  # Callback to generate username from email (optional)
  before_validation :generate_username, on: :create

  def should_generate_new_friendly_id?
    username_changed?
  end

  private

  def generate_username
    self.username ||= email.split('@').first if email.present?
  end
end
