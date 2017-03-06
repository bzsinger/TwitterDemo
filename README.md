# Project 5 - *Name of App Here*

Time spent: 15 hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] Tweet Details Page: User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [X] Profile page:
   - [X] Contains the user header view
   - [X] Contains a section with the users basic stats: # tweets, # following, # followers
- [X] Home Timeline: Tapping on a user image should bring up that user's profile page
- [X] Compose Page: User can compose a new tweet by tapping on a compose button.

The following **optional** features are implemented:

- [X] When composing, you should have a countdown in the upper right for the tweet limit.
- [X] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [ ] Profile Page
   - [ ] Implement the paging view for the user description.
   - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [ ] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account

The following **additional** features are implemented:

- [X] Get list of followers
- [X] UI features 
    - [X] Tap to see full stats
    - [X] Alerts for exceeding tweet character limit
    - [X] Open in-tweet link
- [X] Un-favoriting and un-retweeting
- [X] Replying

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Segues with TableViewCells
2. Code cleanup/MVC optimization

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/99fBZfS.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright 2017 Benjamin Singer

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

#Project 4 - TwitterDemo

TwitterDemo is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: 12 hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can sign in using OAuth login flow
- [X] User can view last 20 tweets from their home timeline
- [X] The current signed in user will be persisted across restarts
- [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [X] Retweeting and favoriting should increment the retweet and favorite count.

The following **optional** features are implemented:

- [ ] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [ ] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [X] User can pull to refresh.

- [X] Retweet/favorite of tweets persists across restarts/reloads
- [X] Added time since tweet posted

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. How to navigate external APIs (infinite scroll would result in too many API calls, locking me out)
2. More in-depth discussion of OAuth


## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/HDthO5T.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright 2017 Benjamin Singer

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
