# frozen_string_literal: true

# app/models/news_item.rb
class NewsItem < ApplicationRecord
  belongs_to :representative
  belongs_to :issue

  ISSUES = [
    "Free Speech", "Immigration", "Terrorism",
    "Social Security and Medicare", "Abortion",
    "Student Loans", "Gun Control", "Unemployment",
    "Climate Change", "Homelessness", "Racism",
    "Tax Reform", "Net Neutrality", "Religious Freedom",
    "Border Security", "Minimum Wage", "Equal Pay"
  ].freeze

  validates :issue, presence: true
  validate :validate_issue_name

  def validate_issue_name
    return unless issue.present? && ISSUES.exclude?(issue.name)

    errors.add(:issue, "is not included in the list")
  end

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end
end

#------------------------------------------------------------------------------
# NewsItem
#
# Name              SQL Type             Null    Primary Default
# ----------------- -------------------- ------- ------- ----------
# id                INTEGER              false   true
# title             varchar              false   false
# link              varchar              false   false
# description       TEXT                 true    false
# representative_id INTEGER              false   false
# created_at        datetime             false   false
# updated_at        datetime             false   false
#
#------------------------------------------------------------------------------
