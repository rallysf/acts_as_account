module ActsAsAccount
  class Journal < ActiveRecord::Base
    cattr_accessor :account_logger

    self.table_name = "acts_as_account_journals"
    
    has_many :postings
    has_many :accounts, :through => :postings
    
    class << self
      private :new
      private :create
      private :create!

      def current
        Thread.current[:acts_as_account_current] ||= create!
      end
      
      def clear_current
        Thread.current[:acts_as_account_current] = nil
      end
    end
    
    def transfers
      [].tap do |transfers|
        postings.in_groups_of(2) { |postings| transfers << Transfer.new(*postings) }
      end
    end

    def transfer(amount, from_account, to_account, reference = nil, valuta = Time.now)
      log_info("ActsAsAccount::Journal.transfer", reference)
      transaction do
        if (amount < 0) 
          # change order if amount is negative
          amount, from_account, to_account = -amount, to_account, from_account
        end

        logger.debug { "ActsAsAccount::Journal.transfer amount: #{amount} from:#{from_account.id} to:#{to_account.id} reference:#{reference.class.name}(#{reference.id}) valuta:#{valuta}" } if logger
        
        # to avoid possible deadlocks we need to ensure that the locking order is always
        # the same therfore the sort by id. 
        [from_account, to_account].sort_by(&:id).map(&:lock!)
        
        add_posting(-amount,  from_account,   to_account, reference, valuta)
        add_posting( amount,    to_account, from_account, reference, valuta)
      end
    end

    def log_info(message, reference)
      account_logger.info "#{reference.uniqueness_token} #{message}" if account_logger && reference.class.name == "Donation"
    end

    private
    
      def add_posting(amount, account, other_account, reference, valuta)
        posting = postings.build(
          :amount => amount, 
          :account => account, 
          :other_account => other_account,
          :reference => reference,
          :valuta => valuta)

        account.class.update_counters account.id, :postings_count => 1, :balance => posting.amount

        posting_result = posting.save(:validate => false)
        account_update_result = account.save(:validate => false)
        log_info "#{amount} from #{account.holder.name} to #{other_account.holder.name}: posting_result = #{posting_result}, account_update_result = #{account_update_result}", reference
        account_update_result
      end
  end
end
