# frozen_string_literal: true

# spec/models/state_spec.rb
require 'rails_helper'

RSpec.describe State, type: :model do
  let(:valid_attributes) do
    {
      name:         'California',
      symbol:       'CA',
      fips_code:    6,
      is_territory: 0,
      lat_min:      32.5,
      lat_max:      42.0,
      long_min:     -124.4,
      long_max:     -114.1
    }
  end

  describe 'associations' do
    it 'has many counties' do
      state = described_class.create!(valid_attributes)
      county1 = state.counties.create!(name: 'County 1', fips_code: '001', fips_class: '06')
      county2 = state.counties.create!(name: 'County 2', fips_code: '002', fips_class: '06')

      expect(state.counties).to include(county1, county2)
    end

    it 'deletes associated counties when state is deleted' do
      state = described_class.create!(valid_attributes)
      state.counties.create!(name: 'County 1', fips_code: '001', fips_class: '06')

      expect { state.destroy }.to change(County, :count).by(-1)
    end
  end

  describe 'database constraints' do
    it 'requires name' do
      expect do
        described_class.create!(valid_attributes.except(:name))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires symbol' do
      expect do
        described_class.create!(valid_attributes.except(:symbol))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires fips_code' do
      expect do
        described_class.create!(valid_attributes.except(:fips_code))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires lat_min' do
      expect do
        described_class.create!(valid_attributes.except(:lat_min))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires lat_max' do
      expect do
        described_class.create!(valid_attributes.except(:lat_max))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires long_min' do
      expect do
        described_class.create!(valid_attributes.except(:long_min))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires long_max' do
      expect do
        described_class.create!(valid_attributes.except(:long_max))
      end.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe '#std_fips_code' do
    context 'when fips_code is single digit' do
      let(:state) { described_class.create!(valid_attributes.merge(fips_code: 6)) }

      it 'pads with leading zero' do
        expect(state.std_fips_code).to eq('06')
      end
    end

    context 'when fips_code is double digit' do
      let(:state) { described_class.create!(valid_attributes.merge(fips_code: 48)) }

      it 'returns the code as is' do
        expect(state.std_fips_code).to eq('48')
      end
    end
  end

  describe 'geographic boundaries' do
    let(:state) { described_class.create!(valid_attributes) }

    it 'enforces valid latitude ranges' do
      expect(state.lat_min).to be_between(-90, 90)
      expect(state.lat_max).to be_between(-90, 90)
      expect(state.lat_max).to be > state.lat_min
    end

    it 'enforces valid longitude ranges' do
      expect(state.long_min).to be_between(-180, 180)
      expect(state.long_max).to be_between(-180, 180)
      expect(state.long_max).to be > state.long_min
    end
  end

  describe 'territories handling' do
    context 'when is a state' do
      let(:state) { described_class.create!(valid_attributes.merge(is_territory: 0)) }

      it 'is not marked as territory' do
        expect(state.is_territory).to eq(0)
      end
    end

    context 'when is a territory' do
      let(:state) { described_class.create!(valid_attributes.merge(is_territory: 1)) }

      it 'is marked as territory' do
        expect(state.is_territory).to eq(1)
      end
    end
  end
end
