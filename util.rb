# ・濁点、半濁点、拗音、カタカナを、ひらがな清音に正規化。
#  例:が→か ぽ→ほ ヅ→つ ゃ→や
# ・アルファベット、数字の全角を、半角に正規化
# ・記号は除く
CANONICALIZE_FROM = 'がぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔぁぃぅぇぉゃゅょアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴァィゥェォャュョＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ０１２３４５６７８９'
CANONICALIZE_TO   = 'かきくけこさしすせそたちつてとはひふへほはひふへほうあいうえおやゆよあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんかきくけこさしすせそたちつてとはひふへほはひふへほうあいうえおやゆよABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
def canonicalize_initial str
  return nil if str.nil? || str.empty?
  canonicalize_to_kana(str)[0]
end

def canonicalize_to_kana str
  return nil if str.nil?
  str
    .gsub(/[「」『』（）〔〕【】〈〉［］“”‘’\(\)\{\}\[\]・＠＃＄％＊！？＋＝@#$%\*\!\?\+=]/, "")
    .tr(CANONICALIZE_FROM, CANONICALIZE_TO)
end
