# encoding: utf-8

require File.join(File.dirname(__FILE__), %w[.. spec_helper])

def generate_calendar(fixtures)
  RiCal.Calendar do
    fixtures.each do |recurring, overrides|
      uid = ('a'..'z').to_a.shuffle[0,16].join
      dtstart, rrule = recurring.split('#')
      event do |e|
        e.uid = uid
        e.dtstart = Time.parse(dtstart)
        e.rrule = rrule if rrule
      end
      overrides.each do |dtfrom, dtto|
        event do |e|
          e.uid = uid
          e.dtstart = Time.parse(dtto)
          e.recurrence_id = Time.parse(dtfrom)
        end
      end
    end
  end
end

describe RiCal::Component::Calendar do
  
  context "move first override before range" do
    let(:range) { { starting: Time.parse("2016-06-26"), count: 4 } }
    subject {
      generate_calendar(
        "Jun 26, 2016 16:30:00#FREQ=DAILY" => {
          "Jun 26, 2016 16:30:00" => "Jun 25, 2016 12:00:00" # move to previous day
        }
      )
    }
    
    its(:events) { should have(2).items }
  
    it("should return four events from the 27th") {
      subject.occurrences(range).map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-27T16:30:00+00:00
        2016-06-28T16:30:00+00:00
        2016-06-29T16:30:00+00:00
        2016-06-30T16:30:00+00:00
      ))
    }
  end
  
  context "move last event in range to a later date outside range/count" do
    let(:range) { { starting: Time.parse("2016-06-27"), count: 4 } }
    subject {
      generate_calendar(
        "Jun 26, 2016 16:30:00#FREQ=DAILY" => {
          "Jun 29, 2016 16:30:00" => "Jul 03, 2016 12:00:00"
        }
      )
    }
    
    its(:events) { should have(2).items }
  
    it("should return events on 27/6, 28/6, 30/6 and 1/7") {
      subject.occurrences(range).map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-27T16:30:00+00:00
        2016-06-28T16:30:00+00:00
        2016-06-30T16:30:00+00:00
        2016-07-01T16:30:00+00:00
      ))
    }
  
  end
  
  context "move all but last event out of range" do
    let(:range) { { starting: Time.parse("2016-06-26"), before: Time.parse("2016-07-03") } }
    subject {
      generate_calendar(
        "Jun 26, 2016 16:30:00#FREQ=DAILY" => {
          "Jun 26, 2016 16:30:00" => "Jun 03, 2016 12:00:00",
          "Jun 27, 2016 16:30:00" => "Jun 04, 2016 12:00:00",
          "Jun 28, 2016 16:30:00" => "Jun 05, 2016 12:00:00",
          "Jun 29, 2016 16:30:00" => "Jun 06, 2016 12:00:00",
          "Jun 30, 2016 16:30:00" => "Jun 07, 2016 12:00:00",
          "Jul 01, 2016 16:30:00" => "Jun 08, 2016 12:00:00",
          "Jul 02, 2016 16:30:00" => "Jul 02, 2016 12:00:00"
        }
      )
    }
    
    its(:events) { should have(8).items }
  
    it("should return the only event remaining in the range") {
      subject.occurrences(range).map(&:dtstart).map(&:to_s).should eql(["2016-07-02T12:00:00+00:00"])
    }
  
  end
  
  context "move overrides into empty range" do
    let(:range) { { starting: Time.parse("2016-06-26"), before: Time.parse("2016-07-03") } }
    subject {
      generate_calendar(
        "Jul 03, 2016 16:30:00#FREQ=DAILY" => {
          "Jul 03, 2016 16:30:00" => "Jun 26, 2016 12:00:00",
          "Jul 04, 2016 16:30:00" => "Jun 27, 2016 12:00:00",
          "Jul 05, 2016 16:30:00" => "Jun 28, 2016 12:00:00",
          "Jul 06, 2016 16:30:00" => "Jun 29, 2016 12:00:00",
          "Jul 07, 2016 16:30:00" => "Jun 30, 2016 12:00:00",
          "Jul 08, 2016 16:30:00" => "Jul 01, 2016 12:00:00",
          "Jul 09, 2016 16:30:00" => "Jul 02, 2016 12:00:00"
        }
      )
    }
  
    its(:events) { should have(8).items }
  
    it("should return all events now in range") {
      subject.occurrences(range).map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-26T12:00:00+00:00
        2016-06-27T12:00:00+00:00
        2016-06-28T12:00:00+00:00
        2016-06-29T12:00:00+00:00
        2016-06-30T12:00:00+00:00
        2016-07-01T12:00:00+00:00
        2016-07-02T12:00:00+00:00
      ))
    }
  end
  
  context "should distinguish coincident events" do
    let(:range) { { starting: Time.parse("2016-06-26"), count: 8 } }
    subject {
      generate_calendar(
        "Jun 26, 2016 10:00:00#FREQ=DAILY#1" => {
          "Jun 26, 2016 10:00:00" => "Jun 26, 2016 09:30:00",
          "Jun 27, 2016 10:00:00" => "Jun 27, 2016 09:30:00"
        },
        "Jun 26, 2016 10:00:00#FREQ=DAILY#2" => {
          "Jun 28, 2016 10:00:00" => "Jun 28, 2016 16:30:00",
          "Jun 29, 2016 10:00:00" => "Jun 29, 2016 16:30:00"
        },
      )
    }
    
    its(:events) { should have(6).items }

    it("should return the only event remaining in the range") {
      subject.occurrences(range).map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-26T09:30:00+00:00
        2016-06-26T10:00:00+00:00
        2016-06-27T09:30:00+00:00
        2016-06-27T10:00:00+00:00
        2016-06-28T10:00:00+00:00
        2016-06-28T16:30:00+00:00
        2016-06-29T10:00:00+00:00
        2016-06-29T16:30:00+00:00
      ))
    }
  
  end
  
  context "should return correct next occurrence" do
    let(:range) { { starting: Time.parse("2016-06-26"), count: 1 } }
    subject {
      generate_calendar(
        "Jun 26, 2016 10:00:00#FREQ=DAILY" => {
          "Jun 26, 2016 10:00:00" => "Jun 29, 2016 09:30:00",
          "Jun 27, 2016 10:00:00" => "Jun 28, 2016 09:30:00",
          "Jun 28, 2016 10:00:00" => "Jun 27, 2016 09:30:00",
          "Jun 29, 2016 10:00:00" => "Jun 26, 2016 09:30:00",
        }
      )
    }
    it("should return correct next instance") {
      subject.occurrences(range).map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-26T09:30:00+00:00
      ))
    }
  end

end
