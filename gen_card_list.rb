#! /usr/bin/env ruby

# a script to generate all cards of Aozora Bunko in JSON
# 青空文庫に登録されている図書カードリストをJSON形式で生成するスクリプト
#
# Usage:
#   ruby gen_card_list.rb

require 'nokogiri'
require 'json'

ATTRS = {title: "作品名", title_kana: "作品名読み", subtitle: "副題", subtitle_kana: "副題読み",
         title_en: "原題", person_name: "著者名",
         collection:"作品集名", collection_kana:"作品集名読み",
         cat: "分類", work_detail: "作品について", kana_type: "文字遣い種別", detail: "備考",
         first_appearance: "初出",kana_type2:"仮名遣い種別",
         author_name: "作家名", author_kana: "作家名読み",
         input: "入力", proofread: "校正",
         author_en: "ローマ字表記", born_on: "生年", died_on: "没年", author_detail: "人物について",
         site_name: "サイト名", url: "URL"}
ATTRS_R = ATTRS.invert

SUMMARYS = {title: "タイトルデータ", work: "作品データ", author: "作家データ", worker: "工作員データ", site: "関連サイトデータ"}
def parse_table(doc, summary)
  list = []
  smr = SUMMARYS[summary]
  tables = doc.css("table[summary=\"#{smr}\"]")
  tables.each do |t|
    data = {}
    t.children.each do |node|
      if node.class == Nokogiri::XML::Element
        node.children.each do |child|
          if child.name == "td"
            if child["class"] == "header"
              value = child.text.strip.sub(/：$/,"")
              if summary == :author && value == "分類"
                @attr = :role
              else
                @attr = ATTRS_R[value]
              end
            else
              if [:author_detail, :detail, :work_detail].member?(@attr)
                data[@attr] = child.children.to_s.strip
              else
                data[@attr] = child.text.strip
              end

              if [:author_name, :person_name].member?(@attr)
                url = child.css("a").attribute("href").value
                url =~ /person(\d+)\.html/
                data[:author_num] = $1.to_i
              end
            end
          end
        end
      end
    end
    list << data
  end
  list
end

def parse_download(doc)
  table = doc.css("table[summary=\"ダウンロードデータ\"]")
  data = []
  table.children.each do |node|
    next if node.class == Nokogiri::XML::Text
    if node.class == Nokogiri::XML::Element
      elem = []
      node.children.each_with_index do |child, idx|
        if child.name == "td"
          value = child.text.strip
          elem << value
        end
      end
      if elem.size > 0
        charset, enc = elem[3].split("／")
        data << {filetype: elem[0],
                 compresstype: elem[1],
                 filename: elem[2],
                 charset: charset,
                 encoding: enc,
                 size: elem[4].to_i,
                 created_on: elem[5],
                 updated_on: elem[6]}
      end
    end
  end
  data
end

def parse_card(path)
  content = File.read(path)
  unless content.valid_encoding?
    content = File.read(path, encoding: "euc-jp")
  end
  doc = Nokogiri::HTML(content)

  card = {}
  card[:title] = parse_table(doc, :title)[0]
  card[:work] = parse_table(doc, :work)[0]
  card[:author] = parse_table(doc, :author)
  card[:woker] = parse_table(doc, :worker)[0]
  card[:download] = parse_download(doc)
  card[:site] = parse_table(doc, :site)

  card
end

def parse_all_cards
  cards = []

  i = 0
  Dir.glob("cards/*/card*.html") do |d|
    begin
      d =~ %r|cards/(\d+)/card(\d+)\.html|
      person_num = $1.to_i
      work_num = $2.to_i

      # num <= 4 まではダミーなので無視
      if person_num > 4
        i+=1
        card = parse_card(d)
        if card[:title]
          card[:title][:work_id] = work_num
          card[:title][:person_id] = person_num
          cards << card
        else
          raise "ERROR path: #{d}, card: #{card.inspect}"
        end
      end
    end
  end

  cards
end

card_list = parse_all_cards()
puts JSON.generate(card_list)

