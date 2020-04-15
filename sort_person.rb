require 'json'
require 'sort_kana_jisx4061'

filename = "person_detail.json"
content = File.read(filename)
json = JSON.load(content)
list = []
json.each do |person|
  person["name_sort"] = person["name_kana"].gsub(/[「」]/, "")
end

list = sort_kana_jisx4061_by(json){|a| a["name_sort"]}

puts JSON.generate(list)
