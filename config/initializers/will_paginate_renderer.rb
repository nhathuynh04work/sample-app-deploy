require "will_paginate/view_helpers/action_view"

module WillPaginate
    module ActionView
        class BootstrapLinkRenderer < LinkRenderer
            protected

            def html_container(html)
                tag(:ul, html, container_attributes)
            end

            def page_number(page)
                if page == current_page
                    tag(:li, link(page, page, class: "page-link"), class: "page-item active")
                else
                    tag(:li, link(page, page, rel: rel_value(page), class: "page-link"), class: "page-item")
                end
            end

            def gap
                tag(:li, link("&hellip;", "#", class: "page-link"), class: "page-item disabled")
            end


            def previous_or_next_page(page, text, classname, aria_label = nil)
                if page
                    tag(:li, link(text, page, class: "page-link"), class: "page-item #{classname}")
                else
                    tag(:li, link(text, "#", class: "page-link"), class: "page-item disabled #{classname}")
                end
            end
        end
    end
end
