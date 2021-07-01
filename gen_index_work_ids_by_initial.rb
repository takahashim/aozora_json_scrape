#! /usr/bin/env ruby

# gen_card_list.rb で生成されたJSON card.json から、
# イニシャル別の作品リストを生成する
#
# Usage: ruby [this file] > index_work_ids_by_initial.json

require "json"
require_relative "util.rb"

INPUT_JSON_FILENAME='./card.json'

def chunk_cards_by_initial
  output={}

  File.open(INPUT_JSON_FILENAME) do |f|
    cards = JSON.load(f)
    cards.each do |card|
      initial = card.dig("title","canonicalized_initial")
      work_id = card.dig("title","work_id")
      next if initial.nil? || work_id.nil?

      work = {
        id: work_id,
        title: card.dig("title", "title"),
        subtitle: card.dig("title", "subtitle"),
        kana_type: card.dig("work", "kana_type"),
        author: card.dig("title", "person_name"),
        title_kana: canonicalize_to_kana(card.dig("title", "title_kana")),
      }

      if output.has_key?(initial)
        output[initial].push(work)
      else
        output[initial] = [work]
      end
    end
  end
  output
end

result = chunk_cards_by_initial

result.each do |k,v|
  v.sort! do |a,b|
    a[:id] <=> b[:id]
  end.sort! do |a,b|
    a[:title_kana] <=> b[:title_kana]
  end
end
result = result.sort_by{ |k, v| [k, v.size]}

puts JSON.generate(result.to_h)
