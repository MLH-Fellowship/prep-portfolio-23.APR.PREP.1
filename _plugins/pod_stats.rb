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
      projects = site.data['projects']
      fellows = site.data['fellows'] # list of pod fellows
      fellows.each { |f| f['merged'] = f['commits'] = 0 }
      projects.map { |p| p['repo'] }.each do |repo|
        repo['commits'] = repo['merged'] = 0
        add_merges!(fellows, repo)
        add_commits!(fellows, repo)
      end
      # get leaderboard template and add fellows data
      stats_page = site.pages.find { |page| page.name == 'stats.html' }
      stats_page.data['fellows'] = fellows
      stats_page.data['projects'] = projects
    end


    def add_commits!(fellows, repo)
      usernames = fellows.map { |f| f['github'] }
      uri = URI("https://api.github.com/repos/#{repo['owner']}/#{repo['name']}/stats/contributors")
      contributors = get_as_json(uri)

      contributors.each do |contr|
        username = contr['author']['login'].downcase
        next unless usernames.include?(username)

        commits = contr['total'].to_i
        repo['commits'] += commits
        fellow = fellows.detect { |f| f['github'] == username }
        fellow['commits'] += commits
      end
    end


    def add_merges!(fellows, repo)
      usernames = fellows.map { |f| f['github'] }
      uri = URI("https://api.github.com/search/issues?q=repo:#{repo['owner']}/#{repo['name']}+is:pr+is:merged")
      merges = get_as_json(uri)
      merges['items'].each do |merge|
        username = merge['user']['login']
        next unless usernames.include?(username)

        repo['merged'] += 1
        fellow = fellows.detect { |f| f['github'] == username }
        fellow['merged'] += 1
      end
    end

    
    def get_as_json(uri)
      resp = Net::HTTP.get(uri)
      parsed = JSON.parse(resp)
      if parsed.instance_of?(Hash) && !parsed['message'].nil?
        msg = "Error with GET request to #{uri}"
        msg += ": #{parsed['message']}"
        raise msg
      end
      parsed
    end
  end
end
