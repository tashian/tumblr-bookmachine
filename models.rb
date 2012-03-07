class Post
  include MongoMapper::Document

  def year
    created_at.strftime('%Y')
  end
  def month
    created_at.strftime('%B')
  end

  def day
    created_at.strftime("%d")
  end

  def qr_for_url
    link_url.blank? ? nil : "http://qrcode.kaywa.com/img.php?s=8&d=#{CGI.escape(link_url)}"
  end
end
