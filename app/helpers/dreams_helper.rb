module DreamsHelper
  def highlight_search_term(text, search_term)
    return text if search_term.blank?

    highlighted = highlight(text, search_term, highlighter: '<mark class="search-highlight">\1</mark>')
    highlighted.html_safe
  end
end
