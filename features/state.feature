# features/state.feature
Feature: State functionality
  As a system user
  I want to ensure all state operations work correctly
  So that state data is managed properly

  Background:
    Given no states exist

  Scenario Outline: FIPS code formatting
    Given a state exists with fips_code "<original_code>"
    When I get the standardized FIPS code
    Then the result should be "<expected_code>"

    Examples:
      | original_code | expected_code |
      | 1            | 01            |
      | 6            | 06            |
      | 10           | 10            |
      | 48           | 48            |
      | 0            | 00            |
      | 99           | 99            |

  Scenario: County associations and cascade deletion
    Given a state "California" with fips_code "06"
    And the state has the following counties:
      | name           | fips_code | fips_class |
      | Los Angeles    | 001       | 06         |
      | San Francisco  | 002       | 06         |
      | San Diego     | 003       | 06         |
    When I delete the state
    Then all associated counties should be deleted

  Scenario Outline: State creation with boundary coordinates
    When I create a state with these coordinates:
      | lat_min   | lat_max   | long_min   | long_max   |
      | <lat_min> | <lat_max> | <long_min> | <long_max> |
    Then the creation should be "<result>"

    Examples:
      | lat_min | lat_max | long_min | long_max | result  |
      | 32.5    | 42.0    | -124.4   | -114.1   | success |
      | 42.0    | 32.5    | -114.1   | -124.4   | success |
      | -90     | 90      | -180     | 180      | success |
      | -90.1   | 90      | -180     | 180      | error   |
      | -90     | 90.1    | -180     | 180      | error   |
      | -90     | 90      | -180.1   | 180      | error   |
      | -90     | 90      | -180     | 180.1    | error   |

  Scenario Outline: Territory status handling
    When I create a state with territory status <status>
    Then the territory flag should be correctly set to <status>

    Examples:
      | status |
      | 0      |
      | 1      |
