require 'open-uri'
require 'nokogiri'

module Washingtonleg

  class Base
    attr_reader :root_url


    def initialize
      @root_url = BASE_API_URL
      puts "Hello, from the WA Leg .gem"
    end

    # GetLegislationByYear
    # gets all legislation in a year
    # LegislationService.asmx/GetLegislationByYear?year=2012
    def get_legislation_by_year(year)
      response = nodes("#{@root_url}LegislationService.asmx/GetLegislationByYear?year=#{year.to_s}")
      parse_all_bills(response)
    end


    # opens local Bill Summary file and downloads Bill Detail to file
    def loop_and_get_all_bills(year)
      # bills = get_legislation_by_year(year)
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

        # * helper method
    def get_one(bill_number, biennium)
      one_bill = @service.get_legislation(bill_number, biennium).css("ArrayOfLegislation Legislation").last
      File.open("tmp/bill#{bill_number.to_s}.xml", "w") do |f|
        f << one_bill.to_s
      end
      one_bill
    end


    private

    # GetLegislation
    # gets one piece of Legislation in a Biennium
    # LegislationService.asmx/GetLegislation?biennium=2011-12&billNumber=1001
    def get_legislation(bill_number = 0, biennium = "2011-12")
      nodes("#{@root_url}/LegislationService.asmx/GetLegislation?biennium=#{biennium}&billNumber=#{bill_number.to_s}")
    end

    def parse_all_bills(nodes)
      bills = []

      all_legislative_bills = nodes.css("ArrayOfLegislationInfo LegislationInfo") # 4279 records

      all_legislative_bills.each_with_index do |bill, i|
        bill = {
          biennium: bill.css("Biennium").first.text,
          bill_id: bill.css("BillId").first.text,
          bill_number: bill.css("BillNumber").first.text,
          subsitute_version: bill.css("SubstituteVersion").first.text,
          engrossed_version: bill.css("EngrossedVersion").first.text,
          short_legislation_type: bill.css("ShortLegislationType ShortLegislationType").first.text,
          original_agency: bill.css("OriginalAgency").first.text,
          active: bill.css("Active").first.text
        }
        bills << bill

        puts "Bill #{bill[:bill_id]}"
      end

      bills
    end

    def nodes(url)
      response = open(url).read
      puts "Getting #{url}"
      Nokogiri::XML(response)
    end

  end
end
