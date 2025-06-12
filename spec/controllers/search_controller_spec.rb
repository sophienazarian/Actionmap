# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController do
  let(:valid_address) { "Los Angeles, CA" }
  let(:mock_response) do
    instance_double(
      Google::Apis::CivicinfoV2::RepresentativeInfoResponse,
      offices:   [],
      officials: []
    )
  end
  let(:invalid_address) { "NotAState" }
  let(:empty_address) { "" }
  let(:civic_service) { instance_double(Google::Apis::CivicinfoV2::CivicInfoService) }

  before do
    allow(civic_service).to receive(:representative_info_by_address).and_return(mock_response)
    allow(civic_service).to receive(:key=)
    allow(Google::Apis::CivicinfoV2::CivicInfoService).to receive(:new).and_return(civic_service)
  end

  describe 'GET #search' do
    context 'when address is empty' do
      it 'sets a flash alert and redirects to the representatives page' do
        get :search, params: { address: empty_address }

        expect(flash[:alert]).to eq("Address empty")
        expect(response).to redirect_to(representatives_path)
      end
    end

    context 'when address is invalid' do
      before do
        allow(civic_service).to receive(:representative_info_by_address)
          .and_return(mock_response)
          .and_raise(Google::Apis::ClientError.new("Invalid address"))
      end

      it 'sets a flash alert for invalid state and redirects' do
        get :search, params: { address: invalid_address }

        expect(flash[:alert]).to eq("Invalid state")
        expect(response).to redirect_to(representatives_path)
      end
    end

    context 'when address is valid' do
      it 'renders the search page with representatives' do
        get :search, params: { address: valid_address }

        expect(response).to render_template('representatives/search')
        expect(assigns(:representatives)).to eq([])
      end
    end
  end
end
