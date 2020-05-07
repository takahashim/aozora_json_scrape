require 'csv'
require 'json'
require 'zip'
require 'open-uri'

def make_works(csv_file)
  works = {}
  CSV.foreach(csv_file, headers: true) do |row|
    work_id, title, subtitle, published_on, card_url, f_name, l_name, role, input, proofread =
                                                                                   row[0], row[1], row[4], row[11], row[13], row[15], row[16], row[23], row[43], row[44]
    if works[work_id]
      work = works[work_id]
      if work[:title] != title || work[:subtitle] != subtitle || work[:published_on] != published_on || work[:card_url] != card_url
        raise "Invalid data: #{row.inspect}"
      end
    else
      works[work_id] = {work_id: work_id, title: title, subtitle: subtitle,
                        published_on: published_on, card_url: card_url,
                        input: input, proofread: proofread}
    end
    works[work_id][:author] ||= []
    works[work_id][:author] << {author_name: "#{f_name} #{l_name}", role: role}
  end

  ## 公開日順と作品ID順で一意にソート
  works_sorted = works.values.sort_by{ |work| [work[:published_on], work[:work_id]] }.reverse

  works_sorted
end

def extract_aozora_csv(csv_file)
  url = "https://www.aozora.gr.jp/index_pages/list_person_all_extended_utf8.zip"
  zip_file = "list_person_all_extended_utf8.zip"

  content = open(url).read
  File.write(zip_file, content)

  Zip::File.open(zip_file) do |zip_file|
    entry = zip_file.glob(csv_file).first
    entry.extract
  end
end

def save_whatsnew_json(works, year)
  works_year = works_sorted.select{ |work| work[:published_on].start_with?(year) }
  File.write("whatsnew#{year}.json", JSON.dump(works_year)+"\n")
end


# 作品ID,作品名,作品名読み,ソート用読み,副題,副題読み,原題,初出,分類番号,文字遣い種別,作品著作権フラグ,公開日,最終更新日,図書カードURL,人物ID,姓,名,姓読み,名読み,姓読みソート用,名読みソート用,姓ローマ字,名ローマ字,役割フラグ,生年月日,没年月日,人物著作権フラグ,底本名1,底本出版社名1,底本初版発行年1,入力に使用した版1,校正に使用した版1,底本の親本名1,底本の親本出版社名1,底本の親本初版発行年1,底本名2,底本出版社名2,底本初版発行年2,入力に使用した版2,校正に使用した版2,底本の親本名2,底本の親本出版社名2,底本の親本初版発行年2,入力者,校正者,テキストファイルURL,テキストファイル最終更新日,テキストファイル符号化方式,テキストファイル文字集合,テキストファイル修正回数,XHTML/HTMLファイルURL,XHTML/HTMLファイル最終更新日,XHTML/HTMLファイル符号化方式,XHTML/HTMLファイル文字集合,XHTML/HTMLファイル修正回数

csv_file = "list_person_all_extended_utf8.csv"
extract_aozora_csv(csv_file)

## whasnew
works_sorted = make_works(csv_file)

curr_year = works_sorted.first[:published_on].slice(0,4)
prev_year = (curr_year.to_i - 1).to_s

save_whatsnew_json(works, curr_year)
save_whatsnew_json(works, prev_year)
