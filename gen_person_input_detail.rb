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

=begin
      <tr vAlign="top">
        <td vAlign="top" align="left"  width="20" bgColor="#ffffcc">No.</td>
        <td vAlign="top" align="left" width="260" bgColor="#ffffcc">作品名(作品ID)<br>副題</td>
        <td vAlign="top" align="left" width="100" bgColor="#ffffcc">文字遣い種別</td>
        <td vAlign="top" align="left" width="100" bgColor="#ffffcc">翻訳者名等<br>(人物ID)</td>
        <td vAlign="top" align="left" width="100" bgColor="#ffffcc">入力者名<br>校正者名</td>
        <td vAlign="top" align="left" width="140" bgColor="#ffffcc">状態<br>状態の開始日</td>
        <td vAlign="top" align="left" width="200" bgColor="#ffffcc">底本名<br>出版社名</td>
        <td vAlign="top" align="left" width="200" bgColor="#ffffcc">入力に使用した版</td>
      </tr>
<!-------------------------- Loop Start ---------------------------->
      <tr vAlign="top">
        <td vAlign="top" align="right" width="20">1</td>
        <td vAlign="top" align="left" width="260">猟人日記(18331)</td>
        <td vAlign="top" align="left" width="100">新字新仮名</td>
        <td vAlign="top" align="left" width="100">中山 省三郎<br>(1061)</td>
        <td vAlign="top" align="left" width="100">高木昌規<br>　</td>
        <td vAlign="top" align="left" width="140"><font color=red>校正待ち(点検前)</font><br>2011-09-28</td>
        <td vAlign="top" align="left" width="200">猟人日記<br>角川文庫、角川書店</td>
        <td vAlign="top" align="left" width="200">1990（平成2）年11月15日4版発行</td>
      </tr>
=end

def parse_buf(elem)
  return if elem.empty?
  num = elem[0].to_i
  elem[1] =~ /(.*)\((\d+)\)/
  title, work_id = $1, $2.to_i
  kana_type = elem[2]
  people = []
  elem[3].scan(/\((\d+)\)/) do |matched|
    people << matched[0].to_i
  end
  input, proofread = elem[4].split("<br>")
  if proofread == '　'
    proofread = nil
  end
  status, started = elem[5].split("<br>")
  status.gsub!(/<[^>]+>/, "")
  teihon, publisher = elem[6].split("<br>")
  edition = elem[7]

  return {work_id: work_id,
          title: title,
          kana_type: kana_type,
          others: people,
          input: input,
          proofread: proofread,
          status: status,
          started_on: started,
          original: teihon,
          publisher: publisher}
end

def gen_work_list
  work = []

  Dir.glob("index_pages/list_inp*_*.html") do |d|
    begin
      d =~ /list_inp(\d+)_(\d+)\.html/
      num = $1.to_i
      num2 = $2.to_i

      # num <= 4 まではダミーなので無視
      if num > 4
        content = File.read(d)

        td_buf = []
        content.each_line do |line|
          # <h1>作業中　作家別作品一覧：ツルゲーネフ イワン　No.5</h1>
          if line =~ %r{<h1>作業中　作家別作品一覧：(.*)　No.(\d+)</h1>}
            name, person_num = $1, $2.to_i
            work[person_num] ||= {id: person_num, work: []}
          elsif line =~ %r{</tr>}
            elem = parse_buf(td_buf)
            if elem
              work[num][:work] << elem
            end
            td_buf = []
          elsif line =~ %r{<td vAlign="top"([^>]+)>(.*)</td>}
            attrs, elem = $1, $2
            next if attrs =~ /bgColor=/
            td_buf.push(elem)
          end
        end
        if work[num][:work]
          work[num][:work].sort!{|a,b| a[:work_id] <=> b[:work_id] }
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
