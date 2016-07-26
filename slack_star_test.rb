#-------------------------------------------------------------#
# Demo test for starring a message in Slack
#
# Slack star test written by Tom Slattery July 18th 2016
# Purpose: Automate a functional test for starring a message: 
#   * Send a message to Slack by entering text in the box at the bottom of the client.
#   * Your message will appear in the current channel. When you hover over the message, you'll see a star. Click the star.
#   * There is a search field on the upper right. Enter the string has:star in this field and submit it.
#   * Verify that your message appears in the search results.
#   * Click the star icon on the upper right.
#   * Verify that your message appears in this list.
#-------------------------------------------------------------#
    
# the Watir controller
require 'watir'
require 'watir-webdriver'
require 'date'

# setting the message to be unique for each time test is run
slack_message = Time.now.asctime 

# open a browser
browser = Watir::Browser.new

# goto slack.com
browser.goto 'https://enviteclub.slack.com'

# login in slack.com
browser.text_field(:name => 'email').set 'envite.club@gmail.com'
browser.text_field(:name => 'password').set 'noisyforK11'
browser.button(:id => 'signin_btn').click

# Send a message to slack 
browser.text_field(:id => 'message-input').set slack_message
browser.send_keys :enter
sleep 2

# find data-msg-id of message posted
span1 = browser.span(:text => slack_message)
slack_message_id = span1.parent.button.attribute_value('data-msg-id')

# set the variable for finding element by ts-message[id]
ts_message_id = 'msg_' + slack_message_id.gsub(".","_")

# find post, hover over star and then click it
# if current message is the first message or previous message posted was posted greater than 5 minutes ago,
# then ts-message class will contain first
# if ts-message contains first, hover and click star button in div with class=message_content, else
# click star button with slack_message_id
if browser.element(:css, "ts-message[id='#{ts_message_id}'][class~='first']").exists?
    browser.element(:css, "div[class='message_content '] button[data-msg-id='#{slack_message_id}'").hover
    sleep 1
    browser.element(:css, "div[class='message_content '] button[data-msg-id='#{slack_message_id}'").click
    else
    browser.element(:css, "button[data-msg-id='#{slack_message_id}'").hover
    sleep 1
    browser.element(:css, "button[data-msg-id='#{slack_message_id}'").click
end

# Enter the string has:star in search_terms field and submit it.
# Verify that your message appears in the search results.
# Since there is a delay in starred messages showing in search results, test will submit has:star,  
# wait 3 seconds, and the verify message appears in search results.  It will loop through five times.
@has_star_message_search = false
for i in 0..5
    browser.text_field(:id => 'search_terms').set 'has:star'
    browser.send_keys :enter
    sleep 3
    @has_star_message_search = browser.div(:id => 'search_results').text.include? slack_message
    if @has_star_message_search == true
        puts "  Test Passed.  Message appears in the search results for has:star"
        break # if message is found, break loop
    end
end

if @has_star_message_search == false
    puts "  Test Failed.  Message was not found in search results for has:star after 15 seconds"
end

# Click the star icon on the upper right.
# Verify that your message appears in this list.
browser.button(:id => 'stars_toggle').click
if browser.div(:id => 'stars_scroller').text.include? slack_message
    puts "  Test Passed.  Message appears in the search results for click star icon" 
else
    puts "  Test Failed.  Message does not appear in the search results for click star icon"
end

# Close browser
browser.close
