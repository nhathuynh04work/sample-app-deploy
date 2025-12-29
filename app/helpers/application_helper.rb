module ApplicationHelper
    def full_title(page_title = "")
        base_title = "Ruby on Rails Tutorial Sample App"
        if page_title.empty?
            base_title
        else
            page_title  + " | " + base_title
        end
    end

    def alert_class(message_type)
        "alert alert-#{message_type}"
    end
end
