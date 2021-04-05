#! /usr/bin/env ruby

# gen_card_list.rb で生成されたJSON card.json から、
# イニシャル別の作品IDリストを生成する
#
# Usage: ruby [this file] > index_work_ids_by_initial.json

require "json"

INPUT_JSON_FILENAME='./card.json'

def chunk_cards_by_initial
  output={}

  File.open(INPUT_JSON_FILENAME) do |f|
    cards = JSON.load(f)
    cards.each do |card|
      initial = card.dig("title","canonicalized_initial")
      work_id = card.dig("title","work_id")
      next if initial.nil? || work_id.nil?

      if output.has_key?(initial)
        output[initial].push(work_id)
      else
        output[initial] = [work_id]
      end
    end
  end
  output
end

result = chunk_cards_by_initial

result.each { |k,v| v.sort! }
result = result.sort_by{ |k, v| [k, v.size]}

puts JSON.generate(result.to_h)
