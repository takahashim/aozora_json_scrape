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
      end
    end
  end
 rescue ArgumentError => e
   ##  STDERR.print d, ": ", e.class, "\n"
 end
end

work.compact!

puts work.to_json
