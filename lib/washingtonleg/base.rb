module Washingtonleg

  # Usage:
  # load 'washingtonleg.rb'
  # s = Washingtonleg::Base.new
  # s.get_legislation_by_year(2012) => Nokogiri nodes for Legislation
  class Base

    attr_reader :root_url

    def initialize
      @root_url = BASE_API_URL
      puts "Hello, from the WA Leg .gem"
    end

    # GetLegislation
    # gets one piece of Legislation in a Biennium
    # LegislationService.asmx/GetLegislation?biennium=2011-12&billNumber=1001
    def get_legislation(bill_number = 0, biennium = "2011-12")
      nodes("#{@root_url}/LegislationService.asmx/GetLegislation?biennium=#{biennium}&billNumber=#{bill_number}")
    end

    # GetLegislationByYear
    # gets all legislation in a year
    # LegislationService.asmx/GetLegislationByYear?year=2012
    def get_legislation_by_year(year)
      nodes("#{@root_url}LegislationService.asmx/GetLegislationByYear?year=#{year}")
    end


    private

    def nodes(url)
      response = open(url).read
      puts "Getting #{url}"
      Nokogiri::XML(response)
    end

  end
end
