Feature: DataMapper integration

  In order to handle file attachments easily
  As a Ruby developer using DataMapper
  I want to let Adrift do the dirty work

  Scenario: A file is attached
    Given I instantiate a data mapper model
    When I attach a file to it
    And I save it
    Then the file should be stored

  Scenario: A file is attached to an invalid model
    Given I instantiate an invalid data mapper model
    When I attach a file to it
    And I try to save it
    Then it should not be saved
    And the file should not be stored

  Scenario: Two files are attached
    Given I instantiate a data mapper model
    When I attach a file to it
    And I save it
    And I attach another file to it
    And I save it again
    Then the first file should not still be stored
    And the second file should be stored

  Scenario: A file is detached
    Given I instantiate a data mapper model
    When I attach a file to it
    And I save it
    And I detach the file from it
    And I save it
    Then the file should not still be stored

  Scenario: A model with an attached file is destroyed
    Given I instantiate a data mapper model
    When I attach a file to it
    And I save it
    And I destroy it
    Then the file should not still be stored
