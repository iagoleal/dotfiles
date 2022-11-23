#!/bin/bash

# function list-tags() {
#   herbstclient foreach --unique --filter-name="[0-9]*" T tags. \
#     sprintf S "%{%c.name} %{%c.visible} %{%c.client_count} %{%c.frame_count}" T T T T echo S
# }

# # Go over all tags and delete those that are not visible and have no clients
# function delete-empty-tags() {
#   list-tags | while read -r tag visible ccount fcount; do
#     echo "t=$tag v=$visible c=$ccount f=$fcount"
#     if [[ $visible = false && $ccount -eq 0 && $fcount -eq 1 && $tag =~ .+_[0-9]+ ]]; then
#       herbstclient merge_tag $tag $(herbstclient get_attr tags.focus.name)
#     fi
#   done
# }

function list-tags() {
  herbstclient foreach --unique --filter-name="[0-9]*" T tags. sprintf S "%{%c.name}" T echo S
}

function delete-empty-tags() {
  for tag in $(list-tags); do
    num_clients=$(herbstclient attr tags.by-name.$tag.client_count)
    visibility=$(herbstclient attr tags.by-name.$tag.visible)
    renamed=$(herbstclient get_attr tags.by-name.$tag.my_renamed)
    if [[ $visibility = false && $num_clients -eq 0 && $tag =~ .+_[0-9]+ ]]; then
      herbstclient merge_tag $tag $(herbstclient get_attr tags.focus.name)
    fi
  done
}

herbstclient -i | while read -r hook info; do
  case $hook in
    tag_changed|tag_flags)
      delete-empty-tags
      ;;

    reload) break ;;
  esac
done
