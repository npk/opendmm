module OpenDMM
  module Maker
    module Attackers
      include Maker

      module Site
        include HTTParty
        base_uri "attackers.net"

        def self.item(name)
          name =~ /(\w+)-(\d+)/
          get("/works/-/detail/=/cid=#{$1.downcase}#{$2}/")
        end
      end

      module Parser
        def self.parse(content)
          page_uri = content.request.last_uri
          html = Nokogiri::HTML(content)
          specs = parse_specs(html)
          return {
            actresses:    Hash.new_with_keys(specs["出演女優"].split),
            directors:    Hash.new_with_keys(specs["監督"].split),
            description:  html.css("p.works_txt").first.text.squish,
            genres:       specs["ジャンル"].split,
            images: {
              cover:   URI.join(page_uri, html.css("div#works_pake_box a#pake").first["href"]).to_s,
              samples: html.css("ul#sample_photo li a").map { |a| URI.join(page_uri, a["href"]).to_s },
            },
            label:        specs["レーベル"],
            maker:        "Attackers",
            movie_length: ChronicDuration.parse(specs["収録時間"]),
            page:         page_uri.to_s,
            product_id:   specs["品番"],
            release_date: Date.parse(specs["発売日"]),
            series:       parse_series(specs["シリーズ"]),
            title:        html.css("div.hl_box_btm").first.text.squish,
          }
        end

        private

        def self.parse_specs(html)
          specs = {}
          html.css("div#works-content ul li").each do |li|
            if li.text =~ /(.*)：(.*)/
              specs[$1.squish] = $2.squish
            end
          end
          specs
        end

        def self.parse_series(str)
          case str
          when /-+/
            return nil
          else
            return str
          end
        end
      end

      def self.search(name)
        case name
        when /ADN-\d{3}/
          Parser.parse(Site.item(name))
        end
      end
    end
  end
end