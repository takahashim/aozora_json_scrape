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
    * work: 作品
        * work_id: 作品ID
        * title: 作品タイトル

作品の情報については青空文庫のCSVを利用してください。
