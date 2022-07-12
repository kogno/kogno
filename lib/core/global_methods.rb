def t(key, **interpolation)
  translation = I18n.t(key, **interpolation)
  if translation.class == Array
    return translation[rand(translation.count)]
  else
    return translation
  end
end

def l(value, **format)
  I18n.l(value, **format)
end

def set_payload(payload,params=nil)
  unless params.nil?
    output_payload = "#{payload}:#{params.to_json}" 
  else
    output_payload = payload
  end
  return output_payload
end

def reload!(print = true)
  puts 'Reloading ...' if print
  Kogno::Application.load_locales
  Kogno::Application.load_app
  return true
end

def sql_query(query)
  # logger.debug "sql_query = > #{query}", :green
  results = ActiveRecord::Base.connection.select_all(query)
  {
    columns: results.columns, 
    rows: results.rows
  }
  results
end

def html_template(route, params={})
  
  route_array = route.to_s.split("/")
  if route_array.count == 2
    action_group = route_array[0]
    action = route_array[1]
  elsif route_array.count == 1
    if self.type == :context
      action_group = self.name
      action = route_array[0]
    else
      raise "Can't determine the context for template #{route}"
      return false
    end
  else
      raise "Wrong format on route. Expected:'context_name/template_name'"
      return false
  end

  template = $context_html_templates[action_group.to_sym][action.to_sym]
  if template.nil?
    logger.write "Template bot/templates/#{action_group}/#{action}.rhtml not found.", :red
    return ""
  else
    return template.render(self, params)
  end

end
