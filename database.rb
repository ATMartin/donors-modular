require 'data_mapper'

class Database
  def self.initialize
    DataMapper::Logger.new($stdout, :debug)
    # memory database appears to timeout if not used in ~5 mins, which causes the database to be dumped
    #DataMapper.setup(:default, 'sqlite::memory:')
    DataMapper.setup(:default, 'sqlite:test.db')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.seed_data
    (1..200).each do |donation|
      Donation.create(
        amount: donation,
        paid: false
        )
    end
  end
end

class Donation
  include DataMapper::Resource

  property :id, Serial
  property :amount, Integer
  property :paid, Boolean
end