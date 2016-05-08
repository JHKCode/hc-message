# hc-message

This iOS sample application is testing for extracting contents information in message.
There are 3 types of contents - mentions, emoticons, links.
These information is processed in asynchronously and represented in JSON.

1. You can start to test message that can contain mentions or emoticons or links by tapping the button "Go Message Test"

2. If you input text and tap send button, the text will be displayed on list at top of the view with GRAY background color

3. When extracting contents information from text finish, the contents information will be displayed below the text in JSON format with WHITE background color

4. If there is a link and fetching a title from link failed, the contents information will be displayed below the text in JSON format with RED background color

5. When fetching a title failed, it will retry 2 more times to fetch title

6. If a link has been fetched and title of the link exists, it will use cached title information

7. Emoticons which user input are only valid if it is included on the site, https://www.hipchat.com/emoticons
