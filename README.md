# Rate Limit
Rate limiting Rails API endpoint by utilising Redis

## Problem Description

For this challenge, you'll start off by creating a new rails application. You can include any gems or other libraries you consider will be helpful but don’t use a gem for the rate limiting.

Create a new controller, perhaps called "home", with an index method. This should return only the text string "ok".

The challenge is to implement rate limiting on this route. Limit it such that a requester can only make 100 requests per hour. After the limit has been reached, return a 429 with the text "Rate limit exceeded. Try again in #{n} seconds".

How you do this is up to you. Think about how easy your rate limiter will be to maintain and control. Write what you consider to be production-quality code, with comments and tests if and when you consider them necessary.

## Dependencies

- Ruby  2.5.1
- Rails 5.2.0

## Install Redis

`brew install redis`

## Start Redis

`brew services start redis`

## Run API server

`rails server`

## Hit the server for 100 times to reach rate limit

`repeat 100 { curl http://localhost:3000/home }`

## And try again last time to see return 429 instead of 200
`curl http://localhost:3000/home`

## Run Tests

`bundle exec rspec`
