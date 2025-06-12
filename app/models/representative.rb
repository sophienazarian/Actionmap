# frozen_string_literal: true

class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Define a struct for office information
  OfficeInfo = Struct.new(:name, :division_id)

  def self.civic_api_to_representative_params(rep_info)
    rep_info.officials.each_with_index.map do |official, index|
      office_info = find_office_info(rep_info.offices, index)
      create_or_update_representative(official, office_info)
    end
  end

  def self.find_office_info(offices, official_index)
    matching_office = offices.find do |off|
      off.official_indices.include?(official_index)
    end

    return OfficeInfo.new('', '') unless matching_office

    OfficeInfo.new(matching_office.name, matching_office.division_id)
  end

  def self.create_or_update_representative(official, office)
    address = official.address&.first
    rep = find_or_create_rep(official, office, address)
    update_rep_details(rep, official, office, address)
    rep
  end

  def self.find_or_create_rep(official, office, address)
    Representative.find_or_create_by(name: official.name, ocdid: office.division_id) do |r|
      set_initial_attributes(r, official, office, address)
    end
  end

  def self.set_initial_attributes(rep, official, office, address)
    rep.title = office.name
    rep.street = address&.line1
    rep.city = address&.city
    rep.state = address&.state
    rep.zip = address&.zip
    rep.party = official.party
    rep.photo_url = official.photo_url
  end

  def self.update_rep_details(rep, official, office, address)
    rep.update(
      title:     office.name,
      party:     official.party,
      photo_url: official.photo_url,
      street:    address&.line1,
      city:      address&.city,
      state:     address&.state,
      zip:       address&.zip
    )
  end

  def full_address
    address_parts = [street, city, state, zip].compact
    return "Address not available" if address_parts.empty?

    address_parts.join(', ')
  end

  def photo_tag
    if photo_url.present?
      ActionController::Base.helpers.image_tag(
        photo_url,
        class: 'img-fluid rounded',
        alt:   name
      )
    else
      "<em>No photo available</em>".html_safe
    end
  end
end
