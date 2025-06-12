# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative do
  let(:rep_info) do
    Struct.new(:officials, :offices).new(
      [
        Struct.new(:name, :address, :party, :photo_url).new(
          "John Doe", nil, nil, nil
        ),
        Struct.new(:name, :address, :party, :photo_url).new(
          "Jane Smith", nil, nil, nil
        )
      ],
      [
        Struct.new(:name, :division_id, :official_indices).new(
          "Senator", "ocd-division/country:us/state:ca", [0]
        ),
        Struct.new(:name, :division_id, :official_indices).new(
          "Representative", "ocd-division/country:us/state:ca/cd:12", [1]
        )
      ]
    )
  end

  describe '.civic_api_to_representative_params' do
    context 'when processing new representatives' do
      it 'creates the correct number of representatives' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.count).to eq(2)
      end

      it 'creates representative with correct name and title' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.first.name).to eq("John Doe")
        expect(reps.first.title).to eq("Senator")
      end

      it 'creates representative with correct ocdid' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.first.ocdid).to eq("ocd-division/country:us/state:ca")
      end

      it 'sets additional attributes as nil when not provided' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.first.street).to be_nil
        expect(reps.first.city).to be_nil
        expect(reps.first.state).to be_nil
      end

      it 'sets additional attributes as nil when not provided pt 2' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.first.zip).to be_nil
        expect(reps.first.party).to be_nil
        expect(reps.first.photo_url).to be_nil
      end
    end

    context 'when a representative already exists' do
      let!(:existing_rep) do
        described_class.create!(
          name:      "John Doe",
          ocdid:     "ocd-division/country:us/state:ca",
          title:     "Senator",
          street:    nil,
          city:      nil,
          state:     nil,
          zip:       nil,
          party:     nil,
          photo_url: nil
        )
      end

      it 'displays nil for missing optional attributes' do
        expect(existing_rep.street).to be_nil
        expect(existing_rep.city).to be_nil
        expect(existing_rep.party).to be_nil
        expect(existing_rep.photo_url).to be_nil
      end

      it 'reuses the existing representative if present' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.first.id).to eq(existing_rep.id)
      end

      it 'only creates one new representative when another already exists' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.count).to eq(2)
        expect(described_class.where(name: "John Doe").count).to eq(1)
      end

      it 'updates the title if it has changed' do
        existing_rep.update(title: "Old Title")
        reps = described_class.civic_api_to_representative_params(rep_info)
        expect(reps.first.title).to eq("Senator")
      end

      it 'ensures additional fields remain nil if not updated' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        updated_rep = reps.first
        expect(updated_rep.street).to be_nil
        expect(updated_rep.city).to be_nil
        expect(updated_rep.state).to be_nil
      end

      it 'ensures additional fields remain nil if not updated pt 2' do
        reps = described_class.civic_api_to_representative_params(rep_info)
        updated_rep = reps.first
        expect(updated_rep.zip).to be_nil
        expect(updated_rep.party).to be_nil
        expect(updated_rep.photo_url).to be_nil
      end
    end
  end

  describe 'Individual Representative Profiles' do
    let!(:representative) do
      described_class.create!(
        name:      "Jane Smith",
        ocdid:     "ocd-division/country:us/state:tx",
        title:     "Representative",
        street:    "123 Main St",
        city:      "Austin",
        state:     "TX",
        zip:       "73301",
        party:     "Independent",
        photo_url: "https://example.com/photo.jpg"
      )
    end

    it 'displays all relevant details for the representative' do
      expect(representative.name).to eq("Jane Smith")
      expect(representative.title).to eq("Representative")
      expect(representative.street).to eq("123 Main St")
      expect(representative.city).to eq("Austin")
    end

    it 'displays all relevant details for the representative pt 2' do
      expect(representative.state).to eq("TX")
      expect(representative.zip).to eq("73301")
      expect(representative.party).to eq("Independent")
      expect(representative.photo_url).to eq("https://example.com/photo.jpg")
    end

    it 'allows accessing the representative profile attributes' do
      expect(representative).to respond_to(:name, :title, :street, :city, :state, :zip, :party, :photo_url)
    end
  end
end
