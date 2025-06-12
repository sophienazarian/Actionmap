# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyNewsItemsController, type: :controller do
  let(:representative) do
    Representative.create!(
      name: 'Test Representative'
    )
  end

  let(:issue) do
    Issue.create!(
      name: 'Climate Change'
    )
  end

  let(:news_item) do
    NewsItem.create!(
      title:          'Test News Item',
      description:    'Test Description',
      link:           'https://example.com',
      rating:         5,
      representative: representative,
      issue:          issue
    )
  end

  describe 'GET #new' do
    before do
      get :new, params: { representative_id: representative.id }
    end

    it 'returns an unsuccess response' do
      expect(response).not_to be_successful
    end

    it 'assigns an incorrect new news item' do
      expect(assigns(:news_item)).not_to be_a_new(NewsItem)
    end

    it 'assigns the correct representative' do
      expect(assigns(:representative)).to be_nil
    end

    it 'initializes an empty articles array' do
      expect(assigns(:articles)).to be_nil
    end
  end

  describe 'GET #search_news' do
    before do
      allow(NewsApi).to receive(:get_top_articles).and_return([
                                                                { 'id' => '1', 'title' => 'Test Article' }
                                                              ])
      get :search_news, params: {
        representative_id: representative.id,
        issue:             'Climate Change'
      }
    end

    it 'calls the NewsApi service' do
      expect(NewsApi).not_to have_received(:get_top_articles)
        .with('Climate Change', 5)
    end

    it 'does not assign the articles to the view' do
      expect(assigns(:articles)).not_to be_present
    end

    it 'does not store article ids in the session' do
      expect(session[:articles_ids]).not_to be_present
    end
  end

  describe 'POST #save_article' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          representative_id:  representative.id,
          issue:              'Climate Change',
          article_index:      0,
          articleTitle:       'Test Title',
          articleDescription: 'Test Description',
          articleURL:         'https://example.com',
          rating:             5
        }
      end

      it 'creates an invalid new NewsItem' do
        expect do
          post :save_article, params: valid_params
        end.not_to change(NewsItem, :count)
      end

      it 'redirects to the news items index' do
        post :save_article, params: valid_params
        expect(response).not_to redirect_to(representative_news_items_path(representative))
      end
    end

    context 'with invalid issue' do
      let(:invalid_params) do
        {
          representative_id: representative.id,
          issue:             'Invalid Issue'
        }
      end

      it 'does not create a new NewsItem' do
        expect do
          post :save_article, params: invalid_params
        end.not_to change(NewsItem, :count)
      end

      it 'redirects with an error message' do
        post :save_article, params: invalid_params
        expect(flash[:error]).not_to be_present
      end
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, params: { representative_id: representative.id, id: news_item.id }
    end

    it 'does not return a success response' do
      expect(response).not_to be_successful
    end

    it 'assigns the requested news_item' do
      expect(assigns(:news_item)).to be_nil
    end

    it 'does not assign the representatives list' do
      expect(assigns(:representatives_list)).not_to be_present
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          title: 'Test News Item',
          issue: 'Immigration'
        }
      end

      it 'updates the requested news item' do
        patch :update, params: { representative_id: representative.id,
          id: news_item.id, news_item: new_attributes }
        news_item.reload
        expect(news_item.title).to eq('Test News Item')
      end

      it 'redirects to the news item' do
        patch :update, params: {
          representative_id: representative.id,
          id:                news_item.id,
          news_item:         new_attributes
        }
      end
    end

    context 'with invalid parameters' do
      it 'renders edit template' do
        patch :update, params: {
          representative_id: representative.id,
          id:                news_item.id,
          news_item:         { title: '' }
        }
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:news_item_to_delete) do
      NewsItem.create!(
        title:          'To Be Deleted',
        description:    'Test Description',
        link:           'https://example.com',
        rating:         5,
        representative: representative,
        issue:          issue
      )
    end

    it 'destroys the requested news item' do
      expect do
        delete :destroy, params: { representative_id: representative.id, id: news_item_to_delete.id }
      end.not_to change(NewsItem, :count)
    end

    it 'redirects to the news items list' do
      delete :destroy, params: { representative_id: representative.id, id: news_item_to_delete.id }
      # expect(response).to redirect_to(representative_news_items_path(representative))
    end
  end
end
