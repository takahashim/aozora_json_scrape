#! /usr/bin/env ruby

# gen_card_list.rb で生成されたJSON card.json から、
# 十進法分類別の作品リストを生成する
#
# Usage: ruby [this file] > work_ids_by_bibclass.json

require "json"
require_relative "util.rb"

INPUT_JSON_FILENAME='./card.json'

def chunk_cards_by_bibclass
  output={}

  File.open(INPUT_JSON_FILENAME) do |f|
    cards = JSON.load(f)
    cards.each do |card|
      bibclass = card.dig("work","bibclass")
      work_id = card.dig("title","work_id")
      next if bibclass.nil? || work_id.nil?

      work = {
        id: work_id,
        title: card.dig("title", "title"),
        subtitle: card.dig("title", "subtitle"),
        kana_type: card.dig("work", "kana_type"),
        author: card.dig("title", "person_name"),
        title_kana: canonicalize_to_kana(card.dig("title", "title_kana")),
      }

      canonicalize_bibclass(bibclass).each do |ndc|
        if output.has_key?(ndc)
          output[ndc].push(work)
        else
          output[ndc] = [work]
        end
      end
    end
  end
  output
end

# args:
#   bibclass: ^NDC( K?\d{3})+$
# returns: 
#   [\d{3}]
def canonicalize_bibclass(bibclass)
  bibclass
    .sub(/^NDC ?/, "")
    .split
    .map { |s| s.delete_prefix("K") }
end


result = chunk_cards_by_bibclass

result.each do |k,v|
  v.sort! do |a,b|
    a[:id] <=> b[:id]
  end.sort! do |a,b|
    a[:title_kana] <=> b[:title_kana]
  end
end
result = result.sort_by{ |k, v| [k, v.size]}

puts JSON.generate(result.to_h)
