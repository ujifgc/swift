﻿@file = Asset.first :id => @args[0]
return "[Asset ##{@args[0]} missing]"  unless @file
