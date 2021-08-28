#! /usr/bin/env ruby

# gen_person_detail_list.rb で生成されたJSON person_detail.json から、
# イニシャル別の著者リストを生成する
#
require "json"
require_relative "util.rb"

INPUT_JSON_FILENAME='./person_detail.json'

def chunk_persons_by_initial
  output={}

  File.open(INPUT_JSON_FILENAME) do |f|
    JSON.load(f).each do |person|
      initial = person.dig("canonicalized_initial")
      person_id = person.dig("id")
      next if initial.nil? || person_id.nil?

      p = {
        id: person_id,
        name: person["name"],
        name_kana: canonicalize_to_kana(person["name_kana"]),
        works_count: (person["work"] || []).size,
        wips_count: (person["wip"] || []).size
      }

      if output.has_key?(initial)
        output[initial].push(p)
      else
        output[initial] = [p]
      end
    end
  end
  output
end

result = chunk_persons_by_initial

result.each do |k,v|
  v.sort! do |a,b|
    a[:id] <=> b[:id]
  end.sort! do |a,b|
    a[:name_kana] <=> b[:name_kana]
  end
end
result = result.sort_by{ |k, v| [k, v.size]}

puts JSON.generate(result.to_h)
