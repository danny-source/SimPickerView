#!/bin/sh

find -E . -not \( -name .svn -prune -o -name .git -prune -o -name Pods -prune \) -regex '.*\.(h|m|mm|swift)' -print0 | xargs -0 sed -i -E "s/[[:space:]]*$//"
