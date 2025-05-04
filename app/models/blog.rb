# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where('title LIKE :term OR content LIKE :term', term: "%#{term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  scope :visible_to, lambda { |user|
    if user
      where(secret: false).or(Blog.where(secret: true, user_id: user.id))
    else
      where(secret: false)
    end
  }

  scope :editable_by, lambda { |user|
    user ? where(user_id: user.id) : none
  }

  def owned_by?(target_user)
    user == target_user
  end
end
