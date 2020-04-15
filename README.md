![Update JSON files](https://github.com/takahashim/aozora_json_scrape/workflows/Update%20JSON%20files/badge.svg)

青空文庫の作家リストJSONと作品リストJSONを、青空文庫公開サイトとgithubリポジトリから生成するスクリプトと生成結果のJSONファイルです。

* person.json (作家リスト)
    * id: 作家ID
    * name: 作家名(姓 名)
    * alt_id: 別名の作家ID
    * alt_name: 別名の作家名

* person_detail.json (作家情報+作品リスト)
    * id: 作家ID
    * name: 作家名(姓 名)
    * alt_id: 別名の作家ID
    * alt_name: 別名の作家名
    * name_kana: 作家名読み
    * name_en: 作家名ローマ字表記
    * born_on: 生年月日
    * died_on: 没年月日
    * desc: 人物について
    * site_name: 関連サイト名
    * site_url: 関連サイトURL
    * copyright: 著作権存続フラグ
    * work: 作品
        * work_id: 作品ID
        * title: 作品タイトル

* card.json (図書カードリスト)
    * title: タイトルデータ
      * title: 作品名
      * title_kana: 作品名読み
      * subtitle: 副題
      * subtitle_kana: 副題読み
      * collection: 作品集名
      * collection_kana: 作品集名読み
      * person_name: 著者名
      * author_num: 著者ID
      * work_id: 作品ID
      * person_id: 作者ID (= 著者ID)
    * work: 作品データ
      * class: 分類名・分類番号
      * work_note: 作品について
      * kana_type: 文字遣い種別
      * note: 備考
    * author: 作家データ
      * role: 役割分類
      * author_name: 作家名
      * author_num: 作家ID
      * author_kana: 作家名読み
      * author_ne: ローマ字表記
      * born_on: 生年月日
      * died_on: 没年月日
      * author_note: 人物について
    * woker: 工作員データ
        * input: 入力
        * proofread: 校正
    * original_book: 底本
        * booktype: 底本種別(底本/底本の親本)
        * original_book: 底本
        * publisher: 出版社
        * first_edition: 初版発行日
        * input_edition: 入力に使用
        * proof_edition: 校正に使用
        * note: 備考
    * download: ダウンロードデータ
        * filetype: ファイル種別
        * compresstype: 圧縮方式
        * filename: ファイル名
        * charset: 文字集合
        * encoding: 符号化方式
        * size: サイズ
        * created_on: 初登録日
        * updated_on: 最終更新日
    * site: 関連サイトデータ
        * site_name: 関連サイト名
        * url: 関連サイトURL
