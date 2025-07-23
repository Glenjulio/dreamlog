# app/helpers/notifications_helper.rb
module NotificationsHelper
  # genere le conteneur pour les notifications
  def notification_container
    content_tag :div, '',
                data: {
                  controller: 'notifications',
                  notifications_target: 'container'
                },
                class: 'notifications-container'
  end
# Converts flash types to notification types for JavaScript
  def flash_to_notification_type(flash_type)
    case flash_type.to_s
    when 'notice'
      'success'
    when 'alert'
      'error'
    when 'warning'
      'warning'
    when 'info'
      'info'
    else
      'info'
    end
  end
# Renders flash notifications as JSON for JavaScript consumption
  def render_flash_notifications
    return unless flash.any?

    notifications = []
# converti les messages dans le format attendu par JavaScript
    flash.each do |type, message|
      notification_type = flash_to_notification_type(type)
      notifications << {
        message: message,
        type: notification_type
      }
    end

    content_tag :script, type: 'application/json',
                        data: { notifications: true } do
      notifications.to_json.html_safe
    end
  end
end
