require 'json'

module Jekyll
  module AssetFilter
    def asset(input)
      manifest = @context.registers[:site].config['_assets']
      manifest.fetch(input, input)
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)

Jekyll::Hooks.register(:site, :after_init) do |site|
  unless ENV.key?("SKIP_ASSETS")
    env = Jekyll.env == "production" ? "production" : "dev"
    raise RuntimeError unless system("./node_modules/.bin/encore #{env}")
  end
end

Jekyll::Hooks.register(:site, :after_init) do |site|
  manifest = "src/assets/manifest.json"
  raise RuntimeError, "Manifest file #{manifest} not found." unless File.exist?(manifest)
  site.config['_assets'] = JSON.parse(File.read(manifest))
end
