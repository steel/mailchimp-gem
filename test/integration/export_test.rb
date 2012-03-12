require 'test_helper'

class ExportIntegrationTest < Test::Unit::TestCase
  
  should "send request List Data from the Mailchimp Export API" do
    
    FakeWeb.register_uri(
      :post,
      'http://us2.api.mailchimp.com/export/1.0/list/',
      body: '["Email Address","First Name","Last Name","Salesforce ID","EMAIL_TYPE","MEMBER_RATING","OPTIN_TIME","OPTIN_IP","CONFIRM_TIME","CONFIRM_IP","LATITUDE","LONGITUDE","GMTOFF","DSTOFF","TIMEZONE","CC","REGION","LAST_CHANGED"]
["highgroove@example.com","Daniel","Rice","00Qd0000005MKaEEAW","html",2,"2011-10-06 20:06:46","173.160.74.121","2011-10-06 20:07:28","173.160.74.121","33.7490000","-84.3880000","-5","-4","America\/Kentucky\/Monticello","US","GA","2012-03-12 17:45:18"]
["chimpy@example.com","Daniel","Rice","00Qd0000006AjjtEAC","html",2,"",null,"2012-03-08 20:52:31","173.160.74.121",null,null,null,null,null,null,null,"2012-03-12 17:45:20"]
["wolfbrain@example.com","George P","Burdell","00Qd0000006AjjuEAC","html",2,"",null,"2012-03-08 20:53:10","173.160.74.121",null,null,null,null,null,null,null,"2012-03-12 17:45:22"]'
    )
    
    m = Mailchimp::Export.new('abc123-us2')
    response = m.list(:id => 'xxxxxxxx')
    
    assert_kind_of Enumerator, response
    
  end
  
  should "get campaign subscriber activity" do

    FakeWeb.register_uri(
      :post,
      'http://us2.api.mailchimp.com/export/1.0/campaignSubscriberActivity/',
      body: '{"highgroove@example.com":[{"action":"open","timestamp":"2012-03-12 20:14:17","url":null,"ip":"184.77.22.196"}]} {"wolfbrain@example.com":[{"action":"open","timestamp":"2012-03-12 20:14:20","url":null,"ip":"184.77.22.196"}]}'.to_json
    )
    response = Mailchimp::Export.new('abc123-us2').campaign_subscriber_activity(:id => 'xxxxxxxx')
    
    assert_kind_of Enumerator, response
  end
end