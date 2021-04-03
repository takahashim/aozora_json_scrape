#! /usr/bin/env ruby

# gen_perspmon_detail_list.rb で生成されたJSON person_detail.json から、
# ひらがな五十音の索引をつけたJSONを生成する
#
# Usage: ruby [this file] > indexed_person_detail.json

require "json"
require "../util.rb"

INPUT_JSON_FILENAME='../card.json'

def chunk_cards_by_bibclass
  output={}

  File.open(INPUT_JSON_FILENAME) do |f|
    cards = JSON.load(f)
    cards.each do |card|
      bibclass = card.dig("work","bibclass")
      work_id = card.dig("title","work_id")
      next if bibclass.nil? || work_id.nil?

      canonicalize_bibclass(bibclass).each do |ndc|
        if output.has_key?(ndc)
          output[ndc].push(work_id)
        else
          output[ndc] = [work_id]
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
  v.sort!
end
result.sort_by!{ |k, v| [k, v.size]}

puts JSON.generate(result)
