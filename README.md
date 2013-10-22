Rubyを使用してニコニコ動画サイトから動画情報を取得する
=========================================================

対応するniconicoAPI一覧
	getflv
		http://flapi.nicovideo.jp/api/getflv/sm*
		指定された動画のFLV保管URLを取得できる
	getthumbinfo
		http://ext.nicovideo.jp/api/getthumbinfo/sm**
		動画の情報を得られる

非対応
	thumb
		http://ext.nicovideo.jp/thumb/sm*
		張り付け用のiframeが得られる
	getmarquee
		http://flapi.nicovideo.jp/api/getmarquee?*
		時報データの取得、ニコ割ゲームの取得、ニワニュース情報局のニュースインデックスの取得ができる
	getrelation
		http://flapi.nicovideo.jp/api/getrelation?page=**&sort=**&order=**&video=**
		それぞれpage,sort,order,videoを設定してアクセスすると、動画に関連するオススメ動画リストをXML形式で取得できる
	msg
		http://msg.nicovideo.jp/**/api
		このURLに、XMLをPOSTすると、指定した動画のコメントを取得できる
	rss
		http://www.nicovideo.jp/**/**?rss=atom or http://www.nicovideo.jp/**/**?rss=2.0
		マイリストや投稿動画一覧などのURLの最後に「?rss=atom(または2.0)」と打ち込んでアクセスすると、ATOM(RSS)形式で表示され、購読することも可能
