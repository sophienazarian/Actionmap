# frozen_string_literal: true

class MyNewsItemsController < SessionController
  before_action :set_representative, except: [:new]
  before_action :set_representatives_list, only: [:new]
  before_action :set_issues_list, only: %i[new search_news]
  before_action :set_issue, only: %i[search_news]
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @representative = Representative.find(params[:representative_id])
    @news_item = NewsItem.new
    @articles = []
  end

  def search_news
    @representative = Representative.find(params[:representative_id])
    @articles = NewsApi.get_top_articles(@issue, 5)
    session[:articles_ids] = @articles.map { |article| article['id'] }
  end

  def save_article
    representative = Representative.find(params[:representative_id])
    issue = Issue.find_or_create_by!(name: params[:issue])
    article_index = params[:article_index].to_i
    news_item = representative.news_items.new(
      title:       params["article_title_#{article_index}"],
      description: params["article_description_#{article_index}"],
      link:        params["article_url_#{article_index}"],
      issue:       issue,
      rating:      params[:rating]
    )
    if news_item.save
      redirect_to representative_news_items_path(representative), notice: 'Article saved successfully.'
    else
      redirect_to new_representative_my_news_item_path(representative),
                  alert: "Failed to save the article: #{news_item.errors.full_messages.join(', ')}"
    end
  end

  def edit
    set_representatives_list
    set_news_item
  end

  def update
    issue_name = params[:news_item].delete(:issue)
    issue = Issue.find_or_create_by!(name: issue_name) if issue_name.present?
    if @news_item.update(news_item_params.merge(issue: issue))
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      flash.now[:error] = 'An error occurred when updating the news item.'
      render :edit
    end
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News item was successfully destroyed.'
  end

  private

  def set_representative
    @representative = Representative.find(params[:representative_id])
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_issues_list
    @issues_list = [
      'Free Speech', 'Immigration', 'Terrorism', 'Social Security and Medicare',
      'Abortion', 'Student Loans', 'Gun Control', 'Unemployment',
      'Climate Change', 'Homelessness', 'Racism', 'Tax Reform', 'Net Neutrality',
      'Religious Freedom', 'Border Security', 'Minimum Wage', 'Equal Pay'
    ]
  end

  def set_issue
    @issue = params[:issue]
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :link, :description, :representative_id, :issue, :rating)
  end
end
