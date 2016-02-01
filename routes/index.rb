# encoding: utf-8
class Makecollage < Sinatra::Application
  def makeImage(images, imageheight)
  	if imageheight.nil?
			return MultiJson.dump({ :error => 'Property imageheight must exist' })
		end

		if images.nil?
			return MultiJson.dump({ :error => 'Property images of type array must exist and contain images as objects', :description => 'images: [{ image: src, x, y, width, height }]' })
		end

		f = Magick::Image.new(610, imageheight) {}
		
		images.each { |x|
			img = Magick::Image.read(x['src']).first
			#newimage = img.minify
			img.resize!(x['width'], x['height'], filter=LanczosFilter, support=1.0)

			f.composite!(img, x['x'], x['y'], OverCompositeOp)
		} 

		filename = filename()

		f.write(File.join('public/tmp/', filename))

		return filename
  end
 
  def filename
  	return Time.now.to_i.to_s + '.jpg'
  end

  get '/' do 
  	send_file File.join('public', 'index.html')
	end

  get '/oauth/connect' do
   	e = params[:e]
  	
  	if e.empty? 
  		send_file File.join('public', '401.html')
  	end

   	decrypted = AES.decrypt(e, ENV['AES_SECRET']).to_s
   	
  	arr = decrypted.split(" ")
  	
	  if arr.kind_of?(Array)
	  	session[:userid] = arr[0]
			session[:cid] = arr[1]
	  end	  

   	redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
	end

	get '/oauth/fb' do
		session[:source] = "facebook"

		 MultiJson.dump({:images => [], :source => session[:source] })
	end

  get '/oauth/callback' do
	  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
	  session[:access_token] = response.access_token
	  session[:source] = "instagram"
	  
	  redirect('#/builder')
	end

	get '/images' do
	  if session[:access_token]
	    client = Instagram.client(:access_token => session[:access_token])

	    MultiJson.dump({:images => client.user_recent_media, :source => session[:source] })
	  else 
	    MultiJson.dump({:error => 'not authorized' })
	  end
	end

	post '/generate_s3' do 
		payload = MultiJson.load(request.body.read)
		images = payload['images']
		imageheight = payload['imageheight']
		bucket = ENV['AWS_BUCKET']
		
		filename = makeImage(images, imageheight)

		s3 = AWS::S3::new(
	    :access_key_id     => ENV['AWS_ACCESS_KEY'],
	    :secret_access_key => ENV['AWS_ACCESS_SECRET']
  	)
		
		s3.buckets[bucket].objects[filename].write(:file => 'public/tmp/'+filename)
			
		MultiJson.dump({ :url => "https://#{bucket}.s3.amazonaws.com/#{filename}" })
	end

	post '/generate' do 
		payload = MultiJson.load(request.body.read)
		images = payload['images']
		imageheight = payload['imageheight']
		
		filename = makeImage(images, imageheight)
		
		Uploader.new('public/tmp/'+filename, session[:userid], session[:cid]).post_img

		MultiJson.dump({ :status => "success" })
	end
end

