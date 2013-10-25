Rubyを使用してニコニコ動画サイトから動画情報を取得する
=========================================================

## 対応するniconicoAPI一覧
* **getflv** - 指定された動画のFLV保管URLを取得できる  
  `http://flapi.nicovideo.jp/api/getflv/sm*`
		
* **getthumbinfo** - 動画の情報を得られる  
  `http://ext.nicovideo.jp/api/getthumbinfo/sm*`
		
* **rss** - マイリストや投稿動画一覧などのURLの最後に「?rss=atom(または2.0)」と打ち込んでアクセスすると、ATOM(RSS)形式で表示され、購読することも可能  
	`http://www.nicovideo.jp/**/**?rss=atom or http://www.nicovideo.jp/**/**?rss=2.0`

* **msg** - このURLに、XMLをPOSTすると、指定した動画のコメントを取得できる  
	`http://msg.nicovideo.jp/**/api`


## 非対応(未検証)
* **thumb** - 張り付け用のiframeが得られる  
	`http://ext.nicovideo.jp/thumb/sm*`
* **getmarquee** - 時報データの取得、ニコ割ゲームの取得、ニワニュース情報局のニュースインデックスの取得ができる  
	`http://flapi.nicovideo.jp/api/getmarquee?*`
* **getrelation** - それぞれpage,sort,order,videoを設定してアクセスすると、動画に関連するオススメ動画リストをXML形式で取得できる
	`http://flapi.nicovideo.jp/api/getrelation?page=**&sort=**&order=**&video=**`
