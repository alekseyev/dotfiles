function cecho --description 'echo in a given color: cecho green hello'
    set_color $argv[1]
    echo $argv[2..-1]
    set_color normal
end
