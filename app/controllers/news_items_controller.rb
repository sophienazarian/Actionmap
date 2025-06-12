# frozen_string_literal: true

class NewsItemsController < ApplicationController
  before_action :set_representative
  before_action :set_news_item, only: %i[show]

  def index
    @representative = Representative.find(params[:representative_id])
    @news_items = @representative.news_items.includes(:issue)
  end

  def show
    @representative = Representative.find(params[:representative_id])
    @news_item = NewsItem.find(params[:id])
  end

  private

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_news_item
    @news_item = @representative.news_items.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(
      :title, :link, :description, :issue, :representative_id
    )
  end
end
