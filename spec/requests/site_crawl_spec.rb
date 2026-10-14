require "spec_helper"

# Follows every internal link reachable from the home page and checks that
# each one renders. Keyed pages are only crawled for a single key, since the
# other eleven keys exercise exactly the same code paths.
RSpec.describe "Site crawl", type: :request do
  CRAWL_KEY = "Eb"

  def crawlable?(path)
    uri = URI.parse(path)
    return false if uri.host && uri.host != "www.example.com"
    return false unless uri.path&.start_with?("/")
    return false if uri.path.start_with?("/contribute")

    !uri.path.start_with?("/keys/") || uri.path.start_with?("/keys/#{CRAWL_KEY}/")
  rescue URI::InvalidURIError
    false
  end

  it "renders every page linked from the home page" do
    queue = ["/"]
    visited = Set.new
    failures = {}

    while (path = queue.shift)
      next if visited.include?(path)
      visited << path

      get path
      follow_redirect! while response.redirect?

      if response.status >= 400
        failures[path] = response.status
        next
      end

      Nokogiri::HTML(response.body).css("a[href]").each do |link|
        href = link["href"].split("#").first
        queue << href if href.present? && crawlable?(href) && !visited.include?(href)
      end
    end

    expect(failures).to be_empty, -> { failures.map { |page, status| "#{status} #{page}" }.join("\n") }
    expect(visited.size).to be > 100
  end
end
