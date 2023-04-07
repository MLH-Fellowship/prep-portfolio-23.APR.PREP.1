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
      repos = site.data['projects'].map { |p| p['repo'] }
      fellows = site.data['fellows'] # list of pod fellows
      # TODO: update 'name' with the actual key (e.g. 'github')
      # as soon as issue 13 gets solved
      usernames = fellows.map { |f| f['name'] }
      fellows.each { |f| f['commits'] = 0 }

      repos.each do |repo|
        # TODO: get other stats
        uri = URI("https://api.github.com/repos/#{repo['owner']}/#{repo['name']}/stats/contributors")
        resp = Net::HTTP.get(uri)
        contributors = JSON.parse(resp)
        unless contributors.instance_of?(Array)
          msg = "Error with GET request to #{uri}"
          msg += ": #{contributors['message']}" if contributors.instance_of?(Hash)
          raise msg
        end

        contributors.each do |contr|
          username = contr['author']['login']
          next unless usernames.include?(username)

          commits = contr['total']
          fellow = fellows.select { |f| f['name'] == username }
          fellow['commits'] += commits
        end
      end

      # get leaderboard template and add fellows data
      stats_page = site.pages.find { |page| page.name == 'stats.html' }
      stats_page.data['fellows'] = fellows
    end
  end
end
