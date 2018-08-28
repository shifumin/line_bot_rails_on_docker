# frozen_string_literal: true

require 'line/bot'
require 'http'
require 'json'

class WebhookController < ApplicationController
  protect_from_forgery except: :callback

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text'] + 'ぷよっ。'
          }
          client.reply_message(event['replyToken'], message)
          response = HTTP.post("https://slack.com/api/chat.postMessage", params: {
            token: ENV["SLACK_API_TOKEN"],
            channel: "#bot",
            text: event.message['text'],
            # as_user: true
          })
          puts JSON.pretty_generate(JSON.parse(response.body))
        else
          response = HTTP.post("https://slack.com/api/chat.postMessage", params: {
            token: ENV["SLACK_API_TOKEN"],
            channel: "#bot",
            text: 'テキスト以外の何かが送られました。',
            # as_user: true
          })
          puts JSON.pretty_generate(JSON.parse(response.body))
        end
      end
    }

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
