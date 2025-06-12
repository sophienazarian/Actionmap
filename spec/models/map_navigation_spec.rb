# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representatives Search', type: :feature do
  describe 'Search Form' do
    before do
      visit representatives_path
    end

    it 'displays navigation elements' do
      expect(page).to have_content('Actionmap')
      expect(page).to have_link('Home')
      expect(page).to have_link('Representatives')
    end

    context 'when visiting representatives search page' do
      before do
        click_link 'Representatives'
      end

      it 'displays the search form' do
        expect(page).to have_content('Enter a location')
        expect(page).to have_field('address', type: 'text')
        expect(page).to have_button('Search')
      end

      it 'allows searching for representatives' do
        within('form') do
          fill_in 'address', with: 'Los Angeles County, CA'
          click_button 'Search'
        end
        expect(page).to have_current_path(search_representatives_path, ignore_query: true)
      end

      it 'has proper form attributes' do
        form = find('form')
        expect(form['action']).to eq(search_representatives_path)
        expect(form['method']).to eq('get')
        expect(page).to have_css('.form-control')
        expect(page).to have_css('.btn.btn-primary')
      end
    end
  end

  describe 'Layout Structure' do
    before do
      visit representatives_path
      click_link 'Representatives'
    end

    it 'has basic navigation elements' do
      expect(page).to have_css('nav')
      expect(page).to have_link('Home')
      expect(page).to have_link('Representatives')
    end

    it 'has footer information' do
      expect(page).to have_content('Data Sources')
      expect(page).to have_content('Google Civic Information')
      expect(page).to have_content('Census.gov')
    end
  end
end
