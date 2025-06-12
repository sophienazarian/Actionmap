# frozen_string_literal: true

class Issue < ApplicationRecord
  has_many :news_items, dependent: :destroy
end
