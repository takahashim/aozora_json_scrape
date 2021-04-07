#! /usr/bin/env ruby

# gen_person_detail_list.rb で生成されたJSON person_detail.json から、
# イニシャル別の著者IDリストを生成する
#
# Usage: ruby [this file] > index_work_ids_by_initial.json

require "json"

INPUT_JSON_FILENAME='./person_detail.json'

def chunk_persons_by_initial
  output={}

  File.open(INPUT_JSON_FILENAME) do |f|
    JSON.load(f).each do |person|
      initial = person.dig("canonicalized_initial")
      person_id = person.dig("id")
      next if initial.nil? || person_id.nil?

      if output.has_key?(initial)
        output[initial].push(person_id)
      else
        output[initial] = [person_id]
      end
    end
  end
  output
end

result = chunk_persons_by_initial

result.each { |k,v| v.sort! }
result = result.sort_by{ |k, v| [k, v.size]}

puts JSON.generate(result.to_h)
