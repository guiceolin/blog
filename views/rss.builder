xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "Rodrigo Navarro"
  xml.id "http://blog.rnavarro.com.br"
  xml.updated Post.published.first.date.iso8601
  xml.author { xml.name "Rodrigo Navarro" }

  Post.published.each do |post|
    xml.entry do
      xml.title post.title
      xml.link "rel" => "alternate", "href" => post.path
      xml.id post.path
      xml.published post.date.iso8601
      xml.updated post.date.iso8601
      xml.author { xml.name post.author }
      xml.content markdown(post.body), "type" => "html"
    end
  end
end
