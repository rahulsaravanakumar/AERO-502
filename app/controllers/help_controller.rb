# Shows docs/USER_GUIDE.md inside the website, so the guide in the repository
# and the one members read are always the same. Open to everyone, so people who
# cannot sign in can still read what to do.
class HelpController < ApplicationController
     GUIDE_PATH = Rails.root.join("docs/USER_GUIDE.md")

     def show
          renderer = Redcarpet::Render::HTML.new(with_toc_data: true, escape_html: true)
          @guide_html = Redcarpet::Markdown.new(renderer, tables: true, autolink: true).render(GUIDE_PATH.read)
     end
end
