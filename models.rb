class Post
  include MongoMapper::Document

  def year
    created_at.strftime('%Y')
  end

  def month
    created_at.strftime('%B')
  end

  def month_with_year
    created_at.strftime('%B %Y')
  end

  def day
    created_at.strftime("%d")
  end

end
