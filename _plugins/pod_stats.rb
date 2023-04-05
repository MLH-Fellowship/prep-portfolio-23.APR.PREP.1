# frozen_string_literal: true

##
# Fetches Github stats data for each fellow and injects it into the
# stats template
module PodStats
  require 'net/http'
  require 'json'
  class StatsGenerator < Jekyll::Generator
    safe true

    def generate(site)
      # list of MLH repos the pod is working on
      repos = [{ 'name' => 'prep-portfolio-23.APR.PREP.1',
                 'owner' => 'MLH-Fellowship'}]
      fellows = site.data['fellows']

      merged = [] # array of merged pull requests
      repos.each do |repo|
        # TODO: get other stats
        # TODO: proper error handling in API call and parsing?
        uri = URI("https://api.github.com/repos/#{repo['owner']}/#{repo['name']}/pulls")
        resp = Net::HTTP.get(uri)
        pulls = JSON.load(resp)
        # the way of seeing if a pull request was merged is by checking
        # whether merged_at is nil
        merged.concat(pulls.filter { |p| !p['merged_at'].nil? })
      end

      # array of merged pulls authors
      authors = merged.map { |m| m['user']['login'] }

      fellows.each do |fellow|
        # TODO: update fellow['name'] with the actual key (e.g. fellow['github'])
        # as soon as issue 13 gets solved
        # The fellow 'name' is not their username, but the usernames
        # haven't been yet added to _data/fellows.yml
        fellow['merged_pulls'] = authors.count(fellow['name'])
      end

      # get leaderboard template and add fellows data
      # TODO: the stats template
      stats_page = site.pages.find { |page| page.name == 'stats.html' }
      stats_page.data['fellows'] = fellows
    end
  end
end
