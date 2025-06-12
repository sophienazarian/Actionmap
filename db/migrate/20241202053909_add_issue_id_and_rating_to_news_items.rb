# frozen_string_literal: true

class AddIssueIdAndRatingToNewsItems < ActiveRecord::Migration[5.2]
  def change
    add_column :news_items, :issue_id, :integer
    add_column :news_items, :rating, :integer
  end
end
