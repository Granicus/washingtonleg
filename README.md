# WashingtonLeg

## About
This ruby .gem is developed to interface with Washington Legislature's Web Services at http://wslwebservices.leg.wa.gov.

WA Leg has an API, written in .NET, that delivers XML for the Data Objects described below.

## Data Objects

http://wslwebservices.leg.wa.gov/#_Executive_Summary

Service Name | Description
Amendments | Bill being amended, chamber in which amendment was offered, amendment type, floor number, sponsor, etc.
Committees  | Chamber, name of committee, committee acronym.
Committee actions | Committee actions.
Committee meetings  | Date, time, and location of committee meetings and the bills scheduled to be heard.
Documents | Document name, type (bill, amendment, bill report, etc.), document name translated into English, the URLs of the HTML and PDF versions of the document.
Legislation | Bill number, current status, bill history, sponsors.
RCW cite affected | Which sections of the RCW a bill affects.
Session law | The session law number of any bill passed by the Legislature, its effective date, veto information, etc.
Sponsors | Chamber, name of sponsor, sponsor acronym.

## Installation

Add this line to your application's Gemfile:

    gem 'washingtonleg'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install washingtonleg

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
