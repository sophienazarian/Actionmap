# frozen_string_literal: true

Given('the following representatives exist:') do |table|
  table.hashes.each do |row|
    Representative.create!(
      name:      row['Name'],
      title:     row['Title'],
      ocdid:     row['OCDID'],
      state:     row['State'],
      party:     row['Party'],
      street:    row['Street'],
      city:      row['City'],
      zip:       row['Zip'],
      photo_url: row['Photo URL']
    )
  end
end

Given('I navigate to the search page') do
  visit search_representatives_path
end

When('I enter {string} in the search bar') do |location|
  fill_in 'address', with: location
end

When('I click {string}') do |button|
  click_button button
end

Then('I should see {string} in the search results') do |name|
  within('#events') do
    expect(page).to have_content(name)
  end
end

Then('I should not see {string} in the search results') do |name|
  within('#events') do
    expect(page).not_to have_content(name)
  end
end

When('I click on {string}') do |name|
  click_link name
end

Then('I should see {string} on the profile page') do |content|
  expect(page).to have_content(content)
end

Then('I should see an image with source {string}') do |src|
  expect(page).to have_css("img[src='#{src}']")
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end
