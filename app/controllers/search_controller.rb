# frozen_string_literal: true

require 'google/apis/civicinfo_v2'

class SearchController < ApplicationController
  def search
    address = params[:address]

    if address.blank?
      flash[:alert] = "Address empty"
      redirect_to representatives_path and return
    end
    service = Google::Apis::CivicinfoV2::CivicInfoService.new
    service.key = Rails.application.credentials[:GOOGLE_API_KEY]
    result = service.representative_info_by_address(address: address)
    @representatives = Representative.civic_api_to_representative_params(result)

    render 'representatives/search'
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Google::Apis::ClientError: #{e.message}")
    if e.message.include?("address")
      flash[:alert] = "Invalid state"
      redirect_to representatives_path and return
    end
  end
end
