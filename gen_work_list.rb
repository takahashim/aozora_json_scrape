#! /usr/bin/env ruby

# a script to generate all works of Aozora Bunko in JSON
# 青空文庫に登録されいてる作品リストをJSON形式で生成するスクリプト
#
# Usage:
#   git clone --depth=1 https://github.com/aozorabunko/aozorabunko
#   cd aozorabunko
#   ruby ../gen_work_list.rb

require 'json'

work = []

person_headers = {name: "作家名", name_kana: "作家名読み", name_en: "ローマ字表記", born_on: "生年", died_on: "没年",  desc: "人物について"}
site_headers = {site_name: "サイト名", site_url: "URL",  site_desc: "備考"}

Dir.glob("index_pages/person*.html") do |d|
 begin
  d =~ /person(\d+)\.html/
  num = $1.to_i

  # num <= 4 まではダミーなので無視
  if num > 4
    content = File.read(d)

    # format:
    # <li><a href="../cards/000005/card5.html">あいびき</a>　（新字新仮名、作品ID：5）　 　　 →<a href="person6.html">二葉亭 四迷</a>(翻訳者) </li>
    content.each_line do |line|
      if line =~ %r{<a href="../cards/\d+/card(\d+)\.html">(.*?)</a>}
        work_id, title = $1.to_i, $2
        work[num] ||= {id: num, work: []}
        work[num][:work] ||= []
        work[num][:work] << {work_id: work_id, title: title}
      elsif line =~ %r{<tr><td class="header">(.+?)：</td><td>(.+?)</td>}
        header, body = $1, $2
        if person_headers.values.include?(header)
          key, _ = person_headers.rassoc(header)
          if key == :name
            body.gsub!(/<[^>]+>/,"")
            body.gsub!(/　→.*$/,"")
          end
          work[num] ||= {id: num, work: []}
          work[num][key] = body
        elsif site_headers.values.include?(header)
          key, _ = site_headers.rassoc(header)
          if key == :site_name
            body.gsub!(/<[^>]+>/,"")
          end
          work[num] ||= {id: num, work: []}
          work[num][key] = body
        end
      end
    end
  end
 rescue ArgumentError => e
   ##  STDERR.print d, ": ", e.class, "\n"
 end
end

work.compact!

puts work.to_json
