#!/usr/local/bin/ruby

require 'uri'
require 'csv'
require "mysql"
require 'rubygems'
require 'cgi'
require 'open-uri'
require 'json'
require 'rexml/document'
require 'hpricot'
require 'mechanize'
require 'open-uri'
require 'kconv'
require 'net/http'

# == Sample
#
# require "./Niconico"
# 
# mail = "mail"
# password = "password"
# nico = Niconico::new
# nico.login(mail,password)
# 
# start_id = 9
# end_id   = start_id 
# for number in start_id .. end_id do
# 	nico.setVideoId(number)
# 	nico.download
# 	sleep(3)
# end
# nico.logout
#


class Niconico

	attr_reader(:title)

    def initialize(video_id = 1)
		@number = video_id
		if video_id != 1 then
			getInfo
		end
		#@my.query("delete from Nicodou")
	end

	# == Description
	# Set video id 
	def setVideoId(video_id)
		#TODO video_id = sm9
		@number = video_id
		getInfo
	end

	def getXML
		page = open("http://ext.nicovideo.jp/api/getthumbinfo/sm#{@number}")
		File.open("xml/#{@number}.xml", 'w') { |f|
			page.each_line do |line|
				f.write line
			end
		}
	end

	def getInfo
		getXML

		error_code = ""
		error_description = ""
		tags = Array.new()
		tags_category = Array.new()
		tags_lock = Array.new()

		doc = REXML::Document.new(open("xml/#{@number}.xml"))
		result = doc.elements['nicovideo_thumb_response'].attributes['status']
		if result == "fail" then
			@error_code = doc.elements['nicovideo_thumb_response/error/code'].text
			@error_description = doc.elements['nicovideo_thumb_response/error/description'].text
			printf("video_id:%s Fail Code:%s::%s\n" ,@number ,@error_code ,@error_description)
		else
			@video_id 			= doc.elements['nicovideo_thumb_response/thumb/video_id'].text
			@title 				= doc.elements['nicovideo_thumb_response/thumb/title'].text
			@title		 		= @title.gsub(/[\\'"]/) {|ch| ch + ch }
			@description 		= doc.elements['nicovideo_thumb_response/thumb/description'].text
			@description 		= @description.gsub(/[\\'"]/) {|ch| ch + ch }
			@thumbnail_url 		= doc.elements['nicovideo_thumb_response/thumb/thumbnail_url'].text
			@first_retrieve 		= doc.elements['nicovideo_thumb_response/thumb/first_retrieve'].text
			@length 				= doc.elements['nicovideo_thumb_response/thumb/length'].text
			@movie_type 			= doc.elements['nicovideo_thumb_response/thumb/movie_type'].text
			@size_high			= doc.elements['nicovideo_thumb_response/thumb/size_high'].text
			@size_low			= doc.elements['nicovideo_thumb_response/thumb/size_low'].text
			@view_counter		= doc.elements['nicovideo_thumb_response/thumb/view_counter'].text
			@comment_num			= doc.elements['nicovideo_thumb_response/thumb/comment_num'].text
			@mylist_counter		= doc.elements['nicovideo_thumb_response/thumb/mylist_counter'].text
			@last_res_body		= doc.elements['nicovideo_thumb_response/thumb/last_res_body'].text
			@watch_url			= doc.elements['nicovideo_thumb_response/thumb/watch_url'].text
			@thumb_type			= doc.elements['nicovideo_thumb_response/thumb/thumb_type'].text
			@embeddable			= doc.elements['nicovideo_thumb_response/thumb/embeddable'].text
			@no_live_play		= doc.elements['nicovideo_thumb_response/thumb/no_live_play'].text
			@user_id			= doc.elements['nicovideo_thumb_response/thumb/user_id'].text
			#tags_domain		= doc.elements['nicovideo_thumb_response/thumb/tags'].attributes['domain']
			doc.elements.each('nicovideo_thumb_response/thumb/tags/tag') do |tag|
				tags.push(tag.text)
				tags_category.push(tag.attributes['category']) 
				tags_lock.push(tag.attributes['lock'])
			end
			#p tags,tags_category,tags_lock
			tags_csv = tags.join(",")
			printf("video_id:%s title:%s\n", @video_id, @title)

		end
	end

	def login(mail,password)
		@mail = mail
		@password = password
	end

	def logout
		printf("TODO")
	end

	def download
		flv_id = @video_id
		agent = Mechanize.new
		login_page = agent.get("https://secure.nicovideo.jp/secure/login_form")
		login_form = login_page.forms.first
		login_form['mail_tel'] = @mail
		login_form['password'] = @password
		redirect_page = agent.submit(login_form)
		getflv = agent.get("http://flapi.nicovideo.jp/api/getflv/"+flv_id)
		getflv_url=URI.decode(getflv.body)
		getflv_url2=getflv_url.split(/\s*&\s*/)
		thread_id 		= getflv_url2[0].slice(10..getflv_url2[0].length)
		url 			= getflv_url2[2].slice(4..getflv_url2[2].length)
		link			= getflv_url2[3].slice(5..getflv_url2[3].length)
		ms 				= getflv_url2[4].slice(3..getflv_url2[4].length)

		watch = agent.get("http://www.nicovideo.jp/watch/"+flv_id)
		#agent.cookie_jar.save("test.cookie")
		printf("Start Downloading:%s\n",flv_id)
		flv_file = agent.get_file(url)
		file = File.open("video/" + flv_id + "." + @movie_type, "wb")
		file.write flv_file
		file.close
		logout=agent.get("https://secure.nicovideo.jp/secure/logout")
	end
end

