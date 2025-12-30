require "will_paginate/view_helpers/action_view"

module WillPaginate
    module ActionView
        class BootstrapLinkRenderer < LinkRenderer
            protected

            def html_container(html)
                tag(:div, html, container_attributes)
            end

            def page_number(page)
                if page == current_page
                    tag(:div, link(page, page, class: "page-link"), class: "page-item active")
                else
                    tag(:div, link(page, page, rel: rel_value(page), class: "page-link"), class: "page-item")
                end
            end

            def gap
                tag(:div, link("&hellip;", "#", class: "page-link"), class: "page-item disabled")
            end


            def previous_or_next_page(page, text, classname, aria_label = nil)
                if page
                    tag(:div, link(text, page, class: "page-link"), class: "page-item #{classname}")
                else
                    tag(:div, link(text, "#", class: "page-link"), class: "page-item disabled #{classname}")
                end
            end
        end
    end
end
