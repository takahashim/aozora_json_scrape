#!/usr/bin/env ruby

# a script to generate all authors of Aozora Bunko in JSON
# 青空文庫に登録されいてる作家リストをJSON形式で生成するスクリプト
#
# Usage:
#   ruby gen_person_list.rb

require 'open-uri'
require 'json'

def gen_person_list
  url = "https://www.aozora.gr.jp/index_pages/person_all_all.html"
  person = []
  open(url) do |f|
    content = f.read()
    content.each_line do |line|
      line.force_encoding("UTF-8")

      # format sample:
      # <li><a href="person948.html">市島 謙吉</a>　(公開中：0、作業中：1)　　(→<a href="person412.html">市島 春城</a>)</li>
      if line =~ %r|<li><a href="person(\d+).html">(.+?)</a>|
        person_num = $1.to_i
        person_name = $2
        if line =~ %r|→<a href="person(\d+).html">(.+?)</a>|
          alt_num = $1.to_i
          alt_name = $2
        end
        person[person_num] = {id: person_num,
                              name: person_name}
        if alt_num
          person[person_num].merge!({alt_id: alt_num, alt_name: alt_name})
        end
      end
    end
  end
  person.compact!

  person
end

person = gen_person_list()
puts JSON.generate(person)
