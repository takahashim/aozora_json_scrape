#! /usr/bin/env ruby

# a script to generate all authors and their works of Aozora Bunko in JSON
# 青空文庫に登録されいてる作家情報と作品リストをJSON形式で生成するスクリプト
#
# Usage:
#   git clone --depth=1 https://github.com/aozorabunko/aozorabunko
#   cd aozorabunko
#   ruby ../gen_person_detail_list.rb

require 'json'
require 'open-uri'

def gen_person_array
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
        person[person_num] = {id: person_num,
                              name: person_name}
        if line =~ %r|→<a href="person(\d+).html">(.+?)</a>|
          alt_num = $1.to_i
          alt_name = $2
          person[person_num].merge!({alt_id: alt_num, alt_name: alt_name})
        end
      end
    end
  end

  # do not compact
  person
end

def merge_person_and_work(person_array, work_list)
  work_list.each do |work|
    wid = work[:id]
    if person_array[wid] && person_array[wid][:alt_id]
      work[:alt_id] = person_array[wid][:alt_id]
      work[:alt_name] = person_array[wid][:alt_name]
    end
  end

  work_list
end

PERSON_HEADERS = {name: "作家名", name_kana: "作家名読み", name_en: "ローマ字表記", born_on: "生年", died_on: "没年",  desc: "人物について"}
SITE_HEADERS = {site_name: "サイト名", site_url: "URL",  site_desc: "備考"}

def gen_work_list
  work = []

  Dir.glob("index_pages/person*.html") do |d|
    begin
      d =~ /person(\d+)\.html/
      num = $1.to_i

      # num <= 4 まではダミーなので無視
      if num > 4
        content = File.read(d)

        # format:
        # <li><a href="../cards/000005/card5.html">あいびき</a>　（新字新仮名、作品ID：5）　 　　 →<a href="person6.html">二葉亭 四迷</a>(翻訳者) </li>
        # <li>カエルの王さま　または鉄のハインリッヒ（新字新仮名、作品ID：59498）　 →<a href="person1092.html">グリム ヴィルヘルム・カール</a>(著者) →<a href="person1891.html">矢崎 源九郎</a>(翻訳者) </li>
        content.each_line do |line|
          if line =~ %r{<a href="../cards/\d+/card(\d+)\.html">(.*?)</a>}
            work_id, title = $1.to_i, $2
            work[num] ||= {id: num, work: []}
            work[num][:work] ||= []
            new_work = {work_id: work_id, title: title}
            if line =~ %r{</a>　(.+)?（(.+)、作品ID：(\d+)）}
              subtitle, kana_type, work_id = $1, $2, $3.to_i
              if subtitle
                new_work[:subtitle] = subtitle
              end
              new_work[:kana_type] = kana_type
            end

            author_line = line.dup
            while author_line =~ %r{→<a href="person(\d+)\.html">(.+?)</a>\((.+?)\)}
              person_id, person_name, role = $1.to_i, $2, $3
              new_work["others"] ||= []
              new_work["others"] << {person_id: person_id, person_name: person_name, role: role}
              author_line = $'
            end
            work[num][:work] << new_work
          elsif line =~ %r{<div class="copyright">}
            work[num][:copyright] = true
          elsif line =~ %r{<tr><td class="header">(.+?)：</td><td>(.+?)</td>}
            header, body = $1, $2
            if PERSON_HEADERS.values.include?(header)
              key, _ = PERSON_HEADERS.rassoc(header)
              if key == :name
                body.gsub!(/<[^>]+>/,"")
                body.gsub!(/　→.*$/,"")
              end
              work[num] ||= {id: num, work: []}
              work[num][key] = body
            elsif SITE_HEADERS.values.include?(header)
              key, _ = SITE_HEADERS.rassoc(header)
              if key == :site_name
                body.gsub!(/<[^>]+>/,"")
              end
              work[num] ||= {id: num, work: []}
              work[num][key] = body
            end
          elsif line =~ %r{<li>(.+?)　(.*?)（(.+?)、作品ID：(\d+)）　}
            title, subtitle, kana_type, work_id = $1, $2, $3, $4.to_i
            wip = {title: title, subtitle: subtitle, kana_type: kana_type, work_id: work_id}
            author_line = line.dup
            while author_line =~ %r{→<a href="person(\d+)\.html">(.+?)</a>\((.+?)\)}
              person_id, person_name, role = $1.to_i, $2, $3
              wip[:others] ||= []
              wip[:others] << {person_id: person_id, person_name: person_name, role: role}
              author_line = $'
            end
            work[num][:wip] ||= []
            work[num][:wip] << wip
          end
        end
        if work[num][:work]
          ## よみがな順ソート？
          ## work[num][:work].sort!{|a,b| a[:work_id] <=> b[:work_id] }
        end
      end
    rescue ArgumentError => e # encoding error
      ##  STDERR.print d, ": ", e.class, "\n"
    end
  end

  work.compact!

  work
end

def main
  person_array = gen_person_array()
  work_list = gen_work_list()

  list = merge_person_and_work(person_array, work_list)

  puts list.to_json
end

main
