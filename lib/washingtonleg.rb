require_relative 'washingtonleg/version'
require_relative 'washingtonleg/base'

module Washingtonleg
  BASE_API_URL = 'http://wslwebservices.leg.wa.gov/'

  require 'json'

  # Purpose:
  # To pull data from WA Leg and push it into CivicIdeas
  #
  # Usage:
  # action = Washingtonleg::Ez.new
  class Ez

    attr_reader :service

    def initialize
      @service = Washingtonleg::Base.new
    end

    # Download Bill Summary from WA Leg
    # Write .json data locally
    #
    # * Step 1
    def parse_all_bills_to_json(year = "2012")
      bills = []

      all_legislative_bills = @service.get_legislation_by_year(year).css("ArrayOfLegislationInfo LegislationInfo") # 4279 records

      all_legislative_bills.each_with_index do |bill, i|
        bills << {
          biennium: bill.css("Biennium").first.text,
          bill_id: bill.css("BillId").first.text,
          bill_number: bill.css("BillNumber").first.text,
          subsitute_version: bill.css("SubstituteVersion").first.text,
          engrossed_version: bill.css("EngrossedVersion").first.text,
          short_legislation_type: bill.css("ShortLegislationType ShortLegislationType").first.text,
          original_agency: bill.css("OriginalAgency").first.text,
          active: bill.css("Active").first.text
        }
      end

      bills
    end

    # opens local Bill Summary file and downloads Bill Detail to file
    #
    # * Step 2
    def loop_and_get_all_bills
      bills = JSON.parse(File.open("tmp/wa_leg_bills.json", "r").read)
      bills[0..9].each do |bill|
        puts "#{bill['bill_number']}, #{bill['biennium']}"
        if bill['active'] == "true" # only process Active items
          get_one(bill["bill_number"], bill["biennium"])
        else
          puts "ignored inactive bill"
        end
      end
    end

    ## Load all 2011-12 Bills
    ## from the local WA Leg files
    ## into CivicIdeas
    ## as AgendaItems
    ##
    ## * Final Step 3
    # rake maintenance:waleg_import


    private

    # download one Bill as .xml and store it locally in /tmp
    #
    # * helper method
    def get_one(bill_number, biennium)
      one_bill = @service.get_legislation(bill_number, biennium).css("ArrayOfLegislation Legislation").last
      File.open("tmp/bill#{bill_number.to_s}.xml", "w") do |f|
        f << one_bill.to_s
      end
      one_bill
    end

  end

end
