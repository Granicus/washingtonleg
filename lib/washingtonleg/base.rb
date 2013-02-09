require 'open-uri'
require 'nokogiri'
require 'active_support/inflector'

module Washingtonleg

  class Base
    attr_reader :url, :debug

    def initialize(debug = false)
      @url = BASE_API_URL
      @url_prefix = 'LegislationService.asmx'
      @debug = debug
    end

    # GetLegislationByYear
    # LegislationService.asmx/GetLegislationByYear?year=2012
    # gets all legislation in a year
    def get_legislation_by_year(year)
      response = nodes("GetLegislationByYear?year=#{year.to_s}")
      parse_bills(response)
    end

    # GetLegislation
    # LegislationService.asmx/GetLegislation?biennium=2011-12&billNumber=1001
    # gets one piece of Legislation in a Biennium
    def get_legislation(bill_number = 0, biennium = '2011-12')
      response = nodes("GetLegislation?biennium=#{biennium}&billNumber=#{bill_number.to_s}")
      parse_bill(response)
    end

    # Call GetLegislation for each bill returned by GetLegislationByYear.
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

    # Get BillId for all bills returned by GetLegislationByYear for a specified year.
    def get_billids(year)
      response = nodes("GetLegislationByYear?year=#{year.to_s}")
      response.css("ArrayOfLegislationInfo > LegislationInfo > BillId").collect { |b| b.text }.sort.uniq.compact
    end

    # GetRecentLegislation
    # GranicusService.asmx/GetRecentLegislation
    # Gets BillId and LongDescription for bills published in the last 48 hours.
    def get_recent_legislation
      response = nodes('GetRecentLegislation', 'GranicusService.asmx')
      response.css('ArrayOfGranicusLegislation > GranicusLegislation').collect { |b| { :bill_id => b.at_css('BillId').text, :long_description => b.at_css('LongDescription').text } }
    end

    private

    def parse_bills(nodes)
      bills = []

      all_legislative_bills = nodes.css("ArrayOfLegislationInfo LegislationInfo")

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

    def parse_bill(nodes)
      bill = nodes.at_css("ArrayOfLegislation Legislation")

      fields = [
        "Biennium",
        "BillId",
        "BillNumber",
        "SubstituteVersion",
        "EngrossedVersion",
        "ShortLegislationType ShortLegislationType",
        "ShortLegislationType LongLegislationType",
        "OriginalAgency",
        "Active",
        "StateFiscalNote",
        "LocalFiscalNote",
        "Appropriations",
        "RequestedByGovernor",
        "RequestedByBudgetCommittee",
        "RequestedByDepartment",
        "ShortDescription",
        "Request",
        "IntroducedDate",
        "Sponsor",
        "PrimeSponsorID",
        "LongDescription",
        "LegalTitle",
        "Companions",
      ]

      json = {}
      fields.each do |f|
        k = f.split[-1].underscore
        v = bill.at_css(f)
        json[k.to_sym] = v ? v.text : nil
      end

      File.open("tmp/bill#{json[:bill_number]}.xml", "w") do |f|
        f << bill
      end if @debug

      json
    end

    def nodes(url, url_prefix = @url_prefix)
      url_prefix = "#{url_prefix.chomp('/')}/" if url_prefix && !url_prefix.empty?
      puts "Getting #{@url.chomp('/')}/#{url_prefix}#{url}" if @debug
      response = open("#{@url.chomp('/')}/#{url_prefix}#{url}").read
      Nokogiri::XML(response)
    end
  end
end
