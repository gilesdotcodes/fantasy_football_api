#!/usr/bin/env ruby

require 'httparty'
require 'sinatra'

class FantasyFootballApi
  def initialize
    @page = HTTParty.get('https://fantasy.premierleague.com/drf/bootstrap-static')
  end

  def risers
    make_response(output_players(players_with_increased_value))
  end

  def fallers
    make_response(output_players(players_with_decreased_value))
  end

  private

  def players_with_increased_value
    players.select{ |player| player['cost_change_event'] > 0 }
  end

  def players_with_decreased_value
    players.select{ |player| player['cost_change_event'] < 0 }
  end

  def players
    @players ||= @page['elements']
  end

  def output_name_and_value(player)
    "#{player['first_name']} #{player['last_name']} - #{format_cost(player['now_cost'])}"
  end

  def format_cost(cost)
    "#{cost/10}.#{cost%10}"
  end

  def output_players(players)
    ''.tap do |str|
      players.each do |player|
        str << output_name_and_value(player)
        str << "\n"
      end
    end
  end

  def make_response(text, attachments = [], response_type = 'in_channel')
    {
      text: text,
      attachments: attachments,
      username: 'Fantasy Football Bot',
      icon_url: 'https://www.premierleague.com/resources/ver/i/elements/premier-league-logo-header.svg',
      icon_emoji: 'https://www.premierleague.com/resources/ver/i/elements/premier-league-logo-header.svg',
      response_type: response_type
    }
  end
end


post '/football_risers' do
  fantasy_football_api = FantasyFootballApi.new
  content_type :json
  fantasy_football_api.risers.to_json
end

post '/football_fallers' do
  fantasy_football_api = FantasyFootballApi.new
  content_type :json
  fantasy_football_api.fallers.to_json
end
