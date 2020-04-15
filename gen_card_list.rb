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
         collection: "作品集名", collection_kana: "作品集名読み",
         class: "分類", work_note: "作品について", kana_type: "文字遣い種別", note: "備考",
         first_appearance: "初出", kana_type2: "仮名遣い種別",
         author_name: "作家名", author_kana: "作家名読み",
         original_book: "底本", publisher: "出版社", first_edition: "初版発行日",
         input_edition: "入力に使用", proof_edition: "校正に使用",
         base_book: "底本の親本",
         input: "入力", proofread: "校正",
         author_en: "ローマ字表記", born_on: "生年", died_on: "没年", author_note: "人物について",
         site_name: "サイト名", url: "URL"}
ATTRS_R = ATTRS.invert

SUMMARYS = {title: "タイトルデータ", work: "作品データ", author: "作家データ",
            original_book: "底本データ", base_book: "親本データ",
            worker: "工作員データ", site: "関連サイトデータ"}

def parse_num_from_person_path(str)
  str =~ /person(\d+)\.html/
  $1.to_i
end

def parse_table(doc, summary)
  smr = SUMMARYS[summary]
  tables = doc.css("table[summary=\"#{smr}\"]")
  list = tables.map do |t|
    data = {}
    t.children.each do |node|
      if node.class == Nokogiri::XML::Element
        attr = nil
        node.children.each do |child|
          if child.name == "td"
            if child["class"] == "header"
              value = child.text.strip.sub(/：$/, "")
              if summary == :author && value == "分類"
                attr = :role
              else
                attr = ATTRS_R[value]
              end
            else
              if [:author_detail, :note, :work_detail].member?(attr)
                data[attr] = child.children.to_s.strip
              else
                data[attr] = child.text.strip
              end

              if [:author_name, :person_name].member?(attr)
                url = child.css("a").attribute("href").value
                data[:author_id] = parse_num_from_person_path(url)
              end
            end
          end
        end
      end
    end
    data
  end

  list
end

def parse_download(doc)
  table = doc.css("table[summary=\"ダウンロードデータ\"]")
  data = []
  table.children.each do |node|
    if node.class == Nokogiri::XML::Element
      elem = []
      node.children.each do |child|
        if child.name == "td"
          elem << child.text.strip
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

def read_content(path)
  content = File.read(path)
  unless content.valid_encoding?
    content = File.read(path, encoding: "euc-jp")
  end
  content
end

##
# remove kana_type2
#
# There are notation distortions of "仮名遣い種別" and "文字遣い種別".
#
def fix_kana_type(card)
  work = card[:work]
  if work[:kana_type2]
    work[:kana_type] = work[:kana_type2]
    work.delete(:kana_type2)
  end
end

def merge_original_book(card)
  card[:original_book] ||= []
  card[:base_book] ||= []
  card[:original_book].each do |elem|
    if elem[:original_book]
      elem[:book_title] = elem[:original_book]
      elem.delete(:original_book)
    end
    elem[:booktype] = "底本"
  end
  card[:base_book].each do |elem|
    if elem[:base_book]
      elem[:book_title] = elem[:base_book]
      elem.delete(:base_book)
    end
    elem[:booktype] = "底本の親本"
  end
  card[:original_book].concat(card[:base_book])
  card.delete(:base_book)
end

def parse_card(path)
  content = read_content(path)
  doc = Nokogiri::HTML(content)

  card = {
    title: parse_table(doc, :title)[0],
    work: parse_table(doc, :work)[0],
    author: parse_table(doc, :author),
    woker: parse_table(doc, :worker)[0],
    original_book: parse_table(doc, :original_book),
    base_book: parse_table(doc, :base_book),
    download: parse_download(doc),
    site: parse_table(doc, :site)
  }
  fix_kana_type(card)
  merge_original_book(card)
  card
end

def parse_person_and_work(path)
  path =~ %r|cards/(\d+)/card(\d+)\.html|
  person_num = $1.to_i
  work_num = $2.to_i
  return person_num, work_num
end

def parse_all_cards
  cards = []

  i = 0
  Dir.glob("cards/*/card*.html").sort.each do |d|
    begin
      person_num, work_num = parse_person_and_work(d)

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

