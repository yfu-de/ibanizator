require_relative 'lengths'

module Iban
  class Validator
    def validate_iban(input)
      iban = sanitize_input(input)

      valid_length?(iban) && valid_checksum?(iban)
    end

    private

    def valid_length?(iban)
      return false if iban.length <= 4 # two digits for the country code and two for the checksum
      country_code = iban[0..1].upcase.to_sym
      iban.length == LENGTHS[country_code]
    end

    def sanitize_input(input)
      input.to_s.chomp.gsub(/\s+/,"")
    end

    def valid_checksum?(iban)
      number_representation = integerize(reorder(iban))
      number_representation % 97 == 1
    end

    def reorder(iban)
      "#{iban[4..-1]}#{iban[0..3]}"
    end

    def integerize(iban)
      iban.gsub(/[A-Z]/) do |match|
        match.ord - 'A'.ord + 10
      end.to_i
    end
  end
end
