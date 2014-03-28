require "Niconico/version"
require 'uri'
require 'rubygems'
require 'open-uri'
require 'rexml/document'
require 'hpricot'
require 'mechanize'
require 'kconv'
require 'net/http'

# == Sample 1
#
# require "Niconico"
# 
# mail = "mail"
# password = "password"
# nico = NiconicoAPI.new
# nico.login(mail,password)
# 
# start_id = 9
# end_id   = start_id 
# for number in start_id .. end_id do
# 	nico.setVideoId(number)
# 	nico.download
# 	sleep(1)
# end
# nico.logout
#
#
#
# == Sample 2
# require "Niconico"
# 
# mail = "mail"
# password = "password"
# nico = NiconicoAPI.new
# nico.login(mail,password)
# p title = niconico.getMylist(1773577) { |number|
#	nico.setVideoId(number)
#	nico.getComment(-1000) do |chat|
#		p chat
#	end
#	nico.download
#	sleep(1)
# }
# p nico.getMylistTitle
# nico.logout
#

class NiconicoAPI

	attr_reader(:video_id         )
	attr_reader(:title            )
	attr_reader(:description      )
	attr_reader(:thumbnail_url    )
	attr_reader(:first_retriev    )
	attr_reader(:length           )
	attr_reader(:movie_type       )
	attr_reader(:size_high        )
	attr_reader(:size_low         )
	attr_reader(:view_counter     )
	attr_reader(:comment_num      )
	attr_reader(:mylist_counte    )
	attr_reader(:last_res_body    )
	attr_reader(:watch_url        )
	attr_reader(:thumb_type       )
	attr_reader(:embeddable       )
	attr_reader(:no_live_play     )
	attr_reader(:user_id          )
	attr_reader(:error_code       )
	attr_reader(:error_description)
	attr_reader(:tags             )
	attr_reader(:tags_category    )
	attr_reader(:tags_lock        )


    def initialize(video_id = nil)
		@temp_dir = "."
		@number = video_id
		@agent = Mechanize.new
		if video_id != nil then
			getVideoInfo
		end
	end

	# == Description
	# Set video id 
	def setVideoId(video_id)
		#TODO video_id = sm9
		@number = video_id
		getVideoInfo
	end

	def getXML
		cnt_retry = 0
		begin
			page = open("http://ext.nicovideo.jp/api/getthumbinfo/sm#{@number}")
			xml_filename = @temp_dir + "/xml/#{@number}.xml"
			if File.exist?(xml_filename) then
				printf("%s is already downloaded.\n",xml_filename)
			else
				File.open(xml_filename, 'w') { |f|
					page.each_line do |line|
						f.write line
					end
				}
			end
		rescue
			sleep 30
			cnt_retry += 1
			retry if cnt_retry < 5
		end
	end

	def getVideoInfo
		getXML

		@error_code = ""
		@error_description = ""
		@tags = Array.new()
		@tags_category = Array.new()
		@tags_lock = Array.new()

		xml_filename = @temp_dir + "/xml/#{@number}.xml"
		doc = REXML::Document.new(open(xml_filename))
		@status = doc.elements['nicovideo_thumb_response'].attributes['status']
		if @status == "fail" then
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
				@tags.push(tag.text)
				@tags_category.push(tag.attributes['category']) 
				@tags_lock.push(tag.attributes['lock'])
			end
			#p tags,tags_category,tags_lock
			tags_csv = @tags.join(",")
			printf("video_id:%s title:%s\n", @video_id, @title)
		end
		getflvAPI
	end

	def login(mail,password)
		@mail = mail
		@password = password
		login_page = @agent.get("https://secure.nicovideo.jp/secure/login_form")
		login_form = login_page.forms.first
		login_form['mail_tel'] = @mail
		login_form['password'] = @password
		redirect_page = @agent.submit(login_form)
		#TODO set @login_result="ok"|"fail"
	end

	def logout
		@agent.get("https://secure.nicovideo.jp/secure/logout")
	end

	def getflvAPI
		if @status == "ok" then
			getflv = @agent.get("http://flapi.nicovideo.jp/api/getflv/"+@video_id)
			getflv_url=URI.decode(getflv.body)
			getflv_url2=getflv_url.split(/\s*&\s*/)
			@thread_id 		= getflv_url2[0].slice(10..getflv_url2[0].length)
			@video_url		= getflv_url2[2].slice(4..getflv_url2[2].length)
			@link			= getflv_url2[3].slice(5..getflv_url2[3].length)
			@ms_url			= getflv_url2[4].slice(3..getflv_url2[4].length)
		end
	end

	def download
		if @status == "ok" then
			@agent.get("http://www.nicovideo.jp/watch/"+@video_id)
			printf("Start Downloading:%s\n",@video_id)
			video_file = @agent.get_file(@video_url)
#TODO if file exist then skip downloading
			file = File.open("video/" + @video_id + "." + @movie_type, "wb")
			file.write video_file
			file.close
		end
	end

	def getMylist(mylist_no)
		@mylist_link = Array.new()
		@mylist_title = nil
		page = open("http://www.nicovideo.jp/mylist/#{mylist_no}?rss=atom")
		xml_filename = @temp_dir + "/mylist/#{mylist_no}.xml"
		if File.exist?(xml_filename) then
			printf("%s is already downloaded.\n",xml_filename)
		else
			File.open(xml_filename, 'w') { |f|
				page.each_line do |line|
					f.write line
				end
			}
		end

		mylist = REXML::Document.new(open(xml_filename))
		@mylist_title = mylist.elements['feed/title'].text
		@mylist_title =~ /マイリスト (.*)‐ニコニコ動画/
		@mylist_title = $1
		mylist.elements.each('feed/entry') do |entry|
			link = entry.elements['link'].attributes['href']
			@mylist_link.push( link )
			link =~ /http:\/\/www.nicovideo.jp\/watch\/sm(\d*)/
			number = $1
			yield number
		end
		@mylist_title
	end

	def getMylistTitle
		return @mylist_title
	end

	def getComment(comment_num = -250)
		version = "20061206"
		xml_filename = @temp_dir + "/comment/#{@video_id}.xml"
		if @status == "ok" then
			uri = URI.parse(@ms_url)
			Net::HTTP.start(uri.host, uri.port){|http|
				post_xml = sprintf("<thread thread=\"%s\" version=\"%s\" res_from=\"%d\" />",@thread_id,version,comment_num)
				response = http.post(uri.path, post_xml)
				file = File.open(xml_filename , "wb")
				file.write response.body
				file.close
			}
			comment_list = REXML::Document.new(open(xml_filename))
			comment = Hash.new
			comment_list.elements.each('packet/chat') do |chat|
				comment[:vpos] = chat.attributes['vpos']
				comment[:chat] = chat.text
				yield comment
				#printf("%8d: %s\n",vpos,comment)
			end
		end
	end

	def setTempDir(dir)
		@temp_dir = dir
	end

end

