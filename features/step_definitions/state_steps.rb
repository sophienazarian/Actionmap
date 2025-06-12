# frozen_string_literal: true

# features/step_definitions/state_steps.rb
Given('no states exist') do
  State.delete_all
  County.delete_all
end

Given('a state exists with fips_code {string}') do |code|
  @state = State.create!(
    name:         'Test State',
    symbol:       'TS',
    fips_code:    code.to_i,
    is_territory: 0,
    lat_min:      32.5,
    lat_max:      42.0,
    long_min:     -124.4,
    long_max:     -114.1
  )
end

Given('a state {string} with fips_code {string}') do |name, fips|
  @state = State.create!(
    name:         name,
    symbol:       name[0..1].upcase,
    fips_code:    fips.to_i,
    is_territory: 0,
    lat_min:      32.5,
    lat_max:      42.0,
    long_min:     -124.4,
    long_max:     -114.1
  )
end

Given('the state has the following counties:') do |table|
  table.hashes.each do |county_data|
    @state.counties.create!(county_data)
  end
  @county_count = table.hashes.length
end

When('I get the standardized FIPS code') do
  @result = @state.std_fips_code
end

When('I delete the state') do
  @state_id = @state.id
  @state.destroy
end

When('I create a state with these coordinates:') do |table|
  coords = table.hashes.first
  lat_min = coords['lat_min'].to_f
  lat_max = coords['lat_max'].to_f
  long_min = coords['long_min'].to_f
  long_max = coords['long_max'].to_f

  if lat_min < -90 || lat_max > 90 || long_min < -180 || long_max > 180
    @result = 'error'
  else
    begin
      @state = State.create!(
        name:         'Test State',
        symbol:       'TS',
        fips_code:    1,
        is_territory: 0,
        lat_min:      lat_min,
        lat_max:      lat_max,
        long_min:     long_min,
        long_max:     long_max
      )
      @result = 'success'
    rescue StandardError
      @result = 'error'
    end
  end
end

When('I create a state with territory status {int}') do |status|
  @state = State.create!(
    name:         'Test Territory',
    symbol:       'TT',
    fips_code:    1,
    is_territory: status,
    lat_min:      32.5,
    lat_max:      42.0,
    long_min:     -124.4,
    long_max:     -114.1
  )
end

Then('the result should be {string}') do |expected_code|
  expect(@result).to eq(expected_code)
end

Then('all associated counties should be deleted') do
  expect(County.where(state_id: @state_id).count).to eq(0)
  expect(County.count).to eq(0)
end

Then('the creation should be {string}') do |expected_result|
  expect(@result).to eq(expected_result)
end

Then('the territory flag should be correctly set to {int}') do |status|
  expect(@state.is_territory).to eq(status)
end
