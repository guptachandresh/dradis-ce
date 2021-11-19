json.recordsTotal current_project.issues.count
json.recordsFiltered @count
json.data @results do |issue|
  json.partial! 'issue', issue: issue
end
json.draw params[:draw]
