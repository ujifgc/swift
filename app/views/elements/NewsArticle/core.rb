﻿@new = NewsArticle.by_slug @swift[:slug]
not_found  unless @new
@swift[:path_pages][-1] = Page.new :title => @new.title
