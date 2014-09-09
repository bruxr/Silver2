module DeviseHelper

  def devise_error_messages!

    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.join('<br>')
    html = "<div class=\"error\"><i class=\"fa fa-exclamation-circle\"> #{messages}</div>"
    html.html_safe

  end

end