Feature: Creating an Account
  Background: I have a User
    Given I create a user A

  Scenario: Every Holder should have a default Account
    Then User A has an Account named default
    
  Scenario: Creating a second Accounts with the same name for a Holder returns original account 
    Given User A has an Account named default
    And I create an Account named default for User A
    Then I get the original account

  Scenario: Creating an account takes the holder's currency
    Given I create a user B with currency EUR
    Then User B has an Account named default with currency EUR