module Sinatra
  module Buttons
    def post_button(name, url, **options)
      form_button(name, url, 'post', **options)
    end

    private

    def form_button(name, url, method, confirm: nil, **options)
      option_tags = options.map do |key, value|
        "<input type='hidden' name='#{key}' value='#{value}'>"
      end

      <<-HTML
        <form method="#{method}" action="#{url}" class="inline-form">
          #{csrf_tag}
          #{option_tags.join}

          <button class="btn" type="submit" #{confirm ? "data-confirm='#{confirm}'" : ''}>#{name}</button>
        </form>
      HTML
    end
  end

  helpers Buttons
end
