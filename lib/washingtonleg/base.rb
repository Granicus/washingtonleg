require 'open-uri'
require 'nokogiri'

module Washingtonleg

  class Base
    attr_reader :root_url, :debug


    def initialize(debug = false)
      @root_url = BASE_API_URL
      @debug = debug
    end

    # GetLegislationByYear
    # LegislationService.asmx/GetLegislationByYear?year=2012
    # gets all legislation in a year
    def get_legislation_by_year(year)
      response = nodes("#{@root_url}LegislationService.asmx/GetLegislationByYear?year=#{year.to_s}")
      parse_all_bills(response)
    end

    # GetLegislation
    # LegislationService.asmx/GetLegislation?biennium=2011-12&billNumber=1001
    # gets one piece of Legislation in a Biennium
    def get_legislation(bill_number = 0, biennium = "2011-12")
      response = nodes("#{@root_url}LegislationService.asmx/GetLegislation?biennium=#{biennium}&billNumber=#{bill_number.to_s}")
      parse_one_bill(response)
    end

    def loop_and_get_all_bills(year)
      detailed_bills = []

      bills = get_legislation_by_year(year)

      bills.each do |bill|
        if bill[:active] # only process Active items
          detailed_bills << get_legislation(bill[:bill_number], bill[:biennium])
          puts "#{bill[:bill_number]}, #{bill[:biennium]}" if @debug
        else
          puts "  ignore inactive Bill #{bill[:bill_number]}" if @debug
        end
      end

      detailed_bills
    end


    private

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

        puts "Bill #{bill[:bill_id]}" if @debug
      end

      bills
    end

    def parse_one_bill(nodes)
      bill = nodes.css("ArrayOfLegislation Legislation").last

      json = {
        biennium: bill.css("Biennium").first.text,
        bill_id: bill.css("BillId").first.text,
        bill_number: bill.css("BillNumber").first.text,
        subsitute_version: bill.css("SubstituteVersion").first.text,
        engrossed_version: bill.css("EngrossedVersion").first.text,
        short_legislation_type: bill.css("ShortLegislationType ShortLegislationType").first.text,
        long_legislation_type: bill.css("ShortLegislationType LongLegislationType").first.text,
        original_agency: bill.css("OriginalAgency").first.text,
        active: bill.css("Active").first.text,
        state_fiscal_note: bill.css("StateFiscalNote").first.text,
        local_fiscal_note: bill.css("LocalFiscalNote").first.text,
        appropriations: bill.css("Appropriations").first.text,
        requested_by_governor: bill.css("RequestedByGovernor").first.text,
        requested_by_budget_committee: bill.css("RequestedByBudgetCommittee").first.text,
        requested_by_department: bill.css("RequestedByDepartment").first.text,
        short_description: bill.css("ShortDescription").first.text,
        request: (bill.css("Request").first ? bill.css("Request").first.text : ""),
        introduced_date: bill.css("IntroducedDate").first.text,
        sponsor: bill.css("Sponsor").first.text,
        # did not include CurrentStatus sub-nodes
        prime_sponsor_id: bill.css("PrimeSponsorID").first.text,
        long_description: bill.css("LongDescription").first.text,
        legal_title: bill.css("LegalTitle").first.text,
        companions: bill.css("Companions").first.text
      }

      File.open("tmp/bill#{json[:bill_number]}.xml", "w") do |f|
        f << bill
      end if @debug

      json
    end

    def nodes(url)
      response = open(url).read
      puts "Getting #{url}" if @debug
      Nokogiri::XML(response)
    end

  end
end
