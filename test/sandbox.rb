text ='[have][tag:haga] brave [cave][tag:gha] save'
text.gsub(/\[([^\[]*)\]\[tag:(.*?)\]/) do |txt|
  print "#{txt}, #{$1}, #{$2}\n"
end