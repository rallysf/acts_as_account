module ActsAsAccount
  class Posting < ActiveRecord::Base
    self.table_name = "acts_as_account_postings"
    
    belongs_to :account
    belongs_to :other_account, :class_name => 'Account'
    belongs_to :journal
    belongs_to :reference, :polymorphic => true

    before_validation :assign_currency
    validate :same_currency
    validates :currency, :presence => true
    
    scope :debit, -> { where("amount >= 0") }
    scope :credit, -> { where("amount < 0") }
    scope :start_date, lambda { |date|
      where(['DATE(valuta) >= ?', date])
    }
    scope :end_date, lambda { |date|
      where(['DATE(valuta) <= ?', date])
    }

    private
    def same_currency
      errors.add(:currency, "accounts must be the same currency") if account.currency.downcase != other_account.currency.downcase
    end

    def assign_currency
      self.currency = account.currency
    end
  end
end
