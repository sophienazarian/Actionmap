# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsItemsController, type: :controller do
  let(:issue) { Issue.create!(name: 'Climate Change') }
  let(:immigration_issue) { Issue.create!(name: 'Immigration') }

  let(:representative) do
    Representative.create!(
      name:  'John Smith',
      ocdid: 'ocd-division/123',
      title: 'Senator'
    )
  end

  let(:news_item) do
    NewsItem.create!(
      title:          'Test News',
      link:           'http://example.com/news',
      description:    'Test description',
      representative: representative,
      issue:          immigration_issue
    )
  end

  describe 'GET #index' do
    context 'when representative exists' do
      before do
        news_item

        3.times do |i|
          NewsItem.create!(
            title:          "News #{i}",
            link:           "http://example.com/news/#{i}",
            description:    "Description #{i}",
            representative: representative,
            issue:          issue
          )
        end

        get :index, params: { representative_id: representative.id }
      end

      it 'assigns @representative' do
        expect(assigns(:representative)).to eq(representative)
      end

      it 'assigns @news_items to representative\'s news items' do
        expect(assigns(:news_items)).to eq(representative.news_items)
      end

      it 'returns all news items for the representative' do
        expect(assigns(:news_items).count).to eq(4)
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end
    end

    context 'when representative does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          get :index, params: { representative_id: 'nonexistent' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #show' do
    context 'when representative and news item exist' do
      before do
        get :show, params: {
          representative_id: representative.id,
          id:                news_item.id
        }
      end

      it 'assigns @representative' do
        expect(assigns(:representative)).to eq(representative)
      end

      it 'assigns @news_item' do
        expect(assigns(:news_item)).to eq(news_item)
      end

      it 'renders the show template' do
        expect(response).to render_template(:show)
      end
    end

    context 'when representative does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          get :show, params: { representative_id: 'nonexistent', id: news_item.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when news item does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          get :show, params: { representative_id: representative.id, id: 'nonexistent' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'private methods' do
    describe '#set_representative' do
      it 'sets @representative' do
        get :index, params: { representative_id: representative.id }
        expect(assigns(:representative)).to eq(representative)
      end

      it 'raises ActiveRecord::RecordNotFound for nonexistent representative' do
        expect do
          get :index, params: { representative_id: 'nonexistent' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#set_news_item' do
      it 'sets @news_item' do
        get :show, params: {
          representative_id: representative.id,
          id:                news_item.id
        }
        expect(assigns(:news_item)).to eq(news_item)
      end

      it 'raises ActiveRecord::RecordNotFound for nonexistent news item' do
        expect do
          get :show, params: { representative_id: representative.id, id: 'nonexistent' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#news_item_params' do
      before do
        controller.params = ActionController::Parameters.new(
          news_item: {
            title:       'Test Title',
            link:        'http://example.com',
            description: 'Test Description',
            issue:       issue.id
          }
        )
      end

      it 'permits specific parameters' do
        permitted = controller.send(:news_item_params)
        expect(permitted.keys).to match_array(%w[title link description issue])
      end
    end
  end
end
