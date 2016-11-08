# encoding: utf-8

require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Component::Calendar do
  
  context ".occurrences" do
    
    context "all day weekly" do
      
      subject {
        calendars = RiCal.parse_string rectify_ical <<-TEXT
          BEGIN:VCALENDAR
          METHOD:PUBLISH
          VERSION:2.0
          X-WR-CALNAME:iCal Test
          PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
          X-APPLE-CALENDAR-COLOR:#CC73E1
          X-WR-TIMEZONE:Europe/Amsterdam
          CALSCALE:GREGORIAN
          BEGIN:VEVENT
          CREATED:20160621T124137Z
          UID:F299E622-00D3-4399-B010-3B3F845A7FC3
          RRULE:FREQ=WEEKLY;UNTIL=20160730
          DTEND;VALUE=DATE:20160618
          TRANSP:TRANSPARENT
          SUMMARY:Wekelijks hele dag
          DTSTART;VALUE=DATE:20160617
          DTSTAMP:20160621T124209Z
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SEQUENCE:0
          BEGIN:VALARM
          X-WR-ALARMUID:6F24C80B-D99D-40E2-AE5E-7D19FE24B5AA
          UID:6F24C80B-D99D-40E2-AE5E-7D19FE24B5AA
          TRIGGER:-PT15H
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          CREATED:20160621T124137Z
          UID:F299E622-00D3-4399-B010-3B3F845A7FC3
          DTEND;VALUE=DATE:20160625
          TRANSP:TRANSPARENT
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Wekelijks hele dag (vandaag)
          DTSTART;VALUE=DATE:20160624
          DTSTAMP:20160621T124317Z
          SEQUENCE:0
          RECURRENCE-ID;VALUE=DATE:20160624
          BEGIN:VALARM
          X-WR-ALARMUID:6F24C80B-D99D-40E2-AE5E-7D19FE24B5AA
          UID:6F24C80B-D99D-40E2-AE5E-7D19FE24B5AA
          TRIGGER:-PT15H
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          END:VCALENDAR
TEXT
        calendars.first
      }
    
      its(:events) { should have(2).items }
      its(:occurrences) { should have(7).items }
      it {
        subject.occurrences.map(&:summary).should eql([
          "Wekelijks hele dag",
          "Wekelijks hele dag (vandaag)",
          "Wekelijks hele dag",
          "Wekelijks hele dag",
          "Wekelijks hele dag",
          "Wekelijks hele dag",
          "Wekelijks hele dag"
        ])
      }
    end
    
    context "weekly on wednesday with one instance on wednesday" do
      
      subject {
        calendars = RiCal.parse_string rectify_ical <<-TEXT
          BEGIN:VCALENDAR
          METHOD:PUBLISH
          VERSION:2.0
          X-WR-CALNAME:iCal Test
          PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
          X-APPLE-CALENDAR-COLOR:#CC73E1
          X-WR-TIMEZONE:Europe/Amsterdam
          CALSCALE:GREGORIAN
          BEGIN:VTIMEZONE
          TZID:Europe/Amsterdam
          BEGIN:DAYLIGHT
          TZOFFSETFROM:+0100
          RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
          DTSTART:19810329T020000
          TZNAME:CEST
          TZOFFSETTO:+0200
          END:DAYLIGHT
          BEGIN:STANDARD
          TZOFFSETFROM:+0200
          RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
          DTSTART:19961027T030000
          TZNAME:CET
          TZOFFSETTO:+0100
          END:STANDARD
          END:VTIMEZONE
          BEGIN:VEVENT
          CREATED:20160622T152739Z
          UID:0DE7F7E2-ECA9-4D40-964F-84C0B7BE3760
          RRULE:FREQ=WEEKLY
          DTEND;TZID=Europe/Amsterdam:20160622T130000
          TRANSP:OPAQUE
          SUMMARY:Normaal op woensdag 12:00
          DTSTART;TZID=Europe/Amsterdam:20160622T120000
          DTSTAMP:20160622T152753Z
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SEQUENCE:0
          BEGIN:VALARM
          X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
          UID:EBF4F834-8D98-408B-8E29-76E89D90B317
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          CREATED:20160622T152739Z
          UID:0DE7F7E2-ECA9-4D40-964F-84C0B7BE3760
          DTEND;TZID=Europe/Amsterdam:20160630T120000
          TRANSP:OPAQUE
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Nu op donderdag 11:00
          DTSTART;TZID=Europe/Amsterdam:20160630T110000
          DTSTAMP:20160622T152818Z
          SEQUENCE:0
          RECURRENCE-ID;TZID=Europe/Amsterdam:20160629T120000
          BEGIN:VALARM
          X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
          UID:EBF4F834-8D98-408B-8E29-76E89D90B317
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          END:VCALENDAR
  TEXT
        calendars.first
      }
      
      its(:events) { should have(2).items }
      it("should return 2 occurrences for count: 2") {
        subject.occurrences(count: 2).should have(2).items
      }
      it("should return the correct date/times") {
        subject.occurrences(count: 2).map(&:dtstart).map(&:to_s).should eql(%w(
          2016-06-22T12:00:00+02:00
          2016-06-30T11:00:00+02:00
        ))
      }
      it("should return the correct summaries") {
        subject.occurrences(count:2).map(&:summary).should eql([
          'Normaal op woensdag 12:00',
          'Nu op donderdag 11:00'
        ])
      }
      it("should return the correct 4 date/times") {
        subject.occurrences(count: 4).map(&:dtstart).map(&:to_s).should eql(%w(
          2016-06-22T12:00:00+02:00
          2016-06-30T11:00:00+02:00
          2016-07-06T12:00:00+02:00
          2016-07-13T12:00:00+02:00
        ))
      }
      it("should return the correct 4 summaries") {
        subject.occurrences(count:4).map(&:summary).should eql([
          'Normaal op woensdag 12:00',
          'Nu op donderdag 11:00',
          'Normaal op woensdag 12:00',
          'Normaal op woensdag 12:00'          
        ])
      }
    end
    
    context "with starting" do
      subject {
        calendars = RiCal.parse_string rectify_ical <<-TEXT
          BEGIN:VCALENDAR
          METHOD:PUBLISH
          VERSION:2.0
          X-WR-CALNAME:iCal Test
          PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
          X-APPLE-CALENDAR-COLOR:#CC73E1
          X-WR-TIMEZONE:Europe/Amsterdam
          CALSCALE:GREGORIAN
          BEGIN:VTIMEZONE
          TZID:Europe/Amsterdam
          BEGIN:DAYLIGHT
          TZOFFSETFROM:+0100
          RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
          DTSTART:19810329T020000
          TZNAME:CEST
          TZOFFSETTO:+0200
          END:DAYLIGHT
          BEGIN:STANDARD
          TZOFFSETFROM:+0200
          RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
          DTSTART:19961027T030000
          TZNAME:CET
          TZOFFSETTO:+0100
          END:STANDARD
          END:VTIMEZONE
          BEGIN:VEVENT
          CREATED:20160622T152739Z
          UID:0DE7F7E2-ECA9-4D40-964F-84C0B7BE3760
          RRULE:FREQ=WEEKLY
          DTEND;TZID=Europe/Amsterdam:20160622T130000
          TRANSP:OPAQUE
          SUMMARY:Normaal op woensdag 12:00
          DTSTART;TZID=Europe/Amsterdam:20160622T120000
          DTSTAMP:20160622T152753Z
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SEQUENCE:0
          BEGIN:VALARM
          X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
          UID:EBF4F834-8D98-408B-8E29-76E89D90B317
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          CREATED:20160622T152739Z
          UID:0DE7F7E2-ECA9-4D40-964F-84C0B7BE3760
          DTEND;TZID=Europe/Amsterdam:20160629T120000
          TRANSP:OPAQUE
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Nu op woensdag 11:00
          DTSTART;TZID=Europe/Amsterdam:20160629T110000
          DTSTAMP:20160622T152818Z
          SEQUENCE:0
          RECURRENCE-ID;TZID=Europe/Amsterdam:20160629T120000
          BEGIN:VALARM
          X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
          UID:EBF4F834-8D98-408B-8E29-76E89D90B317
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          END:VCALENDAR
  TEXT
        calendars.first
      }

      it("should return correct date/times with `starting` set") {
        subject.occurrences(starting: Time.parse("2016-06-29T11:30:00+02:00"), count: 3).map(&:dtstart).map(&:to_s).should eql(%w(
          2016-07-06T12:00:00+02:00
          2016-07-13T12:00:00+02:00
          2016-07-20T12:00:00+02:00
        ))
      }
      
    end
    
    context "complex" do
      subject {
        calendars = RiCal.parse_string rectify_ical <<-TEXT
          BEGIN:VCALENDAR
          METHOD:PUBLISH
          VERSION:2.0
          X-WR-CALNAME:iCal Test
          PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
          X-APPLE-CALENDAR-COLOR:#CC73E1
          X-WR-TIMEZONE:Europe/Amsterdam
          CALSCALE:GREGORIAN
          BEGIN:VTIMEZONE
          TZID:Europe/Amsterdam
          BEGIN:DAYLIGHT
          TZOFFSETFROM:+0100
          RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
          DTSTART:19810329T020000
          TZNAME:CEST
          TZOFFSETTO:+0200
          END:DAYLIGHT
          BEGIN:STANDARD
          TZOFFSETFROM:+0200
          RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
          DTSTART:19961027T030000
          TZNAME:CET
          TZOFFSETTO:+0100
          END:STANDARD
          END:VTIMEZONE
          BEGIN:VEVENT
          TRANSP:OPAQUE
          DTEND;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160616T201000
          UID:15272224
          EXDATE;TZID=Europe/Amsterdam:20160714T200000
          DTSTAMP;VALUE=DATE-TIME:20160616T120830Z
          SEQUENCE:0
          CATEGORIES:RECURRENCE
          COMMENT:15272224-master
          SUMMARY:Test
          DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160616T200000
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          CREATED:20160616T203425Z
          RRULE:FREQ=WEEKLY;BYDAY=TH
          BEGIN:VALARM
          X-WR-ALARMUID:B10FD1A0-EC38-48C1-A20F-47F5CFD95F52
          UID:B10FD1A0-EC38-48C1-A20F-47F5CFD95F52
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          TRANSP:OPAQUE
          DTEND;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160630T201000
          UID:15272224
          DTSTAMP;VALUE=DATE-TIME:20160616T152912Z
          SEQUENCE:0
          CATEGORIES:RECURRENCE_EXCEPTION
          COMMENT:15272243-child\; 15272224-master
          RECURRENCE-ID;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160630T200000
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Test 3
          DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160630T200000
          CREATED:20160622T212700Z
          BEGIN:VALARM
          X-WR-ALARMUID:6F5DCF00-2117-4981-8EE4-B4E8BA23CD0F
          UID:6F5DCF00-2117-4981-8EE4-B4E8BA23CD0F
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          TRANSP:OPAQUE
          DTEND;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160623T201000
          UID:15272224
          DTSTAMP;VALUE=DATE-TIME:20160616T152908Z
          SEQUENCE:0
          CATEGORIES:RECURRENCE_EXCEPTION
          COMMENT:15272242-child\; 15272224-master
          RECURRENCE-ID;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160623T200000
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Test 2
          DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160623T200000
          CREATED:20160622T212700Z
          BEGIN:VALARM
          X-WR-ALARMUID:DC374FCD-4A8D-406C-8A57-D1B78F6F8974
          UID:DC374FCD-4A8D-406C-8A57-D1B78F6F8974
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          TRANSP:OPAQUE
          DTEND;TZID=Europe/Amsterdam:20160706T181000
          UID:15272224
          DTSTAMP:20160622T212736Z
          SEQUENCE:0
          CATEGORIES:RECURRENCE
          COMMENT:15272224-master
          RECURRENCE-ID;TZID=Europe/Amsterdam:20160707T200000
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Test Woensdag 18:00
          DTSTART;TZID=Europe/Amsterdam:20160706T180000
          CREATED:20160616T203425Z
          BEGIN:VALARM
          X-WR-ALARMUID:B10FD1A0-EC38-48C1-A20F-47F5CFD95F52
          UID:B10FD1A0-EC38-48C1-A20F-47F5CFD95F52
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          TRANSP:OPAQUE
          DTEND;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160616T201000
          UID:15272224
          DTSTAMP;VALUE=DATE-TIME:20160616T152904Z
          SEQUENCE:0
          CATEGORIES:RECURRENCE_EXCEPTION
          COMMENT:15272241-child\; 15272224-master
          RECURRENCE-ID;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160616T200000
          X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
          SUMMARY:Test 1
          DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160616T200000
          CREATED:20160622T212700Z
          BEGIN:VALARM
          X-WR-ALARMUID:043C451B-5DBB-42B3-9737-1726CA8D4667
          UID:043C451B-5DBB-42B3-9737-1726CA8D4667
          TRIGGER:-PT10M
          X-APPLE-DEFAULT-ALARM:TRUE
          ATTACH;VALUE=URI:Basso
          ACTION:AUDIO
          END:VALARM
          END:VEVENT
          END:VCALENDAR
TEXT
        calendars.first
      }
      
      its(:events) { should have(5).items }
      it {
        subject.occurrences(count: 8).should have(8).items
      }
      it {
        subject.occurrences(count: 6).map(&:summary).should eql([
            "Test 1", # instance summary
            "Test 2", # instance summary
            "Test 3", # instance summary
            "Test Woensdag 18:00", # instance different day, time, summary
            "Test", # recurring
            "Test"  # recurring
        ])
      }
      it {
        subject.occurrences(starting: Time.parse("2016-06-16T20:00:01+02:00"), count: 6).map(&:summary).should eql([
            "Test 2", # instance summary
            "Test 3", # instance summary
            "Test Woensdag 18:00", # instance different day, time, summary
            "Test", # recurring
            "Test", # recurring
            "Test", # recurring
        ])
      }
      it {
        subject.occurrences(starting: Time.parse("2016-06-16T20:00:01+02:00"), before: Time.parse("2016-07-21T20:00:00+02:00")).map(&:summary).should eql([
            "Test 2", # instance summary
            "Test 3", # instance summary
            "Test Woensdag 18:00", # instance different day, time, summary
        ])
      }
      it {
        subject.occurrences(count: 6).map(&:dtstart).map(&:to_s).should eql(%w(
          2016-06-16T20:00:00+02:00
          2016-06-23T20:00:00+02:00
          2016-06-30T20:00:00+02:00
          2016-07-06T18:00:00+02:00          
          2016-07-21T20:00:00+02:00          
          2016-07-28T20:00:00+02:00          
        ))
      }
      
      it {
        subject.occurrences(count: 6).map(&:recurrence_id).map(&:to_s).should eql([
          "2016-06-16T20:00:00+02:00",
          "2016-06-23T20:00:00+02:00",
          "2016-06-30T20:00:00+02:00",
          "2016-07-07T20:00:00+02:00",
          "",
          ""
        ])
      }

      it {
        subject.occurrences(count: 6).map(&:recurrence_id).map(&:to_s).should eql([
          "2016-06-16T20:00:00+02:00",
          "2016-06-23T20:00:00+02:00",
          "2016-06-30T20:00:00+02:00",
          "2016-07-07T20:00:00+02:00",
          "",
          ""
        ])
      }
    
    end
    
    context "3gk-kerktijden" do
      subject {
        cal = File.open(File.join(File.dirname(__FILE__), %w[.. .. sample_ical_files 3gk-kerktijden.ics])) do |file|
          RiCal.parse(file)
        end.first
      }
      
      its(:events) { should have(22).items }

      it {
        subject.occurrences.map{ |o| [o.dtstart.to_s, o.summary].join(' ') }.should eql([
          "2016-06-26T10:00:00+02:00  ds. E. Everts - Heilig Avondmaal",
          "2016-06-26T16:30:00+02:00  ds. E. Everts - Heilig Avondmaal",
          "2016-07-03T10:00:00+02:00  ds. J. Verhage",
          "2016-07-03T16:30:00+02:00  ds. E. Everts",
          "2016-07-10T10:00:00+02:00  ds. A. J. Mol",
          "2016-07-10T16:30:00+02:00  ds. E. Everts",
          "2016-07-17T10:00:00+02:00  ds. W. M. van Wijk",
          "2016-07-17T16:30:00+02:00  stud. S. Biewenga",
          "2016-07-24T10:00:00+02:00  dhr. N. Weeda",
          "2016-07-24T16:30:00+02:00  ds. W. M. van Wijk",
          "2016-07-31T10:00:00+02:00  ds. M. Oppenhuizen",
          "2016-07-31T16:30:00+02:00  ds. W. M. van Wijk - Heilige Doop",
          "2016-08-07T10:00:00+02:00  ds. J. Verhage",
          "2016-08-07T16:30:00+02:00  stud. S. Biewenga",
          "2016-08-14T10:00:00+02:00  ds. W. M. van Wijk",
          "2016-08-14T16:30:00+02:00  ds. E. Everts",
          "2016-08-21T10:00:00+02:00  prof. dr. E.A. de Boer",
          "2016-08-21T16:30:00+02:00  ds. W. Smouter",
          "2016-08-28T10:00:00+02:00  ds. J. Dekker",
          "2016-08-28T16:30:00+02:00  ds. W. M. van Wijk",
          "2016-09-04T10:00:00+02:00  ds. W. M. van Wijk",
          "2016-09-04T16:30:00+02:00  ds. W. A. Scheffer",
        ])
      }
      
      it {
        subject.occurrences(starting: Time.parse('2016-07-24 10:00:00'), count: 4).map{ |o| [o.dtstart.to_s, o.summary].join(' ') }.should eql([
          "2016-07-24T10:00:00+02:00  dhr. N. Weeda",
          "2016-07-24T16:30:00+02:00  ds. W. M. van Wijk",
          "2016-07-31T10:00:00+02:00  ds. M. Oppenhuizen",
          "2016-07-31T16:30:00+02:00  ds. W. M. van Wijk - Heilige Doop",
        ])
      }

    end

  end
  
  context "move all daily events to start of recurrence" do
    subject {
      calendars = RiCal.parse_string rectify_ical <<-TEXT
        BEGIN:VCALENDAR
        METHOD:PUBLISH
        VERSION:2.0
        X-WR-CALNAME:iCal Test
        PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
        X-APPLE-CALENDAR-COLOR:#CC73E1
        X-WR-TIMEZONE:Europe/Amsterdam
        CALSCALE:GREGORIAN
        BEGIN:VTIMEZONE
        TZID:Europe/Amsterdam
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+0100
        RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
        DTSTART:19810329T020000
        TZNAME:CEST
        TZOFFSETTO:+0200
        END:DAYLIGHT
        BEGIN:STANDARD
        TZOFFSETFROM:+0200
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
        DTSTART:19961027T030000
        TZNAME:CET
        TZOFFSETTO:+0100
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        CREATED:20160629T143322Z
        UID:7B787DC7-DE62-4CAC-832C-114046808317
        RRULE:FREQ=DAILY;UNTIL=20160703T215959Z
        DTEND;TZID=Europe/Amsterdam:20160627T140000
        EXDATE;TZID=Europe/Amsterdam:20160627T130000
        EXDATE;TZID=Europe/Amsterdam:20160703T130000
        TRANSP:OPAQUE
        SUMMARY:Dagelijks
        DTSTART;TZID=Europe/Amsterdam:20160627T130000
        DTSTAMP:20160629T143422Z
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SEQUENCE:0
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T143322Z
        UID:7B787DC7-DE62-4CAC-832C-114046808317
        DTEND;TZID=Europe/Amsterdam:20160627T190000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Dagelijks
        DTSTART;TZID=Europe/Amsterdam:20160627T180000
        DTSTAMP:20160629T143443Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160701T130000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T143322Z
        UID:7B787DC7-DE62-4CAC-832C-114046808317
        DTEND;TZID=Europe/Amsterdam:20160627T180000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Dagelijks
        DTSTART;TZID=Europe/Amsterdam:20160627T170000
        DTSTAMP:20160629T143440Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160630T130000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T143322Z
        UID:7B787DC7-DE62-4CAC-832C-114046808317
        DTEND;TZID=Europe/Amsterdam:20160627T200000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Dagelijks
        DTSTART;TZID=Europe/Amsterdam:20160627T190000
        DTSTAMP:20160629T143448Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160702T130000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T143322Z
        UID:7B787DC7-DE62-4CAC-832C-114046808317
        DTEND;TZID=Europe/Amsterdam:20160627T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Dagelijks
        DTSTART;TZID=Europe/Amsterdam:20160627T150000
        DTSTAMP:20160629T143414Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160628T130000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T143322Z
        UID:7B787DC7-DE62-4CAC-832C-114046808317
        DTEND;TZID=Europe/Amsterdam:20160627T170000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Dagelijks
        DTSTART;TZID=Europe/Amsterdam:20160627T160000
        DTSTAMP:20160629T143436Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160629T130000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        END:VCALENDAR
TEXT
      calendars.first
    }
    its(:events) { should have(6).items }
    its(:occurrences) { should have(5).items }
    it {
      subject.occurrences.map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-27T15:00:00+02:00
        2016-06-27T16:00:00+02:00
        2016-06-27T17:00:00+02:00
        2016-06-27T18:00:00+02:00
        2016-06-27T19:00:00+02:00
       ))
    }
  end
  
  context "master event vanishes because instance has same dtstart" do
    subject {
      calendars = RiCal.parse_string rectify_ical <<-TEXT
        BEGIN:VCALENDAR
        METHOD:PUBLISH
        VERSION:2.0
        X-WR-CALNAME:iCal Test
        PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
        X-APPLE-CALENDAR-COLOR:#CC73E1
        X-WR-TIMEZONE:Europe/Amsterdam
        CALSCALE:GREGORIAN
        BEGIN:VTIMEZONE
        TZID:Europe/Amsterdam
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+0100
        RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
        DTSTART:19810329T020000
        TZNAME:CEST
        TZOFFSETTO:+0200
        END:DAYLIGHT
        BEGIN:STANDARD
        TZOFFSETFROM:+0200
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
        DTSTART:19961027T030000
        TZNAME:CET
        TZOFFSETTO:+0100
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        RRULE:FREQ=DAILY;UNTIL=20160703T215959Z
        DTEND;TZID=Europe/Amsterdam:20160628T150000
        TRANSP:OPAQUE
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160628T140000
        DTSTAMP:20160629T144442Z
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SEQUENCE:0
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        DTEND;TZID=Europe/Amsterdam:20160627T200000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T190000
        DTSTAMP:20160629T144429Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160702T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        DTEND;TZID=Europe/Amsterdam:20160627T210000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T200000
        DTSTAMP:20160629T144434Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160703T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        DTEND;TZID=Europe/Amsterdam:20160627T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T150000
        DTSTAMP:20160629T144415Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160628T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        DTEND;TZID=Europe/Amsterdam:20160627T170000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T160000
        DTSTAMP:20160629T144419Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160629T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        DTEND;TZID=Europe/Amsterdam:20160627T190000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T180000
        DTSTAMP:20160629T144425Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160701T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T144341Z
        UID:800EEF89-A5BC-4879-AFC7-ABA71C4ED8C0
        DTEND;TZID=Europe/Amsterdam:20160627T180000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T170000
        DTSTAMP:20160629T144422Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160630T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        END:VCALENDAR
TEXT
      calendars.first
    }
    its(:events) { should have(7).items }
    its(:occurrences) { should have(6).items }
    it {
      subject.occurrences.map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-27T15:00:00+02:00
        2016-06-27T16:00:00+02:00
        2016-06-27T17:00:00+02:00
        2016-06-27T18:00:00+02:00
        2016-06-27T19:00:00+02:00
        2016-06-27T20:00:00+02:00
       ))
    }
  end
  
  context "move two events outside range" do
    subject {
      calendars = RiCal.parse_string rectify_ical <<-TEXT
        BEGIN:VCALENDAR
        METHOD:PUBLISH
        VERSION:2.0
        X-WR-CALNAME:iCal Test
        PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
        X-APPLE-CALENDAR-COLOR:#CC73E1
        X-WR-TIMEZONE:Europe/Amsterdam
        CALSCALE:GREGORIAN
        BEGIN:VTIMEZONE
        TZID:Europe/Amsterdam
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+0100
        RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
        DTSTART:19810329T020000
        TZNAME:CEST
        TZOFFSETTO:+0200
        END:DAYLIGHT
        BEGIN:STANDARD
        TZOFFSETFROM:+0200
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
        DTSTART:19961027T030000
        TZNAME:CET
        TZOFFSETTO:+0100
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        CREATED:20160629T145941Z
        UID:00BDE080-FD26-41DC-87FB-8CD0F6682F1F
        RRULE:FREQ=DAILY;UNTIL=20160703T215959Z
        DTEND;TZID=Europe/Amsterdam:20160627T150000
        TRANSP:OPAQUE
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T140000
        DTSTAMP:20160629T150839Z
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SEQUENCE:0
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T145941Z
        UID:00BDE080-FD26-41DC-87FB-8CD0F6682F1F
        DTEND;TZID=Europe/Amsterdam:20160705T150000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160705T140000
        DTSTAMP:20160629T150943Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160703T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T145941Z
        UID:00BDE080-FD26-41DC-87FB-8CD0F6682F1F
        DTEND;TZID=Europe/Amsterdam:20160621T150000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160621T140000
        DTSTAMP:20160629T150915Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160628T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T145941Z
        UID:00BDE080-FD26-41DC-87FB-8CD0F6682F1F
        DTEND;TZID=Europe/Amsterdam:20160627T150000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Nieuwe activiteit
        DTSTART;TZID=Europe/Amsterdam:20160627T140000
        DTSTAMP:20160629T150305Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160627T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        END:VCALENDAR
TEXT
      calendars.first
    }
    its(:events) { should have(4).items }
    its(:occurrences) { should have(7).items }
    it {
      subject.occurrences.map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-21T14:00:00+02:00
        2016-06-27T14:00:00+02:00
        2016-06-29T14:00:00+02:00
        2016-06-30T14:00:00+02:00
        2016-07-01T14:00:00+02:00
        2016-07-02T14:00:00+02:00
        2016-07-05T14:00:00+02:00
       ))
    }
  end
  
  context "all recurring instances moved individually, one removed" do
    subject {
      calendars = RiCal.parse_string rectify_ical <<-TEXT
        BEGIN:VCALENDAR
        METHOD:PUBLISH
        VERSION:2.0
        X-WR-CALNAME:iCal Test
        PRODID:-//Apple Inc.//Mac OS X 10.11.5//EN
        X-APPLE-CALENDAR-COLOR:#CC73E1
        X-WR-TIMEZONE:Europe/Amsterdam
        CALSCALE:GREGORIAN
        BEGIN:VTIMEZONE
        TZID:Europe/Amsterdam
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+0100
        RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
        DTSTART:19810329T020000
        TZNAME:CEST
        TZOFFSETTO:+0200
        END:DAYLIGHT
        BEGIN:STANDARD
        TZOFFSETFROM:+0200
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
        DTSTART:19961027T030000
        TZNAME:CET
        TZOFFSETTO:+0100
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        RRULE:FREQ=DAILY;UNTIL=20160703T215959Z
        DTEND;TZID=Europe/Amsterdam:20160627T150000
        EXDATE;TZID=Europe/Amsterdam:20160630T140000
        TRANSP:OPAQUE
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160627T140000
        DTSTAMP:20160629T151505Z
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SEQUENCE:0
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        DTEND;TZID=Europe/Amsterdam:20160701T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160701T150000
        DTSTAMP:20160629T151937Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160701T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        DTEND;TZID=Europe/Amsterdam:20160628T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160628T150000
        DTSTAMP:20160629T151932Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160628T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        DTEND;TZID=Europe/Amsterdam:20160702T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160702T150000
        DTSTAMP:20160629T151940Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160702T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        DTEND;TZID=Europe/Amsterdam:20160630T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160630T150000
        DTSTAMP:20160629T151934Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160629T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        DTEND;TZID=Europe/Amsterdam:20160627T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160627T150000
        DTSTAMP:20160629T151928Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160703T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        BEGIN:VEVENT
        CREATED:20160629T151449Z
        UID:FCA6E456-4D2B-447A-8794-D8A39B841655
        DTEND;TZID=Europe/Amsterdam:20160629T160000
        TRANSP:OPAQUE
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:Daily
        DTSTART;TZID=Europe/Amsterdam:20160629T150000
        DTSTAMP:20160629T151934Z
        SEQUENCE:0
        RECURRENCE-ID;TZID=Europe/Amsterdam:20160627T140000
        BEGIN:VALARM
        X-WR-ALARMUID:EBF4F834-8D98-408B-8E29-76E89D90B317
        UID:EBF4F834-8D98-408B-8E29-76E89D90B317
        TRIGGER:-PT10M
        X-APPLE-DEFAULT-ALARM:TRUE
        ATTACH;VALUE=URI:Basso
        ACTION:AUDIO
        END:VALARM
        END:VEVENT
        END:VCALENDAR
TEXT
      calendars.first
    }
    its(:events) { should have(7).items }
    its(:occurrences) { should have(6).items }
    it {
      subject.occurrences.map(&:dtstart).map(&:to_s).should eql(%w(
        2016-06-27T15:00:00+02:00
        2016-06-28T15:00:00+02:00
        2016-06-29T15:00:00+02:00
        2016-06-30T15:00:00+02:00
        2016-07-01T15:00:00+02:00
        2016-07-02T15:00:00+02:00
       ))
    }
  end
  
  context "with count <= 0" do
    subject {
      RiCal.Calendar do |cal|
        cal.event do |event|
          event.dtstart = Time.parse("2016-06-27T15:00:00+02:00")
          event.rrule   = "FREQ=WEEKLY"
        end
      end
    }
    it {
      lambda {
        subject.occurrences
      }.should raise_error(/This component is unbounded/)
    }
    it {
      subject.occurrences(count:-1).should be_empty
    }
    it {
      subject.occurrences(count:0).should be_empty
    }
    it {
      subject.occurrences(count:10).should have(10).items
    }
  end
  
  context "with first event changed in time" do
    subject {
      RiCal.parse_string(rectify_ical(<<-TEXT
          BEGIN:VCALENDAR
          PRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN
          CALSCALE:GREGORIAN
          VERSION:2.0
          BEGIN:VEVENT
          DTEND;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160915T101000
          DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160915T100000
          DTSTAMP;VALUE=DATE-TIME:20160915T090850Z
          UID:15279167-mp3
          SUMMARY:Dagelijks 10:00
          RRULE:FREQ=WEEKLY;BYDAY=TH
          CLASS:PUBLIC
          RELATED-TO:RELTYPE=SELF:15279167
          BEGIN:VALARM
          TRIGGER:+PT0M
          END:VALARM
          END:VEVENT
          BEGIN:VEVENT
          DTEND;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160915T112000
          DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160915T111000
          RECURRENCE-ID;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160915T100000
          DTSTAMP;VALUE=DATE-TIME:20160915T090942Z
          UID:15279167-mp3
          SUMMARY:Vandaag 11:10
          CLASS:PUBLIC
          RELATED-TO:RELTYPE=SELF:15279168
          RELATED-TO:RELTYPE=PARENT:15279167
          BEGIN:VALARM
          TRIGGER:+PT0M
          END:VALARM
          END:VEVENT
          BEGIN:VTIMEZONE
          TZID;X-RICAL-TZSOURCE=TZINFO:Europe/Amsterdam
          BEGIN:DAYLIGHT
          RDATE:20160327T020000
          TZOFFSETTO:+0200
          DTSTART;VALUE=DATE-TIME:20160327T020000
          TZNAME:CEST
          TZOFFSETFROM:+0100
          END:DAYLIGHT
          END:VTIMEZONE
          END:VCALENDAR
        TEXT
      )).first
    }
    
    its(:events) { should have(2).items }
    it {
      subject.occurrences(
        starting: Time.parse("2016-09-15 10:59:45 +0200"), count: 3).map(&:dtstart).map(&:to_s).should eql(%w(
          2016-09-15T11:10:00+02:00
          2016-09-22T10:00:00+02:00
          2016-09-29T10:00:00+02:00
        )
      )
    }
  end
end
