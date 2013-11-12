require_relative 'iban/validator'
require_relative 'swift_bic/bank_db'

module Iban
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :bank_db

    def initialize
      @bank_db = SwiftBic::BankDb
    end
  end

  self.configuration = Configuration.new

  class Ibanizator
    def calculate_iban options
      # Error handling
      # TODO

      # Fill account number to 10 digits
      while options[:account_number].size < 10 do
        options[:account_number].insert(0, '0')
      end

      country_code_num = character_to_digit options[:country_code].to_s
      checksum = calculate_checksum options[:bank_code], options[:account_number], country_code_num

      options[:country_code].to_s.upcase + checksum + options[:bank_code] + options[:account_number]
    end

    def validate_iban iban
      # for the sake of compatibility
      validator = Iban::Validator.new
      validator.validate_iban(iban)
    end

    def bic bank_code
      bank_db = Iban.configuration.bank_db.new(bank_code)
      bank_db.bic
    end

    def bank_name bank_code
      bank_db = Iban.configuration.bank_db.new(bank_code)
      bank_db.bank_name
    end

    def character_to_digit char
      char.upcase!.split('').inject('') { |code, c| code + (c.ord - 55).to_s }
    end

    def calculate_checksum bank_code, account_number, country_code_num
      x = (bank_code + account_number + country_code_num + '00').to_i % 97
      checksum = (98 - x).to_s
      checksum.length == 1 ? checksum.insert(0, '0') : checksum
    end
  end
end