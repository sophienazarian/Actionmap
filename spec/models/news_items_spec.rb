# frozen_string_literal: true

require 'rails_helper'
RSpec.describe NewsItem, type: :model do
  describe "associations" do
    let(:representative) { Representative.create!(name: 'John Doe') }
    let(:issue) { Issue.create!(name: 'Free Speech') }
    let(:news_item) do
      described_class.create!(
        title:          'Title',
        link:           'http://example.com',
        representative: representative,
        issue:          issue
      )
    end

    it "belongs to a representative" do
      expect(news_item.representative).to eq(representative)
    end

    it "belongs to an issue" do
      expect(news_item.issue).to eq(issue)
    end
  end

  describe "validations" do
    let(:representative) { Representative.create!(name: 'John Doe') }
    let(:issue) { Issue.create!(name: 'Free Speech') }
    let(:news_item) do
      described_class.create!(
        title:          'Title',
        link:           'http://example.com',
        representative: representative,
        issue:          issue
      )
    end

    it "is valid with an issue from the ISSUES list" do
      expect(news_item).to be_valid
    end
  end

  describe "invalidations" do
    let(:representative) { Representative.create!(name: 'John Doe') }
    let(:invalid_issue) { Issue.create!(name: 'Invalid Issue') }
    let(:news_item) do
      described_class.new(
        title:          'Title',
        link:           'http://example.com',
        representative: representative,
        issue:          invalid_issue
      )
    end

    it "is invalid with an issue not in the ISSUES list" do
      expect(news_item).not_to be_valid
      expect(news_item.errors[:issue]).to include("is not included in the list")
    end
  end

  describe ".find_for" do
    let(:representative) { Representative.create!(name: 'John Doe') }
    let(:issue) { Issue.create!(name: 'Free Speech') }
    let!(:news_item) do
      described_class.create!(
        title:          'Title',
        link:           'http://example.com',
        representative: representative,
        issue:          issue
      )
    end

    context 'when a news item exists for the given representative_id' do
      it "returns the news item for the given representative_id" do
        result = described_class.find_for(representative.id)
        expect(result).to eq(news_item)
      end
    end

    context 'when no news item exists for the given representative_id' do
      let(:other_representative) { Representative.create!(name: 'Jane Smith') }

      it "returns nil if no news item exists for the given representative_id" do
        result = described_class.find_for(other_representative.id)
        expect(result).to be_nil
      end
    end
  end
end
