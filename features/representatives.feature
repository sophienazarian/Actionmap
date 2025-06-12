Feature: Search and View Representatives
  As a user
  I want to search for representatives by location
  So that I can view their details and profiles

  Scenario: Search for representatives in California
    Given I am on the representatives page
    When I enter "California" in the search bar
    And I click "Search"
    Then I should see "Kamala D. Harris" in the search results
    And I should not see "Ted Cruz" in the search results

  Scenario: Search for representatives in Texas
    Given I am on the representatives page
    When I enter "Texas" in the search bar
    And I click "Search"
    Then I should see "Ted Cruz" in the search results
    And I should not see "Alex Padilla" in the search results

  Scenario: View individual representative profile
    Given I am on the representatives page
    When I enter "Texas" in the search bar
    And I click "Search"
    And I click on "Ted Cruz"
    Then I should see "Ted Cruz" on the profile page
    And I should see "U.S. Senator" on the profile page
    And I should see "Republican Party" on the profile page
    And I should see "127A, Washington, DC, 20510" on the profile page
    And I should see an image with source "http://www.cruz.senate.gov/files/images/OfficialPortrait.jpg"
