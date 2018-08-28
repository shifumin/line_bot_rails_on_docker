# frozen_string_literal: true

Rails.application.routes.draw do
  post '/callback' => 'webhook#callback'
end
